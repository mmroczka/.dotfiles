#!/bin/sh

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

# Get current Aerospace mode by checking which keybindings are active
# The mode is stored in aerospace's state
MODE="MAIN"

# Try to detect resize mode by checking if we're in a non-main mode
# This is a workaround since aerospace doesn't have a direct "get current mode" command
# We can infer it from the window state or just show it when triggered

# For now, we'll just update when the mode changes
# The actual mode detection would require aerospace to provide this info

if [ "$SENDER" = "mode_resize" ]; then
  MODE="RESIZE"
  sketchybar --set "$NAME" \
    label="$MODE" \
    label.drawing=on \
    background.color=$RED \
    background.drawing=on \
    icon.color=$WHITE \
    label.color=$WHITE
elif [ "$SENDER" = "mode_move" ]; then
  MODE="MOVE"
  sketchybar --set "$NAME" \
    label="$MODE" \
    label.drawing=on \
    background.color=$RED \
    background.drawing=on \
    icon.color=$WHITE \
    label.color=$WHITE
elif [ "$SENDER" = "mode_main" ]; then
  MODE=""
  sketchybar --set "$NAME" \
    label="" \
    label.drawing=off \
    background.drawing=off
else
  # Default: assume main mode (no indicator)
  sketchybar --set "$NAME" \
    label="" \
    label.drawing=off \
    background.drawing=off
fi
