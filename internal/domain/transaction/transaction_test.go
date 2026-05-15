package transaction_test

import (
	"context"
	"testing"
	"time"

	appdb "github.com/asad/expense-tracker/internal/db"
	"github.com/asad/expense-tracker/internal/domain/transaction"
	"github.com/asad/expense-tracker/internal/testutil"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func seedUser(t *testing.T, db *testutil.TestDB) uuid.UUID {
	t.Helper()
	ctx := context.Background()
	err := appdb.SeedUser(ctx, db.Pool, "test@example.com", "password123")
	require.NoError(t, err)

	var id uuid.UUID
	err = db.Pool.QueryRow(ctx, "SELECT id FROM users WHERE email=$1", "test@example.com").Scan(&id)
	require.NoError(t, err)
	return id
}

func seedBucket(t *testing.T, db *testutil.TestDB, userID uuid.UUID, name string) uuid.UUID {
	t.Helper()
	var id uuid.UUID
	err := db.Pool.QueryRow(context.Background(),
		"INSERT INTO buckets (user_id, name) VALUES ($1, $2) RETURNING id",
		userID, name).Scan(&id)
	require.NoError(t, err)
	return id
}

func seedPerson(t *testing.T, db *testutil.TestDB, userID uuid.UUID, name string) uuid.UUID {
	t.Helper()
	var id uuid.UUID
	err := db.Pool.QueryRow(context.Background(),
		"INSERT INTO people (user_id, name) VALUES ($1, $2) RETURNING id",
		userID, name).Scan(&id)
	require.NoError(t, err)
	return id
}

func TestTransaction_CreateExpense(t *testing.T) {
	db := testutil.NewTestDB(t)
	svc := transaction.NewService(db.Pool, db.Cache)
	ctx := context.Background()

	userID := seedUser(t, db)
	bucketID := seedBucket(t, db, userID, "Cash")

	tx, err := svc.Create(ctx, userID, transaction.CreateInput{
		Type:         transaction.TypeExpense,
		AmountPaisa:  5000,
		FromBucketID: &bucketID,
		Note:         "Lunch",
		OccurredAt:   time.Now(),
	})
	require.NoError(t, err)
	assert.Equal(t, transaction.TypeExpense, tx.Type)
	assert.Equal(t, int64(5000), tx.AmountPaisa)
	assert.Equal(t, &bucketID, tx.FromBucketID)
	assert.Nil(t, tx.ToBucketID)
}

func TestTransaction_ValidationRules(t *testing.T) {
	db := testutil.NewTestDB(t)
	svc := transaction.NewService(db.Pool, db.Cache)
	ctx := context.Background()

	userID := seedUser(t, db)
	bucketID := seedBucket(t, db, userID, "Cash")
	personID := seedPerson(t, db, userID, "Karim")

	tests := []struct {
		name    string
		input   transaction.CreateInput
		wantErr bool
	}{
		{
			name: "expense requires from_bucket",
			input: transaction.CreateInput{
				Type: transaction.TypeExpense, AmountPaisa: 100,
				OccurredAt: time.Now(),
			},
			wantErr: true,
		},
		{
			name: "income requires to_bucket",
			input: transaction.CreateInput{
				Type: transaction.TypeIncome, AmountPaisa: 100,
				OccurredAt: time.Now(),
			},
			wantErr: true,
		},
		{
			name: "transfer requires both buckets",
			input: transaction.CreateInput{
				Type: transaction.TypeTransfer, AmountPaisa: 100,
				FromBucketID: &bucketID,
				OccurredAt:   time.Now(),
			},
			wantErr: true,
		},
		{
			name: "transfer same bucket rejected",
			input: transaction.CreateInput{
				Type: transaction.TypeTransfer, AmountPaisa: 100,
				FromBucketID: &bucketID, ToBucketID: &bucketID,
				OccurredAt: time.Now(),
			},
			wantErr: true,
		},
		{
			name: "loan_given requires person",
			input: transaction.CreateInput{
				Type: transaction.TypeLoanGiven, AmountPaisa: 100,
				FromBucketID: &bucketID,
				OccurredAt:   time.Now(),
			},
			wantErr: true,
		},
		{
			name: "valid loan_given",
			input: transaction.CreateInput{
				Type: transaction.TypeLoanGiven, AmountPaisa: 100,
				FromBucketID: &bucketID, PersonID: &personID,
				OccurredAt: time.Now(),
			},
			wantErr: false,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			_, err := svc.Create(ctx, userID, tc.input)
			if tc.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestTransaction_UpdateCreatesReversal(t *testing.T) {
	db := testutil.NewTestDB(t)
	svc := transaction.NewService(db.Pool, db.Cache)
	ctx := context.Background()

	userID := seedUser(t, db)
	bucketID := seedBucket(t, db, userID, "Cash")

	original, err := svc.Create(ctx, userID, transaction.CreateInput{
		Type: transaction.TypeExpense, AmountPaisa: 1000,
		FromBucketID: &bucketID, Note: "Original",
		OccurredAt: time.Now(),
	})
	require.NoError(t, err)

	updated, err := svc.Update(ctx, original.ID, userID, transaction.CreateInput{
		Type: transaction.TypeExpense, AmountPaisa: 2000,
		FromBucketID: &bucketID, Note: "Corrected",
		OccurredAt: time.Now(),
	})
	require.NoError(t, err)
	assert.Equal(t, int64(2000), updated.AmountPaisa)
	assert.NotEqual(t, original.ID, updated.ID)

	// Verify original doesn't appear in list (it's been reversed)
	result, err := svc.List(ctx, userID, transaction.ListFilter{Limit: 50})
	require.NoError(t, err)
	for _, tx := range result.Items {
		assert.NotEqual(t, original.ID, tx.ID, "original should not appear in list")
	}

	// Verify DB has 3 rows: original + reversal + new
	var count int
	err = db.Pool.QueryRow(ctx, "SELECT COUNT(*) FROM transactions WHERE user_id=$1", userID).Scan(&count)
	require.NoError(t, err)
	assert.Equal(t, 3, count)
}

func TestTransaction_DeleteCreatesReversal(t *testing.T) {
	db := testutil.NewTestDB(t)
	svc := transaction.NewService(db.Pool, db.Cache)
	ctx := context.Background()

	userID := seedUser(t, db)
	bucketID := seedBucket(t, db, userID, "Cash")

	tx, err := svc.Create(ctx, userID, transaction.CreateInput{
		Type: transaction.TypeExpense, AmountPaisa: 500,
		FromBucketID: &bucketID, OccurredAt: time.Now(),
	})
	require.NoError(t, err)

	err = svc.Delete(ctx, tx.ID, userID)
	require.NoError(t, err)

	result, err := svc.List(ctx, userID, transaction.ListFilter{Limit: 50})
	require.NoError(t, err)
	assert.Empty(t, result.Items, "deleted transaction should not appear in list")

	// DB has 2 rows: original + reversal
	var count int
	err = db.Pool.QueryRow(ctx, "SELECT COUNT(*) FROM transactions WHERE user_id=$1", userID).Scan(&count)
	require.NoError(t, err)
	assert.Equal(t, 2, count)
}
