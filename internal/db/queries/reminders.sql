-- name: CreateReminder :one
INSERT INTO reminders (
    user_id, title, amount, default_type, recurrence_type, recurrence_day,
    next_due_at, linked_bucket_id, linked_person_id, status
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 'active')
RETURNING id, user_id, title, amount, default_type, recurrence_type, recurrence_day,
          next_due_at, linked_bucket_id, linked_person_id, status, created_at;

-- name: GetReminder :one
SELECT id, user_id, title, amount, default_type, recurrence_type, recurrence_day,
       next_due_at, linked_bucket_id, linked_person_id, status, created_at
FROM reminders
WHERE id = $1 AND user_id = $2;

-- name: ListReminders :many
SELECT id, user_id, title, amount, default_type, recurrence_type, recurrence_day,
       next_due_at, linked_bucket_id, linked_person_id, status, created_at
FROM reminders
WHERE user_id = $1
  AND status = 'active'
  AND ($2::timestamptz IS NULL OR next_due_at <= $2)
ORDER BY next_due_at ASC;

-- name: UpdateReminder :one
UPDATE reminders
SET title = $3,
    amount = $4,
    default_type = $5,
    recurrence_type = $6,
    recurrence_day = $7,
    next_due_at = $8,
    linked_bucket_id = $9,
    linked_person_id = $10,
    status = $11
WHERE id = $1 AND user_id = $2
RETURNING id, user_id, title, amount, default_type, recurrence_type, recurrence_day,
          next_due_at, linked_bucket_id, linked_person_id, status, created_at;

-- name: AddReminderTag :exec
INSERT INTO reminder_tags (reminder_id, tag_id)
VALUES ($1, $2)
ON CONFLICT DO NOTHING;

-- name: GetReminderTags :many
SELECT tg.id, tg.user_id, tg.name, tg.archived_at, tg.created_at
FROM tags tg
JOIN reminder_tags rt ON rt.tag_id = tg.id
WHERE rt.reminder_id = $1;

-- name: DeleteReminderTags :exec
DELETE FROM reminder_tags WHERE reminder_id = $1;
