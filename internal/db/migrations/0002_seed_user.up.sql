-- Seed user is inserted at application startup via Go, not raw SQL,
-- to allow bcrypt hashing of the plaintext password from env vars.
-- This migration is intentionally a no-op placeholder.
SELECT 1;
