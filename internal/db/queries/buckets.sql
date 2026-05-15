-- name: ListBuckets :many
SELECT id, user_id, name, starting_balance, archived_at, created_at
FROM buckets
WHERE user_id = $1 AND archived_at IS NULL
ORDER BY created_at ASC;

-- name: GetBucket :one
SELECT id, user_id, name, starting_balance, archived_at, created_at
FROM buckets
WHERE id = $1 AND user_id = $2;

-- name: CreateBucket :one
INSERT INTO buckets (user_id, name, starting_balance)
VALUES ($1, $2, $3)
RETURNING id, user_id, name, starting_balance, archived_at, created_at;

-- name: UpdateBucket :one
UPDATE buckets
SET name = $3, archived_at = $4
WHERE id = $1 AND user_id = $2
RETURNING id, user_id, name, starting_balance, archived_at, created_at;
