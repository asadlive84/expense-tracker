package report

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/asad/expense-tracker/internal/cache"
	sqlcdb "github.com/asad/expense-tracker/internal/db/sqlc"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type BucketBalance struct {
	BucketID     uuid.UUID `json:"bucket_id"`
	Name         string    `json:"name"`
	BalancePaisa int64     `json:"balance_paisa"`
}

type PersonBalance struct {
	PersonID uuid.UUID `json:"person_id"`
	Name     string    `json:"name"`
	NetPaisa int64     `json:"net_paisa"`
}

type TagTotal struct {
	TagID      uuid.UUID `json:"tag_id"`
	Name       string    `json:"name"`
	TotalPaisa int64     `json:"total_paisa"`
}

type MonthlySummary struct {
	Income  int64      `json:"income_paisa"`
	Expense int64      `json:"expense_paisa"`
	Net     int64      `json:"net_paisa"`
	ByTag   []TagTotal `json:"by_tag"`
}

type Service struct {
	pool  *pgxpool.Pool
	cache *cache.Cache
}

func NewService(pool *pgxpool.Pool, c *cache.Cache) *Service {
	return &Service{pool: pool, cache: c}
}

func (s *Service) BucketBalances(ctx context.Context, userID uuid.UUID) ([]BucketBalance, error) {
	key := cache.KeyBucketBalances(userID.String())

	if b, ok := s.cache.Get(ctx, key); ok {
		var result []BucketBalance
		if err := json.Unmarshal(b, &result); err == nil {
			return result, nil
		}
	}

	rows, err := sqlcdb.New(s.pool).BucketBalances(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("bucket balances: %w", err)
	}

	result := make([]BucketBalance, len(rows))
	for i, r := range rows {
		result[i] = BucketBalance{BucketID: r.BucketID, Name: r.Name, BalancePaisa: r.BalancePaisa}
	}

	if b, err := json.Marshal(result); err == nil {
		s.cache.Set(ctx, key, b, cache.TTLBucketBalance)
	}
	return result, nil
}

func (s *Service) PersonBalances(ctx context.Context, userID uuid.UUID) ([]PersonBalance, error) {
	key := cache.KeyPersonBalances(userID.String())

	if b, ok := s.cache.Get(ctx, key); ok {
		var result []PersonBalance
		if err := json.Unmarshal(b, &result); err == nil {
			return result, nil
		}
	}

	rows, err := sqlcdb.New(s.pool).PersonBalances(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("person balances: %w", err)
	}

	result := make([]PersonBalance, len(rows))
	for i, r := range rows {
		result[i] = PersonBalance{PersonID: r.PersonID, Name: r.Name, NetPaisa: r.NetPaisa}
	}

	if b, err := json.Marshal(result); err == nil {
		s.cache.Set(ctx, key, b, cache.TTLPersonBalance)
	}
	return result, nil
}

func (s *Service) TagTotals(ctx context.Context, userID uuid.UUID, from, to time.Time) ([]TagTotal, error) {
	fromStr := from.UTC().Format("2006-01-02")
	toStr := to.UTC().Format("2006-01-02")
	key := cache.KeyTagTotals(userID.String(), fromStr, toStr)

	if b, ok := s.cache.Get(ctx, key); ok {
		var result []TagTotal
		if err := json.Unmarshal(b, &result); err == nil {
			return result, nil
		}
	}

	rows, err := sqlcdb.New(s.pool).TagTotals(ctx, sqlcdb.TagTotalsParams{
		UserID:       userID,
		OccurredAt:   pgtype.Timestamptz{Time: from.UTC(), Valid: true},
		OccurredAt_2: pgtype.Timestamptz{Time: to.UTC(), Valid: true},
	})
	if err != nil {
		return nil, fmt.Errorf("tag totals: %w", err)
	}

	result := make([]TagTotal, len(rows))
	for i, r := range rows {
		result[i] = TagTotal{TagID: r.TagID, Name: r.Name, TotalPaisa: r.TotalPaisa}
	}

	if b, err := json.Marshal(result); err == nil {
		s.cache.Set(ctx, key, b, cache.TTLTagTotals)
	}
	return result, nil
}

func (s *Service) Summary(ctx context.Context, userID uuid.UUID, month string) (*MonthlySummary, error) {
	key := cache.KeySummary(userID.String(), month)

	if b, ok := s.cache.Get(ctx, key); ok {
		var result MonthlySummary
		if err := json.Unmarshal(b, &result); err == nil {
			return &result, nil
		}
	}

	t, err := time.Parse("2006-01", month)
	if err != nil {
		return nil, fmt.Errorf("parse month %q: %w", month, err)
	}
	start := time.Date(t.Year(), t.Month(), 1, 0, 0, 0, 0, time.UTC)
	end := start.AddDate(0, 1, 0)

	row, err := sqlcdb.New(s.pool).MonthlySummary(ctx, sqlcdb.MonthlySummaryParams{
		UserID:       userID,
		OccurredAt:   pgtype.Timestamptz{Time: start, Valid: true},
		OccurredAt_2: pgtype.Timestamptz{Time: end, Valid: true},
	})
	if err != nil {
		return nil, fmt.Errorf("monthly summary: %w", err)
	}

	tagTotals, err := s.TagTotals(ctx, userID, start, end.Add(-time.Second))
	if err != nil {
		tagTotals = nil
	}

	result := &MonthlySummary{
		Income:  row.TotalIncome,
		Expense: row.TotalExpense,
		Net:     row.TotalIncome - row.TotalExpense,
		ByTag:   tagTotals,
	}

	if b, err := json.Marshal(result); err == nil {
		s.cache.Set(ctx, key, b, cache.TTLSummary)
	}
	return result, nil
}
