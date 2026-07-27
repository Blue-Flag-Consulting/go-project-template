package main

import (
	"github.com/spf13/cobra"
)

var (
	configFile string
)

type Application func() error

func cli(app Application) *cobra.Command {
	var rootCmd = &cobra.Command{
		Use:     appName + " [file path]",
		Short:   appName + " is a CLI tool that changes everything...",
		Long:    `A robust CLI tool built in Go to ...`,
		Version: RenderBuildInfo(),
		Args:    cobra.ExactArgs(0),
		RunE: func(cmd *cobra.Command, args []string) error {

			//validation should go here.

			return app()
		},
	}

	// PersistentFlags makes them available to this command and any sub-commands you might add later
	rootCmd.PersistentFlags().StringVarP(&configFile, "config", "c", "", "yaml file which host the application configuration ")
	return rootCmd
}
