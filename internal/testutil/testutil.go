package testutil

import (
	"context"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/asad/expense-tracker/internal/cache"
	appdb "github.com/asad/expense-tracker/internal/db"
	"github.com/asad/expense-tracker/internal/platform/logger"
	"github.com/jackc/pgx/v5/pgxpool"
	tcpostgres "github.com/testcontainers/testcontainers-go/modules/postgres"
	tcredis "github.com/testcontainers/testcontainers-go/modules/redis"
)

type TestDB struct {
	Pool  *pgxpool.Pool
	Cache *cache.Cache
}

// moduleRoot finds the Go module root by walking up until go.mod is found.
func moduleRoot() string {
	_, filename, _, _ := runtime.Caller(0)
	dir := filepath.Dir(filename)
	for {
		if _, err := os.Stat(filepath.Join(dir, "go.mod")); err == nil {
			return dir
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			panic("go.mod not found")
		}
		dir = parent
	}
}

func NewTestDB(t *testing.T) *TestDB {
	t.Helper()
	ctx := context.Background()

	pgC, err := tcpostgres.Run(ctx, "postgres:16-alpine",
		tcpostgres.WithDatabase("testdb"),
		tcpostgres.WithUsername("test"),
		tcpostgres.WithPassword("test"),
		tcpostgres.BasicWaitStrategies(),
	)
	if err != nil {
		t.Fatalf("start postgres: %v", err)
	}
	t.Cleanup(func() { _ = pgC.Terminate(ctx) })

	connStr, err := pgC.ConnectionString(ctx, "sslmode=disable")
	if err != nil {
		t.Fatalf("postgres connstr: %v", err)
	}

	migrationsPath := filepath.Join(moduleRoot(), "internal", "db", "migrations")
	if err := appdb.RunMigrations(connStr, migrationsPath); err != nil {
		t.Fatalf("migrate: %v", err)
	}

	pool, err := appdb.NewPool(ctx, connStr)
	if err != nil {
		t.Fatalf("pool: %v", err)
	}
	t.Cleanup(func() { pool.Close() })

	redisC, err := tcredis.Run(ctx, "redis:7-alpine")
	if err != nil {
		t.Fatalf("start redis: %v", err)
	}
	t.Cleanup(func() { _ = redisC.Terminate(ctx) })

	redisURL, err := redisC.ConnectionString(ctx)
	if err != nil {
		t.Fatalf("redis connstr: %v", err)
	}

	log := logger.New("test")
	c, err := cache.New(redisURL, log)
	if err != nil {
		t.Fatalf("cache: %v", err)
	}

	return &TestDB{Pool: pool, Cache: c}
}
