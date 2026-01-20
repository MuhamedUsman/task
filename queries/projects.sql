-- name: CreateProject :exec
INSERT INTO projects (id, title, selected, currency_symbol, currency_code, hourly_rate, deadline)
    VALUES (?, ?, ?, ?, ?, ?, ?);

-- name: GetProjects :many
SELECT *
FROM projects
ORDER BY created_at DESC;

-- name: GetProjectsWithTaskStatus :many
SELECT DISTINCT p.id, p.title, p.selected, p.currency_symbol, p.currency_code, p.hourly_rate, p.deadline
FROM projects p
JOIN tasks t ON p.id = t.project_id
WHERE t.status = ?;

-- name: GetProject :one
SELECT *
FROM projects
WHERE id = ?;

-- name: UpdateProject :exec
UPDATE projects
SET
    title = ?,
    selected = ?,
    currency_symbol = ?,
    currency_code = ?,
    hourly_rate = ?,
    deadline = ?,
    updated_at = ?
WHERE id = ?;

-- name: DeleteProjectByID :exec
DELETE
FROM projects
WHERE id = ?;

-- name: DeleteProjectByTitle :exec
DELETE
FROM projects
WHERE title = ?;

