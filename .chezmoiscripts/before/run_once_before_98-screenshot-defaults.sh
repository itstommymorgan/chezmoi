#!/usr/bin/env zsh

# Screenshots should behave like the Windows snipping tool: hotkey, drag, and the
# image is on the clipboard ready to paste.
#
# Cmd+Ctrl+Shift+4 already does the crosshair-and-drag part natively. These two
# defaults fix what happens afterwards.

set -euo pipefail

# The floating thumbnail parks in the corner for ~5s and the capture does not land
# until it disappears, so hitting paste straight after a screenshot gets nothing.
# This is the setting that makes macOS screenshots feel broken rather than slow.
defaults write com.apple.screencapture show-thumbnail -bool false

# Send captures to the clipboard rather than scattering PNGs across the Desktop.
# Applies to Cmd+Shift+4 and to Screenshot.app's default, and can still be
# overridden per-capture in the Cmd+Shift+5 UI.
defaults write com.apple.screencapture target -string clipboard

# Picked up on the next capture without this, but restarting makes it immediate.
killall SystemUIServer 2>/dev/null || true
