-- name: GetUserByEmail :one
SELECT id, email, password_hash, name, phone, default_bucket_id, created_at
FROM users
WHERE email = $1;

-- name: CreateUser :one
INSERT INTO users (email, password_hash)
VALUES ($1, $2)
RETURNING id, email, password_hash, name, phone, default_bucket_id, created_at;

-- name: GetUserByID :one
SELECT id, email, password_hash, name, phone, default_bucket_id, created_at
FROM users
WHERE id = $1;

-- name: UpdateUserProfile :one
UPDATE users
SET name  = COALESCE($2, name),
    phone = COALESCE($3, phone)
WHERE id = $1
RETURNING id, email, password_hash, name, phone, default_bucket_id, created_at;

-- name: SetUserDefaultBucket :one
UPDATE users
SET default_bucket_id = $2
WHERE id = $1
RETURNING id, email, name, phone, default_bucket_id, created_at;

-- name: ClearUserDefaultBucket :one
UPDATE users
SET default_bucket_id = NULL
WHERE id = $1
RETURNING id, email, name, phone, default_bucket_id, created_at;
