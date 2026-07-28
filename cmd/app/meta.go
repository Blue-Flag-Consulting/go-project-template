package main

import "charm.land/lipgloss/v2"

// Build Info is added during compile time. Helps identify the build when debugging or reviewing logs
// ldflags: -s -w -X 'main.buildTime={{.Date}}' -X 'main.shortCommit={{.ShortCommit}}' -X 'main.fullCommit={{.FullCommit}}' -X 'main.versionTag={{.Version}}'
var (
	buildTime   string
	shortCommit string
	fullCommit  string
	versionTag  string
)

func StyledVersionInfo() string {
	// Styles
	label := lipgloss.NewStyle().
		Foreground(lipgloss.Color("63")). // cyan
		Bold(true)

	value := lipgloss.NewStyle().
		Foreground(lipgloss.Color("15")) // white

	title := lipgloss.NewStyle().
		Foreground(lipgloss.Color("205")). // magenta
		Bold(true).
		Underline(true)

	description := lipgloss.NewStyle().
		Foreground(lipgloss.Color("240"))

	box := lipgloss.NewStyle().
		Border(lipgloss.RoundedBorder()).
		BorderForeground(lipgloss.Color("240")).
		Padding(1, 2)

	// Row helper with aligned labels.
	const labelWidth = 14
	row := func(l, v string) string {
		ll := label.Width(labelWidth).Render(l + ": ")
		vv := value.Render(v)
		return lipgloss.JoinHorizontal(lipgloss.Left, ll, vv)
	}

	// Content
	content := lipgloss.JoinVertical(lipgloss.Left,
		row("Version", versionTag),
		row("Build Time", buildTime),
		row("Build Commit", fullCommit),
	)

	// Title + content
	header := title.Render(appName)
	summary := description.Render(longDescription)
	return box.Render(header+"\n"+summary+"\n\n"+content) + "\n"
}
