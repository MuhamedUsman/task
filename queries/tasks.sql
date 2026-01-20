-- name: CreateTask :exec
INSERT INTO tasks (id, project_id, title, description, status, priority, time_spent, deadline, started_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);

-- name: GetTask :one
SELECT *
FROM tasks
WHERE id = ?;

-- name: GetTasksByProject :many
SELECT *
FROM tasks
WHERE project_id = ?;

-- name: GetTasksByProjectWithStatus :many
SELECT *
FROM tasks
WHERE project_id = ? AND status = ?;

-- name: GetTasksByProjectWithPriority :many
SELECT *
FROM tasks
WHERE project_id = ? AND priority = ?;

-- name: GetRunningTaskByProject :one
SELECT *
FROM tasks
WHERE project_id = ? AND status = 1;

-- name: GetTasksByProjectWithDeadlineExceeded :many
SELECT *
FROM tasks
WHERE project_id = ? AND abs(deadline - sqlc.arg('current_unix_epoch')) >= (time_spent * 60 * 60);

-- name: UpdateTask :exec
UPDATE tasks
SET
    title = ?,
    description = ?,
    status = ?,
    priority = ?,
    time_spent = ?,
    deadline = ?,
    started_at = ?
WHERE id = ?;

-- name: DeleteTaskByID :exec
DELETE
FROM tasks
WHERE id = ?;

-- name: DeleteTaskByProjectWithTitle :exec
DELETE
FROM tasks
WHERE tasks.project_id = ? AND title = ?;

-- name: DeleteTaskByProjectWithStatus :exec
DELETE
FROM tasks
WHERE project_id = ? AND status = ?;