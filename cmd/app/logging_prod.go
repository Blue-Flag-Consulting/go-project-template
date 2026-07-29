//go:build prod

package main

import (
	"go-project-template/internal/logger"
	"log/slog"
)

var loglevel slog.LevelVar

var log *slog.Logger

func init() {
	loglevel.Set(slog.LevelInfo)
	log = logger.PrettyLogger(&loglevel)
}
