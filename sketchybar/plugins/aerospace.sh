#!/usr/bin/env bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/icon_map.sh"
source "$CONFIG_DIR/colors.sh"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME background.drawing=on \
    background.color=$ACCENT_TRANSPARENT \
    icon.color=$ACCENT \
    label.color=$ACCENT
else
  sketchybar --set $NAME background.drawing=off \
    icon.color=$GREY \
    label.color=$GREY
fi
