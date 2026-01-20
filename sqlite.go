package main

import (
	"context"
	"database/sql"
	"embed"
	"errors"
	"fmt"
	"path/filepath"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/sqlite3"
	iofs2 "github.com/golang-migrate/migrate/v4/source/iofs"
	_ "github.com/mattn/go-sqlite3"
)

const (
	driverSrcName       = "iofs"
	dbFilename          = "task.db"
	maxMigrationVersion = 2
)

//go:embed migrations
var fs embed.FS

type DB struct {
	*sql.DB
}

func OpenDB(ctx context.Context, appStoragePath string) (*DB, error) {
	db, err := sql.Open("sqlite3", filepath.Join(appStoragePath, dbFilename))
	if err != nil {
		return nil, fmt.Errorf("opening database: %v", err)
	}
	if err = db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("pinging db to establish/verify connection: %v", err)
	}
	return &DB{DB: db}, nil
}

func (db *DB) RunMigrations() error {
	iofs, err := iofs2.New(fs, "migrations")
	if err != nil {
		return fmt.Errorf("initializing driver for embedded migration files: %w", err)
	}
	defer func() {
		_ = iofs.Close()
	}()
	cfg := new(sqlite3.Config)
	driver, err := sqlite3.WithInstance(db.DB, cfg)
	if err != nil {
		return fmt.Errorf("getting migrate compatible sqlite3 driver: %v", err)
	}
	m, err := migrate.NewWithInstance(driverSrcName, iofs, "sqlite3", driver)
	if err != nil {
		return fmt.Errorf("initializing migrate with db driver: %v", err)
	}
	v, d, err := m.Version()
	if err != nil && !errors.Is(err, migrate.ErrNilVersion) {
		return fmt.Errorf("retrieving active migration version: %v", err)
	}
	if d {
		return fmt.Errorf("database is in dirty state")
	}
	if v == maxMigrationVersion {
		return nil // latest migration already applied
	}
	if err = m.Up(); err != nil {
		return fmt.Errorf("applying migrations all the way up: %q", err)
	}
	return nil
}
