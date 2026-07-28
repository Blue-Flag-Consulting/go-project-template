package main

import (
	"image/color"
	"os"

	"charm.land/lipgloss/v2"
	"github.com/charmbracelet/fang"
	"github.com/charmbracelet/x/term"
)

var isDark bool

// MotionAppliedColorScheme returns a colorscheme inspired by Motion Applied.
func MotionAppliedColorScheme(c lipgloss.LightDarkFunc) fang.ColorScheme {
	// Core Brand Colors
	// Motion Applied uses a signature bright orange in their logo over stark backgrounds.
	brandOrange := lipgloss.Color("#FF8700")

	// Base Text
	darkText := lipgloss.Color("#1A1A1A")
	lightText := lipgloss.Color("#F8F9FA")

	// Codeblock Backgrounds
	codeBgLight := lipgloss.Color("#F1F3F5")
	codeBgDark := lipgloss.Color("#212529")

	// Accent Colors for syntax
	techBlueLight := lipgloss.Color("#0072CE")
	techBlueDark := lipgloss.Color("#4DB8FF")

	successGreenLight := lipgloss.Color("#0CB37F")
	successGreenDark := lipgloss.Color("#20D489")

	// Muted shades for descriptions and comments
	mutedLight := lipgloss.Color("#6C757D")
	mutedDark := lipgloss.Color("#ADB5BD")

	errorRed := lipgloss.Color("#E60000")
	white := lipgloss.Color("#FFFFFF")

	return fang.ColorScheme{
		Base: c(darkText, lightText),

		// Use the signature orange for high-visibility components
		Title:   brandOrange,
		Command: brandOrange,

		Codeblock: c(codeBgLight, codeBgDark),
		Program:   c(techBlueLight, techBlueDark),

		// Subtle greyed elements for secondary info
		DimmedArgument: c(mutedLight, mutedDark),
		Comment:        c(mutedLight, mutedDark),
		Description:    c(lipgloss.Color("#495057"), lipgloss.Color("#CED4DA")),
		FlagDefault:    c(mutedLight, mutedDark),
		Help:           c(mutedLight, mutedDark),
		Dash:           c(mutedLight, mutedDark),

		// Standard syntax colors
		Flag:         c(successGreenLight, successGreenDark),
		QuotedString: c(techBlueLight, techBlueDark),
		Argument:     c(darkText, lightText),

		// High contrast error states
		ErrorHeader: [2]color.Color{
			white,    // fg
			errorRed, // bg
		},
		ErrorDetails: errorRed,
	}
}

// DefaultMotionAppliedTheme is a helper to instantiate the theme based on the terminal's background.
func DefaultMotionAppliedTheme(isDark bool) fang.ColorScheme {
	return MotionAppliedColorScheme(lipgloss.LightDark(isDark))
}

func init() {
	isDark = false
	if term.IsTerminal(os.Stdout.Fd()) {
		isDark = lipgloss.HasDarkBackground(os.Stdin, os.Stdout)
	}
}
