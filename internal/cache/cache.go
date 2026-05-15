package cache

import (
	"context"
	"fmt"
	"log/slog"
	"time"

	"github.com/redis/go-redis/v9"
)

const (
	TTLBucketBalance  = time.Hour
	TTLPersonBalance  = time.Hour
	TTLTagTotals      = 15 * time.Minute
	TTLSummary        = time.Hour
)

type Cache struct {
	client *redis.Client
	log    *slog.Logger
}

func New(redisURL string, log *slog.Logger) (*Cache, error) {
	opts, err := redis.ParseURL(redisURL)
	if err != nil {
		return nil, fmt.Errorf("parse redis url: %w", err)
	}
	return &Cache{client: redis.NewClient(opts), log: log}, nil
}

func (c *Cache) Get(ctx context.Context, key string) ([]byte, bool) {
	val, err := c.client.Get(ctx, key).Bytes()
	if err == redis.Nil {
		return nil, false
	}
	if err != nil {
		c.log.WarnContext(ctx, "redis get failed", "key", key, "err", err)
		return nil, false
	}
	return val, true
}

func (c *Cache) Set(ctx context.Context, key string, value []byte, ttl time.Duration) {
	if err := c.client.Set(ctx, key, value, ttl).Err(); err != nil {
		c.log.WarnContext(ctx, "redis set failed", "key", key, "err", err)
	}
}

func (c *Cache) Del(ctx context.Context, keys ...string) {
	if len(keys) == 0 {
		return
	}
	if err := c.client.Del(ctx, keys...).Err(); err != nil {
		c.log.WarnContext(ctx, "redis del failed", "keys", keys, "err", err)
	}
}

func (c *Cache) DelByPattern(ctx context.Context, pattern string) {
	var cursor uint64
	for {
		keys, next, err := c.client.Scan(ctx, cursor, pattern, 100).Result()
		if err != nil {
			c.log.WarnContext(ctx, "redis scan failed", "pattern", pattern, "err", err)
			return
		}
		if len(keys) > 0 {
			pipe := c.client.Pipeline()
			for _, k := range keys {
				pipe.Del(ctx, k)
			}
			if _, err := pipe.Exec(ctx); err != nil {
				c.log.WarnContext(ctx, "redis pipeline del failed", "pattern", pattern, "err", err)
			}
		}
		cursor = next
		if cursor == 0 {
			break
		}
	}
}

func KeyBucketBalances(userID string) string {
	return fmt.Sprintf("bal:bucket:%s", userID)
}

func KeyPersonBalances(userID string) string {
	return fmt.Sprintf("bal:person:%s", userID)
}

func KeyTagTotals(userID, from, to string) string {
	return fmt.Sprintf("tagtot:%s:%s:%s", userID, from, to)
}

func KeyTagTotalsPattern(userID string) string {
	return fmt.Sprintf("tagtot:%s:*", userID)
}

func KeySummary(userID, month string) string {
	return fmt.Sprintf("summary:%s:%s", userID, month)
}

func KeySummaryPattern(userID string) string {
	return fmt.Sprintf("summary:%s:*", userID)
}
