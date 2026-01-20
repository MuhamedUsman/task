package main

import (
	"context"
	"fmt"
	"log/slog"
	"os"
	"path/filepath"
	"runtime"
	"time"

	"github.com/lmittmann/tint"
)

func init() {
	opts := &tint.Options{
		AddSource:  true,
		TimeFormat: time.Kitchen,
		ReplaceAttr: func(g []string, a slog.Attr) slog.Attr {
			if a.Value.Kind() == slog.KindAny {
				if _, ok := a.Value.Any().(error); ok {
					return tint.Attr(9, a)
				}
			}
			return a
		},
	}
	slog.SetDefault(slog.New(tint.NewHandler(os.Stderr, opts)))
}

func main() {
	path, err := getAppStoragePath("task")
	if err != nil {
		slog.Error("failed to get app storage path", "error", err)
	}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	db, err := OpenDB(ctx, path)
	if err != nil {
		slog.Error("failed to open database connection", "error", err)
	}
	if err = db.RunMigrations(); err != nil {
		slog.Error("failed to run db migrations", "error", err)
	}
	defer func() {
		_ = db.Close()
	}()
}

func getAppStoragePath(appName string) (string, error) {
	var appStoragePath string
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return "", fmt.Errorf("accessing user's home directory: %v", err)
	}

	switch opSys := runtime.GOOS; opSys {
	case "windows": // Windows: Store in C:/Users/username/AppData/Local/Programs/appName
		localAppData := os.Getenv("LOCALAPPDATA")
		if localAppData == "" {
			return "", fmt.Errorf("finding LOCALAPPDATA environment variable")
		}
		appStoragePath = filepath.Join(localAppData, "Programs", appName)
	case "darwin": // macOS: Store in ~/Library/Application Support/appName
		appStoragePath = filepath.Join(homeDir, "Library", "Application Support", appName)
	case "linux": // Linux: Store in ~/.local/share/appName
		appStoragePath = filepath.Join(homeDir, ".local", "share", appName)
	default:
		return "", fmt.Errorf("unsupported OS: %s", opSys)
	}

	err = os.MkdirAll(appStoragePath, os.ModeDir)
	if err != nil {
		return "", fmt.Errorf("creating app storage directory: %v", err)
	}

	return appStoragePath, nil
}
