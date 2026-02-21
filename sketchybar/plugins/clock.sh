#!/bin/sh

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

sketchybar --set "$NAME" label="$(date '+%d %b %H.%M')" icon.color="$GREY" label.color="$GREY"
