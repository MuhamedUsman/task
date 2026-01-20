PRAGMA FOREIGN_KEYS = ON;

CREATE TABLE IF NOT EXISTS tasks (
    id TEXT PRIMARY KEY,
    project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    paused INTEGER DEFAULT 1, -- 1 paused, 0 resumed
    time_spent REAL NOT NULL DEFAULT 0.0, -- in hours
    deadline INTEGER, -- Unix timestamp (seconds) or NULL
    created_at INTEGER NOT NULL DEFAULT (unixepoch()),
    started_at INTEGER,

    UNIQUE (title, project_id),
    CHECK ( paused IN (0, 1) ),
    CHECK ( length(id) = 12 AND id GLOB '[0-9a-f]*' ),
    CHECK ( length(title) > 0 AND length(title) <= 255 ),
    CHECK ( (paused = 1 AND started_at IS NULL) OR (paused = 0 AND started_at IS NOT NULL) )
) STRICT;

CREATE INDEX idx_tasks_project_id ON tasks(project_id);