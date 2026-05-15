package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/asad/expense-tracker/internal/cache"
	"github.com/asad/expense-tracker/internal/config"
	appdb "github.com/asad/expense-tracker/internal/db"
	apphttp "github.com/asad/expense-tracker/internal/http"
	"github.com/asad/expense-tracker/internal/platform/logger"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		fmt.Fprintf(os.Stderr, "config error: %v\n", err)
		os.Exit(1)
	}

	log := logger.New(os.Getenv("ENV"))

	ctx := context.Background()

	// Run migrations
	migrationsPath := "internal/db/migrations"
	if p := os.Getenv("MIGRATIONS_PATH"); p != "" {
		migrationsPath = p
	}
	if err := appdb.RunMigrations(cfg.DatabaseURL, migrationsPath); err != nil {
		log.Error("migration failed", "err", err)
		os.Exit(1)
	}
	log.Info("migrations complete")

	// Connect to DB
	pool, err := appdb.NewPool(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Error("db connect failed", "err", err)
		os.Exit(1)
	}
	defer pool.Close()

	// Seed user
	if err := appdb.SeedUser(ctx, pool, cfg.SeedUserEmail, cfg.SeedUserPassword); err != nil {
		log.Error("seed user failed", "err", err)
		os.Exit(1)
	}

	// Connect to Redis
	redisCache, err := cache.New(cfg.RedisURL, log)
	if err != nil {
		log.Error("redis connect failed", "err", err)
		os.Exit(1)
	}

	// Build router
	router := apphttp.NewRouter(pool, redisCache, cfg.JWTSecret, log)

	srv := &http.Server{
		Addr:         ":" + cfg.Port,
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		log.Info("server starting", "addr", srv.Addr)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Error("server error", "err", err)
			os.Exit(1)
		}
	}()

	<-quit
	log.Info("shutting down")

	shutdownCtx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(shutdownCtx); err != nil {
		log.Error("shutdown error", "err", err)
	}
	log.Info("server stopped")
}
