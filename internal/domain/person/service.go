package person

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

type Person struct {
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

func (s *Service) List(ctx context.Context, userID uuid.UUID) ([]Person, error) {
	rows, err := sqlcdb.New(s.pool).ListPeople(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("list people: %w", err)
	}
	out := make([]Person, len(rows))
	for i, r := range rows {
		out[i] = fromRow(r)
	}
	return out, nil
}

func (s *Service) Get(ctx context.Context, id, userID uuid.UUID) (*Person, error) {
	row, err := sqlcdb.New(s.pool).GetPerson(ctx, sqlcdb.GetPersonParams{ID: id, UserID: userID})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apperror.NotFound("person not found")
		}
		return nil, fmt.Errorf("get person: %w", err)
	}
	p := fromRow(row)
	return &p, nil
}

type CreateInput struct {
	Name string `json:"name" validate:"required,min=1,max=100"`
}

func (s *Service) Create(ctx context.Context, userID uuid.UUID, in CreateInput) (*Person, error) {
	row, err := sqlcdb.New(s.pool).CreatePerson(ctx, sqlcdb.CreatePersonParams{
		UserID: userID,
		Name:   in.Name,
	})
	if err != nil {
		return nil, fmt.Errorf("create person: %w", err)
	}
	p := fromRow(row)
	return &p, nil
}

type UpdateInput struct {
	Name     *string `json:"name"`
	Archived *bool   `json:"archived"`
}

func (s *Service) Update(ctx context.Context, id, userID uuid.UUID, in UpdateInput) (*Person, error) {
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

	row, err := sqlcdb.New(s.pool).UpdatePerson(ctx, sqlcdb.UpdatePersonParams{
		ID:         id,
		UserID:     userID,
		Name:       name,
		ArchivedAt: archivedAt,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apperror.NotFound("person not found")
		}
		return nil, fmt.Errorf("update person: %w", err)
	}
	p := fromRow(row)
	return &p, nil
}

func fromRow(r sqlcdb.Person) Person {
	p := Person{
		ID:        r.ID,
		UserID:    r.UserID,
		Name:      r.Name,
		CreatedAt: r.CreatedAt.Time,
	}
	if r.ArchivedAt.Valid {
		t := r.ArchivedAt.Time
		p.ArchivedAt = &t
	}
	return p
}
