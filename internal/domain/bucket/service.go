package bucket

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/asad/expense-tracker/internal/platform/apperror"
	sqlcdb "github.com/asad/expense-tracker/internal/db/sqlc"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Bucket struct {
	ID              uuid.UUID  `json:"id"`
	UserID          uuid.UUID  `json:"user_id"`
	Name            string     `json:"name"`
	StartingBalance int64      `json:"starting_balance_paisa"`
	ArchivedAt      *time.Time `json:"archived_at,omitempty"`
	CreatedAt       time.Time  `json:"created_at"`
}

type Service struct {
	pool *pgxpool.Pool
}

func NewService(pool *pgxpool.Pool) *Service {
	return &Service{pool: pool}
}

func (s *Service) List(ctx context.Context, userID uuid.UUID) ([]Bucket, error) {
	rows, err := sqlcdb.New(s.pool).ListBuckets(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("list buckets: %w", err)
	}
	out := make([]Bucket, len(rows))
	for i, r := range rows {
		out[i] = fromRow(r)
	}
	return out, nil
}

func (s *Service) Get(ctx context.Context, id, userID uuid.UUID) (*Bucket, error) {
	row, err := sqlcdb.New(s.pool).GetBucket(ctx, sqlcdb.GetBucketParams{ID: id, UserID: userID})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apperror.NotFound("bucket not found")
		}
		return nil, fmt.Errorf("get bucket: %w", err)
	}
	b := fromRow(row)
	return &b, nil
}

type CreateInput struct {
	Name            string `json:"name" validate:"required,min=1,max=100"`
	StartingBalance int64  `json:"starting_balance_paisa"`
}

func (s *Service) Create(ctx context.Context, userID uuid.UUID, in CreateInput) (*Bucket, error) {
	row, err := sqlcdb.New(s.pool).CreateBucket(ctx, sqlcdb.CreateBucketParams{
		UserID:          userID,
		Name:            in.Name,
		StartingBalance: in.StartingBalance,
	})
	if err != nil {
		return nil, fmt.Errorf("create bucket: %w", err)
	}
	b := fromRow(row)
	return &b, nil
}

type UpdateInput struct {
	Name     *string `json:"name"`
	Archived *bool   `json:"archived"`
}

func (s *Service) Update(ctx context.Context, id, userID uuid.UUID, in UpdateInput) (*Bucket, error) {
	existing, err := s.Get(ctx, id, userID)
	if err != nil {
		return nil, err
	}

	name := existing.Name
	if in.Name != nil {
		name = *in.Name
	}

	var archivedAt pgtype.Timestamptz
	if existing.ArchivedAt != nil {
		archivedAt = pgtype.Timestamptz{Time: *existing.ArchivedAt, Valid: true}
	}
	if in.Archived != nil {
		if *in.Archived {
			now := time.Now().UTC()
			archivedAt = pgtype.Timestamptz{Time: now, Valid: true}
		} else {
			archivedAt = pgtype.Timestamptz{}
		}
	}

	row, err := sqlcdb.New(s.pool).UpdateBucket(ctx, sqlcdb.UpdateBucketParams{
		ID:         id,
		UserID:     userID,
		Name:       name,
		ArchivedAt: archivedAt,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apperror.NotFound("bucket not found")
		}
		return nil, fmt.Errorf("update bucket: %w", err)
	}
	b := fromRow(row)
	return &b, nil
}

func fromRow(r sqlcdb.Bucket) Bucket {
	b := Bucket{
		ID:              r.ID,
		UserID:          r.UserID,
		Name:            r.Name,
		StartingBalance: r.StartingBalance,
		CreatedAt:       r.CreatedAt.Time,
	}
	if r.ArchivedAt.Valid {
		t := r.ArchivedAt.Time
		b.ArchivedAt = &t
	}
	return b
}
