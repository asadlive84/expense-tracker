package transaction

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/asad/expense-tracker/internal/cache"
	sqlcdb "github.com/asad/expense-tracker/internal/db/sqlc"
	"github.com/asad/expense-tracker/internal/platform/apperror"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type TxType string

const (
	TypeExpense            TxType = "expense"
	TypeIncome             TxType = "income"
	TypeTransfer           TxType = "transfer"
	TypeLoanGiven          TxType = "loan_given"
	TypeLoanTaken          TxType = "loan_taken"
	TypeRepaymentReceived  TxType = "repayment_received"
	TypeRepaymentPaid      TxType = "repayment_paid"
)

var validTypes = map[TxType]bool{
	TypeExpense: true, TypeIncome: true, TypeTransfer: true,
	TypeLoanGiven: true, TypeLoanTaken: true,
	TypeRepaymentReceived: true, TypeRepaymentPaid: true,
}

type TagRef struct {
	ID   uuid.UUID `json:"id"`
	Name string    `json:"name"`
}

type Transaction struct {
	ID           uuid.UUID  `json:"id"`
	UserID       uuid.UUID  `json:"user_id"`
	Type         TxType     `json:"type"`
	AmountPaisa  int64      `json:"amount_paisa"`
	FromBucketID *uuid.UUID `json:"from_bucket_id"`
	ToBucketID   *uuid.UUID `json:"to_bucket_id"`
	PersonID     *uuid.UUID `json:"person_id"`
	Note         string     `json:"note"`
	OccurredAt   time.Time  `json:"occurred_at"`
	CreatedAt    time.Time  `json:"created_at"`
	ReversesID   *uuid.UUID `json:"reverses_id,omitempty"`
	Tags         []TagRef   `json:"tags"`
	Reversed     bool       `json:"reversed"`
}

type CreateInput struct {
	Type         TxType     `json:"type"         validate:"required"`
	AmountPaisa  int64      `json:"amount_paisa" validate:"required,gt=0"`
	FromBucketID *uuid.UUID `json:"from_bucket_id"`
	ToBucketID   *uuid.UUID `json:"to_bucket_id"`
	PersonID     *uuid.UUID `json:"person_id"`
	Note         string     `json:"note"`
	OccurredAt   time.Time  `json:"occurred_at"  validate:"required"`
	TagIDs       []uuid.UUID `json:"tag_ids"`
}

type ListFilter struct {
	Type     string
	BucketID uuid.UUID
	PersonID uuid.UUID
	TagID    uuid.UUID
	From     time.Time
	To       time.Time
	Limit    int32
	// cursor fields
	CursorTime time.Time
	CursorID   uuid.UUID
}

type ListResult struct {
	Items      []Transaction `json:"items"`
	NextCursor string        `json:"next_cursor"`
}

type cursorPayload struct {
	Time time.Time `json:"t"`
	ID   uuid.UUID `json:"i"`
}

type Service struct {
	pool  *pgxpool.Pool
	cache *cache.Cache
}

func NewService(pool *pgxpool.Pool, c *cache.Cache) *Service {
	return &Service{pool: pool, cache: c}
}

func (s *Service) invalidateCache(ctx context.Context, userID uuid.UUID) {
	uid := userID.String()
	s.cache.Del(ctx, cache.KeyBucketBalances(uid), cache.KeyPersonBalances(uid))
	s.cache.DelByPattern(ctx, cache.KeyTagTotalsPattern(uid))
	s.cache.DelByPattern(ctx, cache.KeySummaryPattern(uid))
}

func validateType(in CreateInput) error {
	if !validTypes[in.Type] {
		return apperror.ValidationError("invalid transaction type", map[string]string{
			"type": fmt.Sprintf("must be one of: expense, income, transfer, loan_given, loan_taken, repayment_received, repayment_paid"),
		})
	}

	fields := map[string]string{}

	switch in.Type {
	case TypeExpense:
		if in.FromBucketID == nil {
			fields["from_bucket_id"] = "required for expense"
		}
		if in.ToBucketID != nil {
			fields["to_bucket_id"] = "must be null for expense"
		}
	case TypeIncome:
		if in.ToBucketID == nil {
			fields["to_bucket_id"] = "required for income"
		}
		if in.FromBucketID != nil {
			fields["from_bucket_id"] = "must be null for income"
		}
	case TypeTransfer:
		if in.FromBucketID == nil {
			fields["from_bucket_id"] = "required for transfer"
		}
		if in.ToBucketID == nil {
			fields["to_bucket_id"] = "required for transfer"
		}
		if in.PersonID != nil {
			fields["person_id"] = "must be null for transfer"
		}
		if in.FromBucketID != nil && in.ToBucketID != nil && *in.FromBucketID == *in.ToBucketID {
			fields["to_bucket_id"] = "must differ from from_bucket_id"
		}
	case TypeLoanGiven:
		if in.FromBucketID == nil {
			fields["from_bucket_id"] = "required for loan_given"
		}
		if in.ToBucketID != nil {
			fields["to_bucket_id"] = "must be null for loan_given"
		}
		if in.PersonID == nil {
			fields["person_id"] = "required for loan_given"
		}
	case TypeLoanTaken:
		if in.ToBucketID == nil {
			fields["to_bucket_id"] = "required for loan_taken"
		}
		if in.FromBucketID != nil {
			fields["from_bucket_id"] = "must be null for loan_taken"
		}
		if in.PersonID == nil {
			fields["person_id"] = "required for loan_taken"
		}
	case TypeRepaymentReceived:
		if in.ToBucketID == nil {
			fields["to_bucket_id"] = "required for repayment_received"
		}
		if in.FromBucketID != nil {
			fields["from_bucket_id"] = "must be null for repayment_received"
		}
		if in.PersonID == nil {
			fields["person_id"] = "required for repayment_received"
		}
	case TypeRepaymentPaid:
		if in.FromBucketID == nil {
			fields["from_bucket_id"] = "required for repayment_paid"
		}
		if in.ToBucketID != nil {
			fields["to_bucket_id"] = "must be null for repayment_paid"
		}
		if in.PersonID == nil {
			fields["person_id"] = "required for repayment_paid"
		}
	}

	if len(fields) > 0 {
		return apperror.ValidationError("transaction field validation failed", fields)
	}
	return nil
}

func uuidToPtr(u pgtype.UUID) *uuid.UUID {
	if !u.Valid {
		return nil
	}
	id := uuid.UUID(u.Bytes)
	return &id
}

func ptrToUUID(id *uuid.UUID) pgtype.UUID {
	if id == nil {
		return pgtype.UUID{}
	}
	return pgtype.UUID{Bytes: *id, Valid: true}
}

func (s *Service) insertTx(ctx context.Context, q *sqlcdb.Queries, userID uuid.UUID, in CreateInput, reversesID *uuid.UUID) (sqlcdb.Transaction, error) {
	return q.CreateTransaction(ctx, sqlcdb.CreateTransactionParams{
		UserID:       userID,
		Type:         string(in.Type),
		Amount:       in.AmountPaisa,
		FromBucketID: ptrToUUID(in.FromBucketID),
		ToBucketID:   ptrToUUID(in.ToBucketID),
		PersonID:     ptrToUUID(in.PersonID),
		Note:         in.Note,
		OccurredAt:   pgtype.Timestamptz{Time: in.OccurredAt.UTC(), Valid: true},
		ReversesID:   ptrToUUID(reversesID),
	})
}

func (s *Service) attachTags(ctx context.Context, q *sqlcdb.Queries, txID uuid.UUID, tagIDs []uuid.UUID) ([]TagRef, error) {
	for _, tid := range tagIDs {
		if err := q.AddTransactionTag(ctx, sqlcdb.AddTransactionTagParams{
			TransactionID: txID,
			TagID:         tid,
		}); err != nil {
			return nil, fmt.Errorf("attach tag %s: %w", tid, err)
		}
	}
	rows, err := q.GetTransactionTags(ctx, txID)
	if err != nil {
		return nil, fmt.Errorf("get tags: %w", err)
	}
	tags := make([]TagRef, len(rows))
	for i, r := range rows {
		tags[i] = TagRef{ID: r.ID, Name: r.Name}
	}
	return tags, nil
}

func (s *Service) Create(ctx context.Context, userID uuid.UUID, in CreateInput) (*Transaction, error) {
	if err := validateType(in); err != nil {
		return nil, err
	}

	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{IsoLevel: pgx.ReadCommitted})
	if err != nil {
		return nil, fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	q := sqlcdb.New(tx)
	row, err := s.insertTx(ctx, q, userID, in, nil)
	if err != nil {
		return nil, fmt.Errorf("insert transaction: %w", err)
	}

	tags, err := s.attachTags(ctx, q, row.ID, in.TagIDs)
	if err != nil {
		return nil, err
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, fmt.Errorf("commit: %w", err)
	}

	s.invalidateCache(ctx, userID)
	return s.toTransaction(row, tags, false), nil
}

func (s *Service) Get(ctx context.Context, id, userID uuid.UUID) (*Transaction, error) {
	q := sqlcdb.New(s.pool)
	row, err := q.GetTransaction(ctx, sqlcdb.GetTransactionParams{ID: id, UserID: userID})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apperror.NotFound("transaction not found")
		}
		return nil, fmt.Errorf("get transaction: %w", err)
	}

	reversed, err := q.IsTransactionReversed(ctx, pgtype.UUID{Bytes: id, Valid: true})
	if err != nil {
		return nil, fmt.Errorf("check reversed: %w", err)
	}

	tags, err := q.GetTransactionTags(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("get tags: %w", err)
	}
	tagRefs := make([]TagRef, len(tags))
	for i, t := range tags {
		tagRefs[i] = TagRef{ID: t.ID, Name: t.Name}
	}

	return s.toTransaction(row, tagRefs, reversed), nil
}

func (s *Service) List(ctx context.Context, userID uuid.UUID, f ListFilter) (*ListResult, error) {
	if f.Limit <= 0 || f.Limit > 200 {
		f.Limit = 50
	}

	var fromTS, toTS, cursorTS pgtype.Timestamptz
	if !f.From.IsZero() {
		fromTS = pgtype.Timestamptz{Time: f.From.UTC(), Valid: true}
	}
	if !f.To.IsZero() {
		toTS = pgtype.Timestamptz{Time: f.To.UTC(), Valid: true}
	}
	if !f.CursorTime.IsZero() {
		cursorTS = pgtype.Timestamptz{Time: f.CursorTime.UTC(), Valid: true}
	}

	zeroUUID := uuid.UUID{}
	bucketID := f.BucketID
	if bucketID == zeroUUID {
		bucketID = zeroUUID
	}

	rows, err := sqlcdb.New(s.pool).ListTransactions(ctx, sqlcdb.ListTransactionsParams{
		UserID:  userID,
		Column2: f.Type,
		Column3: bucketID,
		Column4: f.PersonID,
		Column5: fromTS,
		Column6: toTS,
		Column7: f.TagID,
		Column8: cursorTS,
		Column9: f.CursorID,
		Limit:   f.Limit,
	})
	if err != nil {
		return nil, fmt.Errorf("list transactions: %w", err)
	}

	q := sqlcdb.New(s.pool)
	items := make([]Transaction, 0, len(rows))
	for _, row := range rows {
		tags, err := q.GetTransactionTags(ctx, row.ID)
		if err != nil {
			return nil, fmt.Errorf("get tags for %s: %w", row.ID, err)
		}
		tagRefs := make([]TagRef, len(tags))
		for i, t := range tags {
			tagRefs[i] = TagRef{ID: t.ID, Name: t.Name}
		}
		items = append(items, *s.toTransaction(row, tagRefs, false))
	}

	var nextCursor string
	if int32(len(items)) == f.Limit {
		last := items[len(items)-1]
		b, _ := json.Marshal(cursorPayload{Time: last.OccurredAt, ID: last.ID})
		nextCursor = base64.URLEncoding.EncodeToString(b)
	}

	return &ListResult{Items: items, NextCursor: nextCursor}, nil
}

func (s *Service) Update(ctx context.Context, id, userID uuid.UUID, in CreateInput) (*Transaction, error) {
	if err := validateType(in); err != nil {
		return nil, err
	}

	original, err := s.Get(ctx, id, userID)
	if err != nil {
		return nil, err
	}
	if original.Reversed {
		return nil, apperror.Conflict("transaction has already been reversed")
	}

	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{IsoLevel: pgx.ReadCommitted})
	if err != nil {
		return nil, fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	q := sqlcdb.New(tx)

	// Insert reversal of the original
	reversal := CreateInput{
		Type:         original.Type,
		AmountPaisa:  original.AmountPaisa,
		FromBucketID: original.FromBucketID,
		ToBucketID:   original.ToBucketID,
		PersonID:     original.PersonID,
		Note:         original.Note,
		OccurredAt:   original.OccurredAt,
	}
	if _, err := s.insertTx(ctx, q, userID, reversal, &id); err != nil {
		return nil, fmt.Errorf("insert reversal: %w", err)
	}

	// Insert the new corrected row
	newRow, err := s.insertTx(ctx, q, userID, in, nil)
	if err != nil {
		return nil, fmt.Errorf("insert new transaction: %w", err)
	}

	tags, err := s.attachTags(ctx, q, newRow.ID, in.TagIDs)
	if err != nil {
		return nil, err
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, fmt.Errorf("commit: %w", err)
	}

	s.invalidateCache(ctx, userID)
	return s.toTransaction(newRow, tags, false), nil
}

func (s *Service) Delete(ctx context.Context, id, userID uuid.UUID) error {
	original, err := s.Get(ctx, id, userID)
	if err != nil {
		return err
	}
	if original.Reversed {
		return apperror.Conflict("transaction has already been reversed")
	}

	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{IsoLevel: pgx.ReadCommitted})
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	reversal := CreateInput{
		Type:         original.Type,
		AmountPaisa:  original.AmountPaisa,
		FromBucketID: original.FromBucketID,
		ToBucketID:   original.ToBucketID,
		PersonID:     original.PersonID,
		Note:         original.Note,
		OccurredAt:   original.OccurredAt,
	}
	if _, err := s.insertTx(ctx, sqlcdb.New(tx), userID, reversal, &id); err != nil {
		return fmt.Errorf("insert reversal: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit: %w", err)
	}

	s.invalidateCache(ctx, userID)
	return nil
}

func (s *Service) toTransaction(row sqlcdb.Transaction, tags []TagRef, reversed bool) *Transaction {
	t := &Transaction{
		ID:          row.ID,
		UserID:      row.UserID,
		Type:        TxType(row.Type),
		AmountPaisa: row.Amount,
		Note:        row.Note,
		OccurredAt:  row.OccurredAt.Time,
		CreatedAt:   row.CreatedAt.Time,
		Tags:        tags,
		Reversed:    reversed,
	}
	t.FromBucketID = uuidToPtr(row.FromBucketID)
	t.ToBucketID = uuidToPtr(row.ToBucketID)
	t.PersonID = uuidToPtr(row.PersonID)
	t.ReversesID = uuidToPtr(row.ReversesID)
	return t
}

func DecodeCursor(cursor string) (time.Time, uuid.UUID, error) {
	if cursor == "" {
		return time.Time{}, uuid.UUID{}, nil
	}
	b, err := base64.URLEncoding.DecodeString(cursor)
	if err != nil {
		return time.Time{}, uuid.UUID{}, fmt.Errorf("decode cursor: %w", err)
	}
	var p cursorPayload
	if err := json.Unmarshal(b, &p); err != nil {
		return time.Time{}, uuid.UUID{}, fmt.Errorf("unmarshal cursor: %w", err)
	}
	return p.Time, p.ID, nil
}
