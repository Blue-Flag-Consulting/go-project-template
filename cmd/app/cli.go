package main

import (
	"github.com/spf13/cobra"
)

var (
	configFile string
)

const (
	useDescription   = appName + " [file path]"
	shortDescription = appName + " is a CLI tool that changes everything..."
	longDescription  = `A robust CLI tool built in Go to ...`
)

type Application func() error

func cli(app Application) *cobra.Command {
	var rootCmd = &cobra.Command{
		Use:   useDescription,
		Short: shortDescription,
		Long:  longDescription,
		Args:  cobra.ExactArgs(0),
		RunE: func(cmd *cobra.Command, args []string) error {
			//validation should go here?
			return app()
		},
	}
	// removes the default "Version is {{.Version}}" style.
	rootCmd.SetVersionTemplate("{{.Version}}")

	// PersistentFlags makes them available to this command and any sub-commands you might add later
	rootCmd.PersistentFlags().StringVarP(&configFile, "config", "c", "", "yaml file which host the application configuration ")

	return rootCmd
}
