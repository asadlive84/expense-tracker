package tag

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

type Tag struct {
	ID         uuid.UUID  `json:"id"`
	UserID     uuid.UUID  `json:"user_id"`
	Name       string     `json:"name"`
	ArchivedAt *time.Time `json:"archived_at,omitempty"`
	CreatedAt  time.Time  `json:"created_at"`
}

type Service struct {
	pool *pgxpool.Pool
}

func NewService(pool *pgxpool.Pool) *Service {
	return &Service{pool: pool}
}

func (s *Service) List(ctx context.Context, userID uuid.UUID) ([]Tag, error) {
	rows, err := sqlcdb.New(s.pool).ListTags(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("list tags: %w", err)
	}
	out := make([]Tag, len(rows))
	for i, r := range rows {
		out[i] = fromRow(r)
	}
	return out, nil
}

func (s *Service) Get(ctx context.Context, id, userID uuid.UUID) (*Tag, error) {
	row, err := sqlcdb.New(s.pool).GetTag(ctx, sqlcdb.GetTagParams{ID: id, UserID: userID})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apperror.NotFound("tag not found")
		}
		return nil, fmt.Errorf("get tag: %w", err)
	}
	t := fromRow(row)
	return &t, nil
}

type CreateInput struct {
	Name string `json:"name" validate:"required,min=1,max=50"`
}

func (s *Service) Create(ctx context.Context, userID uuid.UUID, in CreateInput) (*Tag, error) {
	row, err := sqlcdb.New(s.pool).CreateTag(ctx, sqlcdb.CreateTagParams{
		UserID: userID,
		Name:   in.Name,
	})
	if err != nil {
		return nil, fmt.Errorf("create tag: %w", err)
	}
	t := fromRow(row)
	return &t, nil
}

type UpdateInput struct {
	Name     *string `json:"name"`
	Archived *bool   `json:"archived"`
}

func (s *Service) Update(ctx context.Context, id, userID uuid.UUID, in UpdateInput) (*Tag, error) {
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

	row, err := sqlcdb.New(s.pool).UpdateTag(ctx, sqlcdb.UpdateTagParams{
		ID:         id,
		UserID:     userID,
		Name:       name,
		ArchivedAt: archivedAt,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apperror.NotFound("tag not found")
		}
		return nil, fmt.Errorf("update tag: %w", err)
	}
	t := fromRow(row)
	return &t, nil
}

// Delete permanently removes a tag. The junction rows in transaction_tags are
// cascade-deleted by the DB, so linked transactions remain intact as untagged.
func (s *Service) Delete(ctx context.Context, id, userID uuid.UUID) error {
	return sqlcdb.New(s.pool).DeleteTag(ctx, sqlcdb.DeleteTagParams{
		ID:     id,
		UserID: userID,
	})
}

func fromRow(r sqlcdb.Tag) Tag {
	t := Tag{
		ID:        r.ID,
		UserID:    r.UserID,
		Name:      r.Name,
		CreatedAt: r.CreatedAt.Time,
	}
	if r.ArchivedAt.Valid {
		at := r.ArchivedAt.Time
		t.ArchivedAt = &at
	}
	return t
}
