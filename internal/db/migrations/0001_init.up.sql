CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE buckets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    starting_balance BIGINT NOT NULL DEFAULT 0,
    archived_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_buckets_user ON buckets(user_id) WHERE archived_at IS NULL;

CREATE TABLE people (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    archived_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_people_user ON people(user_id) WHERE archived_at IS NULL;

CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    archived_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX idx_tags_user_name ON tags(user_id, LOWER(name));

CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN (
        'expense','income','transfer',
        'loan_given','loan_taken',
        'repayment_received','repayment_paid'
    )),
    amount BIGINT NOT NULL CHECK (amount > 0),
    from_bucket_id UUID REFERENCES buckets(id),
    to_bucket_id   UUID REFERENCES buckets(id),
    person_id      UUID REFERENCES people(id),
    note TEXT NOT NULL DEFAULT '',
    occurred_at TIMESTAMPTZ NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    reverses_id UUID REFERENCES transactions(id),
    CHECK (from_bucket_id IS NULL OR to_bucket_id IS NULL OR from_bucket_id <> to_bucket_id)
);
CREATE INDEX idx_tx_user_occurred ON transactions(user_id, occurred_at DESC);
CREATE INDEX idx_tx_from_bucket ON transactions(from_bucket_id) WHERE from_bucket_id IS NOT NULL;
CREATE INDEX idx_tx_to_bucket   ON transactions(to_bucket_id)   WHERE to_bucket_id   IS NOT NULL;
CREATE INDEX idx_tx_person      ON transactions(person_id)      WHERE person_id      IS NOT NULL;
CREATE INDEX idx_tx_reverses    ON transactions(reverses_id)    WHERE reverses_id    IS NOT NULL;

CREATE TABLE transaction_tags (
    transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
    tag_id         UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (transaction_id, tag_id)
);

CREATE TABLE reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    amount BIGINT CHECK (amount IS NULL OR amount > 0),
    default_type TEXT NOT NULL,
    recurrence_type TEXT NOT NULL CHECK (recurrence_type IN ('none','weekly','monthly','yearly')),
    recurrence_day INT,
    next_due_at TIMESTAMPTZ NOT NULL,
    linked_bucket_id UUID REFERENCES buckets(id),
    linked_person_id UUID REFERENCES people(id),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','paused','completed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_reminders_user_due ON reminders(user_id, next_due_at) WHERE status = 'active';

CREATE TABLE reminder_tags (
    reminder_id UUID NOT NULL REFERENCES reminders(id) ON DELETE CASCADE,
    tag_id      UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (reminder_id, tag_id)
);
