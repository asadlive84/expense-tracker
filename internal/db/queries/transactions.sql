-- name: CreateTransaction :one
INSERT INTO transactions (
    user_id, type, amount, from_bucket_id, to_bucket_id,
    person_id, note, occurred_at, reverses_id
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
RETURNING id, user_id, type, amount, from_bucket_id, to_bucket_id,
          person_id, note, occurred_at, created_at, reverses_id;

-- name: GetTransaction :one
SELECT id, user_id, type, amount, from_bucket_id, to_bucket_id,
       person_id, note, occurred_at, created_at, reverses_id
FROM transactions
WHERE id = $1 AND user_id = $2;

-- name: ListTransactions :many
SELECT t.id, t.user_id, t.type, t.amount, t.from_bucket_id, t.to_bucket_id,
       t.person_id, t.note, t.occurred_at, t.created_at, t.reverses_id
FROM transactions t
WHERE t.user_id = $1
  AND NOT EXISTS (
      SELECT 1 FROM transactions r WHERE r.reverses_id = t.id
  )
  AND t.reverses_id IS NULL
  AND ($2 = '' OR t.type = $2)
  AND ($3 = '00000000-0000-0000-0000-000000000000'::uuid OR t.from_bucket_id = $3 OR t.to_bucket_id = $3)
  AND ($4 = '00000000-0000-0000-0000-000000000000'::uuid OR t.person_id = $4)
  AND ($5::timestamptz IS NULL OR t.occurred_at >= $5)
  AND ($6::timestamptz IS NULL OR t.occurred_at <= $6)
  AND (
      $7 = '00000000-0000-0000-0000-000000000000'::uuid OR
      EXISTS (
          SELECT 1 FROM transaction_tags tt WHERE tt.transaction_id = t.id AND tt.tag_id = $7
      )
  )
  AND ($8::timestamptz IS NULL OR $9 = '00000000-0000-0000-0000-000000000000'::uuid OR (t.occurred_at, t.id) < ($8, $9))
ORDER BY t.occurred_at DESC, t.id DESC
LIMIT $10;

-- name: AddTransactionTag :exec
INSERT INTO transaction_tags (transaction_id, tag_id)
VALUES ($1, $2)
ON CONFLICT DO NOTHING;

-- name: GetTransactionTags :many
SELECT tg.id, tg.user_id, tg.name, tg.archived_at, tg.created_at
FROM tags tg
JOIN transaction_tags tt ON tt.tag_id = tg.id
WHERE tt.transaction_id = $1;

-- name: IsTransactionReversed :one
SELECT EXISTS (
    SELECT 1 FROM transactions WHERE reverses_id = $1
) AS reversed;

-- name: BucketBalances :many
SELECT
    b.id AS bucket_id,
    b.name,
    CAST(b.starting_balance + COALESCE(
        SUM(CASE
            WHEN t.to_bucket_id = b.id THEN t.amount
            WHEN t.from_bucket_id = b.id THEN -t.amount
            ELSE 0
        END) FILTER (WHERE t.reverses_id IS NULL AND NOT EXISTS (
            SELECT 1 FROM transactions r WHERE r.reverses_id = t.id
        )),
    0) AS BIGINT) AS balance_paisa
FROM buckets b
LEFT JOIN transactions t ON (t.from_bucket_id = b.id OR t.to_bucket_id = b.id)
    AND t.user_id = $1
WHERE b.user_id = $1 AND b.archived_at IS NULL
GROUP BY b.id, b.name, b.starting_balance
ORDER BY b.created_at ASC;

-- name: PersonBalances :many
SELECT
    p.id AS person_id,
    p.name,
    CAST(COALESCE(
        SUM(CASE
            WHEN t.type IN ('loan_given', 'repayment_received') THEN t.amount
            WHEN t.type IN ('loan_taken', 'repayment_paid') THEN -t.amount
            ELSE 0
        END) FILTER (WHERE t.reverses_id IS NULL AND NOT EXISTS (
            SELECT 1 FROM transactions r WHERE r.reverses_id = t.id
        )),
    0) AS BIGINT) AS net_paisa
FROM people p
LEFT JOIN transactions t ON t.person_id = p.id AND t.user_id = $1
WHERE p.user_id = $1 AND p.archived_at IS NULL
GROUP BY p.id, p.name
ORDER BY p.created_at ASC;

-- name: TagTotals :many
SELECT
    tg.id AS tag_id,
    tg.name,
    CAST(COALESCE(
        SUM(t.amount) FILTER (WHERE t.reverses_id IS NULL AND NOT EXISTS (
            SELECT 1 FROM transactions r WHERE r.reverses_id = t.id
        )),
    0) AS BIGINT) AS total_paisa
FROM tags tg
JOIN transaction_tags tt ON tt.tag_id = tg.id
JOIN transactions t ON t.id = tt.transaction_id
    AND t.user_id = $1
    AND t.occurred_at >= $2
    AND t.occurred_at <= $3
    AND t.type = 'expense'
WHERE tg.user_id = $1 AND tg.archived_at IS NULL
GROUP BY tg.id, tg.name
ORDER BY total_paisa DESC;

-- name: MonthlySummary :one
SELECT
    CAST(COALESCE(SUM(t.amount) FILTER (WHERE t.type = 'income'), 0) AS BIGINT) AS total_income,
    CAST(COALESCE(SUM(t.amount) FILTER (WHERE t.type = 'expense'), 0) AS BIGINT) AS total_expense
FROM transactions t
WHERE t.user_id = $1
  AND t.occurred_at >= $2
  AND t.occurred_at < $3
  AND t.reverses_id IS NULL
  AND NOT EXISTS (SELECT 1 FROM transactions r WHERE r.reverses_id = t.id);
