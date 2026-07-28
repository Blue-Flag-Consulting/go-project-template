package main

import (
	"log/slog"
)

var loglevel slog.LevelVar

func init() {
	loglevel.Set(slog.LevelInfo)
}
