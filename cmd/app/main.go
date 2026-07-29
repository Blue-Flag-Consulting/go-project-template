package main

import (
	"context"
	"os"

	"github.com/charmbracelet/fang"
)

// TODO: Update the name
const appName = "NewApp"

func main() {
	cmd := cli(App)

	if err := fang.Execute(context.Background(), cmd, fang.WithVersion(StyledVersionInfo())); err != nil {
		os.Exit(1)
	}
	os.Exit(0)
}

// App will be invoked by the CLI.
func App() error {
	log.Info("starting app...")
	return nil
}
