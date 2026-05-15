-- name: ListPeople :many
SELECT id, user_id, name, archived_at, created_at
FROM people
WHERE user_id = $1 AND archived_at IS NULL
ORDER BY created_at ASC;

-- name: GetPerson :one
SELECT id, user_id, name, archived_at, created_at
FROM people
WHERE id = $1 AND user_id = $2;

-- name: CreatePerson :one
INSERT INTO people (user_id, name)
VALUES ($1, $2)
RETURNING id, user_id, name, archived_at, created_at;

-- name: UpdatePerson :one
UPDATE people
SET name = $3, archived_at = $4
WHERE id = $1 AND user_id = $2
RETURNING id, user_id, name, archived_at, created_at;
