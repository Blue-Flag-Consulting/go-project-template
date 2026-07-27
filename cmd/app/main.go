package main

import (
	"context"
	"fmt"
	"os"

	"github.com/charmbracelet/fang"
)

// TODO: Update the name
const appName = "NewApp"

func main() {
	cmd := cli(App)

	if err := fang.Execute(context.Background(), cmd); err != nil {
		os.Exit(1)
	}
	os.Exit(0)
}

// App will be invoked by the CLI.
func App() error {
	fmt.Println("Hello World!")
	fmt.Println(configFile)
	return nil
}
