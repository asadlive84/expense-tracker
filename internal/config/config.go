package config

import (
	"errors"
	"os"
)

type Config struct {
	Port                 string
	DatabaseURL          string
	RedisURL             string
	JWTSecret            string
	SeedUserEmail        string
	SeedUserPassword     string
}

func Load() (*Config, error) {
	cfg := &Config{
		Port:             getEnv("PORT", "8080"),
		DatabaseURL:      os.Getenv("DATABASE_URL"),
		RedisURL:         getEnv("REDIS_URL", "redis://localhost:6379"),
		JWTSecret:        os.Getenv("JWT_SECRET"),
		SeedUserEmail:    os.Getenv("SEED_USER_EMAIL"),
		SeedUserPassword: os.Getenv("SEED_USER_PASSWORD"),
	}

	var errs []error
	if cfg.DatabaseURL == "" {
		errs = append(errs, errors.New("DATABASE_URL is required"))
	}
	if cfg.JWTSecret == "" {
		errs = append(errs, errors.New("JWT_SECRET is required"))
	}
	if len(cfg.JWTSecret) < 32 {
		errs = append(errs, errors.New("JWT_SECRET must be at least 32 characters"))
	}
	if cfg.SeedUserEmail == "" {
		errs = append(errs, errors.New("SEED_USER_EMAIL is required"))
	}
	if cfg.SeedUserPassword == "" {
		errs = append(errs, errors.New("SEED_USER_PASSWORD is required"))
	}

	return cfg, errors.Join(errs...)
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
