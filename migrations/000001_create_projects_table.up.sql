CREATE TABLE IF NOT EXISTS projects (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL UNIQUE,
    selected INTEGER NOT NULL,
    currency_symbol TEXT NOT NULL,
    currency_code TEXT NOT NULL,
    hourly_rate REAL,
    deadline INTEGER, -- Unix timestamp (seconds) or NULL
    created_at INTEGER NOT NULL DEFAULT (unixepoch()),
    updated_at INTEGER NOT NULL DEFAULT (unixepoch()),

    CHECK ( selected IN (0, 1) ),
    CHECK ( length(id) = 12 AND id GLOB '[0-9a-f]*' ),
    CHECK ( length(title) > 0 AND length(title) <= 255 )
) STRICT;

CREATE UNIQUE INDEX IF NOT EXISTS idx_single_project_selected ON projects(selected) WHERE selected = 1;