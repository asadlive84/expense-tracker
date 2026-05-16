-- name: ListTags :many
SELECT t.id, t.user_id, t.name, t.archived_at, t.created_at
FROM tags t
WHERE t.user_id = $1 AND t.archived_at IS NULL
ORDER BY (
    SELECT MAX(tx.created_at)
    FROM transaction_tags tt
    JOIN transactions tx ON tx.id = tt.transaction_id
    WHERE tt.tag_id = t.id
) DESC NULLS LAST, t.created_at ASC;

-- name: GetTag :one
SELECT id, user_id, name, archived_at, created_at
FROM tags
WHERE id = $1 AND user_id = $2;

-- name: CreateTag :one
INSERT INTO tags (user_id, name)
VALUES ($1, $2)
RETURNING id, user_id, name, archived_at, created_at;

-- name: UpdateTag :one
UPDATE tags
SET name = $3, archived_at = $4
WHERE id = $1 AND user_id = $2
RETURNING id, user_id, name, archived_at, created_at;

-- name: GetTagByName :one
SELECT id, user_id, name, archived_at, created_at
FROM tags
WHERE user_id = $1 AND LOWER(name) = LOWER($2);

-- name: DeleteTag :exec
DELETE FROM tags WHERE id = $1 AND user_id = $2;
