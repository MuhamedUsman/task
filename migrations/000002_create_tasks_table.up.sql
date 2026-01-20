PRAGMA FOREIGN_KEYS = ON;

CREATE TABLE IF NOT EXISTS tasks (
    id TEXT PRIMARY KEY,
    project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    status INTEGER NOT NULL DEFAULT 0, -- 0 paused, 1 running, 2 completed
    priority INTEGER NOT NULL,
    time_spent REAL NOT NULL, -- in hours
    deadline INTEGER, -- Unix timestamp (seconds) or NULL
    created_at INTEGER NOT NULL DEFAULT (unixepoch()),
    started_at INTEGER,

    UNIQUE (title, project_id),
    CHECK ( status IN (0, 1, 2) ),
    CHECK ( priority IN (0, 1, 2) ),
    CHECK ( length(id) = 12 AND id GLOB '[0-9a-f]*' ),
    CHECK ( length(title) > 0 AND length(title) <= 255 ),
    CHECK ( (status != 1 AND started_at IS NULL) OR (status = 1 AND started_at IS NOT NULL) )
) STRICT;

CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks(project_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_single_running_task ON tasks(status) WHERE status = 1;