package reminder

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/asad/expense-tracker/internal/domain/transaction"
	sqlcdb "github.com/asad/expense-tracker/internal/db/sqlc"
	"github.com/asad/expense-tracker/internal/platform/apperror"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Reminder struct {
	ID             uuid.UUID  `json:"id"`
	UserID         uuid.UUID  `json:"user_id"`
	Title          string     `json:"title"`
	AmountPaisa    *int64     `json:"amount_paisa,omitempty"`
	DefaultType    string     `json:"default_type"`
	RecurrenceType string     `json:"recurrence_type"`
	RecurrenceDay  *int32     `json:"recurrence_day,omitempty"`
	NextDueAt      time.Time  `json:"next_due_at"`
	LinkedBucketID *uuid.UUID `json:"linked_bucket_id,omitempty"`
	LinkedPersonID *uuid.UUID `json:"linked_person_id,omitempty"`
	Status         string     `json:"status"`
	CreatedAt      time.Time  `json:"created_at"`
}

type CreateInput struct {
	Title          string     `json:"title"           validate:"required,min=1,max=200"`
	AmountPaisa    *int64     `json:"amount_paisa"`
	DefaultType    string     `json:"default_type"    validate:"required"`
	RecurrenceType string     `json:"recurrence_type" validate:"required,oneof=none weekly monthly yearly"`
	RecurrenceDay  *int32     `json:"recurrence_day"`
	NextDueAt      time.Time  `json:"next_due_at"     validate:"required"`
	LinkedBucketID *uuid.UUID `json:"linked_bucket_id"`
	LinkedPersonID *uuid.UUID `json:"linked_person_id"`
	TagIDs         []uuid.UUID `json:"tag_ids"`
}

type UpdateInput struct {
	Title          *string    `json:"title"`
	AmountPaisa    *int64     `json:"amount_paisa"`
	DefaultType    *string    `json:"default_type"`
	RecurrenceType *string    `json:"recurrence_type"`
	RecurrenceDay  *int32     `json:"recurrence_day"`
	NextDueAt      *time.Time `json:"next_due_at"`
	LinkedBucketID *uuid.UUID `json:"linked_bucket_id"`
	LinkedPersonID *uuid.UUID `json:"linked_person_id"`
	Status         *string    `json:"status"`
	TagIDs         []uuid.UUID `json:"tag_ids"`
}

type PayInput struct {
	AmountPaisa *int64     `json:"amount_paisa"`
	OccurredAt  *time.Time `json:"occurred_at"`
	Note        string     `json:"note"`
}

type PayResult struct {
	Reminder    *Reminder             `json:"reminder"`
	Transaction *transaction.Transaction `json:"transaction"`
}

type Service struct {
	pool    *pgxpool.Pool
	txSvc   *transaction.Service
}

func NewService(pool *pgxpool.Pool, txSvc *transaction.Service) *Service {
	return &Service{pool: pool, txSvc: txSvc}
}

func (s *Service) Create(ctx context.Context, userID uuid.UUID, in CreateInput) (*Reminder, error) {
	q := sqlcdb.New(s.pool)

	var amount *int64
	if in.AmountPaisa != nil && *in.AmountPaisa > 0 {
		amount = in.AmountPaisa
	}

	row, err := q.CreateReminder(ctx, sqlcdb.CreateReminderParams{
		UserID:          userID,
		Title:           in.Title,
		Amount:          amount,
		DefaultType:     in.DefaultType,
		RecurrenceType:  in.RecurrenceType,
		RecurrenceDay:   in.RecurrenceDay,
		NextDueAt:       pgtype.Timestamptz{Time: in.NextDueAt.UTC(), Valid: true},
		LinkedBucketID:  uuidToNullable(in.LinkedBucketID),
		LinkedPersonID:  uuidToNullable(in.LinkedPersonID),
	})
	if err != nil {
		return nil, fmt.Errorf("create reminder: %w", err)
	}

	for _, tid := range in.TagIDs {
		_ = q.AddReminderTag(ctx, sqlcdb.AddReminderTagParams{ReminderID: row.ID, TagID: tid})
	}

	r := fromRow(row)
	return &r, nil
}

func (s *Service) Get(ctx context.Context, id, userID uuid.UUID) (*Reminder, error) {
	row, err := sqlcdb.New(s.pool).GetReminder(ctx, sqlcdb.GetReminderParams{ID: id, UserID: userID})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apperror.NotFound("reminder not found")
		}
		return nil, fmt.Errorf("get reminder: %w", err)
	}
	r := fromRow(row)
	return &r, nil
}

func (s *Service) List(ctx context.Context, userID uuid.UUID, dueBefore *time.Time) ([]Reminder, error) {
	var dueBeforeTS pgtype.Timestamptz
	if dueBefore != nil {
		dueBeforeTS = pgtype.Timestamptz{Time: dueBefore.UTC(), Valid: true}
	}
	rows, err := sqlcdb.New(s.pool).ListReminders(ctx, sqlcdb.ListRemindersParams{
		UserID:  userID,
		Column2: dueBeforeTS,
	})
	if err != nil {
		return nil, fmt.Errorf("list reminders: %w", err)
	}
	out := make([]Reminder, len(rows))
	for i, r := range rows {
		out[i] = fromRow(r)
	}
	return out, nil
}

func (s *Service) Update(ctx context.Context, id, userID uuid.UUID, in UpdateInput) (*Reminder, error) {
	existing, err := s.Get(ctx, id, userID)
	if err != nil {
		return nil, err
	}

	title := existing.Title
	if in.Title != nil {
		title = *in.Title
	}
	amount := existing.AmountPaisa
	if in.AmountPaisa != nil {
		amount = in.AmountPaisa
	}
	defaultType := existing.DefaultType
	if in.DefaultType != nil {
		defaultType = *in.DefaultType
	}
	recurrenceType := existing.RecurrenceType
	if in.RecurrenceType != nil {
		recurrenceType = *in.RecurrenceType
	}
	recurrenceDay := existing.RecurrenceDay
	if in.RecurrenceDay != nil {
		recurrenceDay = in.RecurrenceDay
	}
	nextDueAt := existing.NextDueAt
	if in.NextDueAt != nil {
		nextDueAt = *in.NextDueAt
	}
	linkedBucket := existing.LinkedBucketID
	if in.LinkedBucketID != nil {
		linkedBucket = in.LinkedBucketID
	}
	linkedPerson := existing.LinkedPersonID
	if in.LinkedPersonID != nil {
		linkedPerson = in.LinkedPersonID
	}
	status := existing.Status
	if in.Status != nil {
		status = *in.Status
	}

	q := sqlcdb.New(s.pool)
	row, err := q.UpdateReminder(ctx, sqlcdb.UpdateReminderParams{
		ID:             id,
		UserID:         userID,
		Title:          title,
		Amount:         amount,
		DefaultType:    defaultType,
		RecurrenceType: recurrenceType,
		RecurrenceDay:  recurrenceDay,
		NextDueAt:      pgtype.Timestamptz{Time: nextDueAt.UTC(), Valid: true},
		LinkedBucketID: uuidToNullable(linkedBucket),
		LinkedPersonID: uuidToNullable(linkedPerson),
		Status:         status,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apperror.NotFound("reminder not found")
		}
		return nil, fmt.Errorf("update reminder: %w", err)
	}

	if in.TagIDs != nil {
		_ = q.DeleteReminderTags(ctx, id)
		for _, tid := range in.TagIDs {
			_ = q.AddReminderTag(ctx, sqlcdb.AddReminderTagParams{ReminderID: id, TagID: tid})
		}
	}

	r := fromRow(row)
	return &r, nil
}

func (s *Service) Pay(ctx context.Context, id, userID uuid.UUID, in PayInput) (*PayResult, error) {
	rem, err := s.Get(ctx, id, userID)
	if err != nil {
		return nil, err
	}

	amount := rem.AmountPaisa
	if in.AmountPaisa != nil {
		amount = in.AmountPaisa
	}
	if amount == nil || *amount <= 0 {
		return nil, apperror.ValidationError("amount required to pay reminder", map[string]string{
			"amount_paisa": "must be provided (either on reminder or in pay request)",
		})
	}

	occurredAt := time.Now().UTC()
	if in.OccurredAt != nil {
		occurredAt = *in.OccurredAt
	}

	var fromBucket, toBucket *uuid.UUID
	txType := transaction.TxType(rem.DefaultType)
	switch txType {
	case transaction.TypeExpense, transaction.TypeLoanGiven, transaction.TypeRepaymentPaid:
		fromBucket = rem.LinkedBucketID
	case transaction.TypeIncome, transaction.TypeLoanTaken, transaction.TypeRepaymentReceived:
		toBucket = rem.LinkedBucketID
	}

	txInput := transaction.CreateInput{
		Type:         txType,
		AmountPaisa:  *amount,
		FromBucketID: fromBucket,
		ToBucketID:   toBucket,
		PersonID:     rem.LinkedPersonID,
		Note:         in.Note,
		OccurredAt:   occurredAt,
	}

	tx, err := s.txSvc.Create(ctx, userID, txInput)
	if err != nil {
		return nil, fmt.Errorf("create transaction: %w", err)
	}

	nextDue := AdvanceDueDate(rem.NextDueAt, rem.RecurrenceType, rem.RecurrenceDay)
	status := "active"
	if rem.RecurrenceType == "none" {
		status = "completed"
	}

	updated, err := s.Update(ctx, id, userID, UpdateInput{
		NextDueAt: &nextDue,
		Status:    &status,
	})
	if err != nil {
		return nil, fmt.Errorf("advance reminder: %w", err)
	}

	return &PayResult{Reminder: updated, Transaction: tx}, nil
}

func (s *Service) Skip(ctx context.Context, id, userID uuid.UUID) (*Reminder, error) {
	rem, err := s.Get(ctx, id, userID)
	if err != nil {
		return nil, err
	}

	nextDue := AdvanceDueDate(rem.NextDueAt, rem.RecurrenceType, rem.RecurrenceDay)
	status := "active"
	if rem.RecurrenceType == "none" {
		status = "completed"
	}

	return s.Update(ctx, id, userID, UpdateInput{
		NextDueAt: &nextDue,
		Status:    &status,
	})
}

func AdvanceDueDate(current time.Time, recurrenceType string, recurrenceDay *int32) time.Time {
	switch recurrenceType {
	case "weekly":
		return current.AddDate(0, 0, 7)
	case "monthly":
		nextYear, nextMonth := current.Year(), current.Month()+1
		if nextMonth > 12 {
			nextMonth = 1
			nextYear++
		}
		day := current.Day()
		if recurrenceDay != nil {
			day = int(*recurrenceDay)
		}
		lastDay := lastDayOfMonth(nextYear, nextMonth)
		if day > lastDay {
			day = lastDay
		}
		return time.Date(nextYear, nextMonth, day, current.Hour(), current.Minute(), 0, 0, time.UTC)
	case "yearly":
		return current.AddDate(1, 0, 0)
	default:
		return current
	}
}

func lastDayOfMonth(year int, month time.Month) int {
	return time.Date(year, month+1, 0, 0, 0, 0, 0, time.UTC).Day()
}

func uuidToNullable(id *uuid.UUID) pgtype.UUID {
	if id == nil {
		return pgtype.UUID{}
	}
	return pgtype.UUID{Bytes: *id, Valid: true}
}

func fromRow(r sqlcdb.Reminder) Reminder {
	rem := Reminder{
		ID:             r.ID,
		UserID:         r.UserID,
		Title:          r.Title,
		AmountPaisa:    r.Amount,
		DefaultType:    r.DefaultType,
		RecurrenceType: r.RecurrenceType,
		RecurrenceDay:  r.RecurrenceDay,
		NextDueAt:      r.NextDueAt.Time,
		Status:         r.Status,
		CreatedAt:      r.CreatedAt.Time,
	}
	if r.LinkedBucketID.Valid {
		id := uuid.UUID(r.LinkedBucketID.Bytes)
		rem.LinkedBucketID = &id
	}
	if r.LinkedPersonID.Valid {
		id := uuid.UUID(r.LinkedPersonID.Bytes)
		rem.LinkedPersonID = &id
	}
	return rem
}
