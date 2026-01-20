CREATE TABLE IF NOT EXISTS projects (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL UNIQUE,
    selected INTEGER NOT NULL DEFAULT 0,
    currency_symbol TEXT NOT NULL DEFAULT '$',
    currency_code TEXT NOT NULL DEFAULT 'USD',
    hourly_rate REAL,
    time_spent REAL NOT NULL DEFAULT 0.0, -- in hours
    deadline INTEGER, -- Unix timestamp (seconds) or NULL
    created_at INTEGER NOT NULL DEFAULT (unixepoch()),
    updated_at INTEGER NOT NULL DEFAULT (unixepoch()),

    CHECK ( selected IN (0, 1) ),
    CHECK ( length(id) = 12 AND id GLOB '[0-9a-f]*' ),
    CHECK ( length(title) > 0 AND length(title) <= 255 )
) STRICT;