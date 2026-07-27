package logger

import (
	"log/slog"
	"os"

	"github.com/lmittmann/tint"
	"github.com/mattn/go-isatty"
)

// SetLogLevel sets the log level based on the string passed in. this is used by the config file to set the log level.
func SetLogLevel(logger *slog.LevelVar, level string) {
	switch level {
	case "DEBUG":
		logger.Set(slog.LevelDebug)
	case "INFO":
		logger.Set(slog.LevelInfo)
	case "WARN":
		logger.Set(slog.LevelWarn)
	case "ERROR":
		logger.Set(slog.LevelError)
	}
}

// PrettyLoggerWithSource returns a slog.Handler that writes to os.Stdout. Added coloring to make it easier to read.
func PrettyLoggerWithSource(level *slog.LevelVar) *slog.Logger {
	var h slog.Handler

	h = tint.NewTextHandler(os.Stdout, &tint.Options{
		NoColor:   !isatty.IsTerminal(os.Stdout.Fd()),
		AddSource: true,
		Level:     level,
	})
	return slog.New(h)
}

// PrettyLogger returns a slog.Handler that writes to os.Stdout. Added coloring to make it easier to read.
func PrettyLogger(level *slog.LevelVar) *slog.Logger {
	var h slog.Handler

	h = tint.NewTextHandler(os.Stdout, &tint.Options{
		NoColor:   !isatty.IsTerminal(os.Stdout.Fd()),
		AddSource: false,
		Level:     level,
	})
	return slog.New(h)
}
