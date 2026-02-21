#!/usr/bin/env bash

# workspace_layout.sh
# Displays windows in the focused workspace grouped by their container layout
# Output format: (vt) App1 App2 | (ht) App3 App4 | (f) App5

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

# Apps to exclude from the display (case-sensitive)
EXCLUDED_APPS=(
  "Wispr Flow"
)

# Check if app should be excluded
is_excluded() {
  local app_name="$1"
  for excluded in "${EXCLUDED_APPS[@]}"; do
    if [ "$app_name" = "$excluded" ]; then
      return 0  # true, is excluded
    fi
  done
  return 1  # false, not excluded
}

# Map layout names to short labels
get_layout_label() {
  case "$1" in
    h_tiles) echo "(ht)" ;;
    v_tiles) echo "(vt)" ;;
    h_accordion) echo "(ha)" ;;
    v_accordion) echo "(va)" ;;
    floating) echo "(f)" ;;
    *) echo "(?)" ;;
  esac
}

# Get windows in focused workspace with their layout info
# Format: window_id|app_name|layout
get_windows() {
  aerospace list-windows --workspace focused --format '%{window-id}|%{app-name}|%{window-layout}' 2>/dev/null
}

# Build the display string
build_display() {
  local windows
  windows=$(get_windows)
  
  if [ -z "$windows" ]; then
    echo ""
    return
  fi
  
  local output=""
  local current_layout=""
  local current_apps=""
  local first_group=true
  
  # Process each window
  while IFS='|' read -r window_id app_name layout; do
    # Skip empty lines
    [ -z "$window_id" ] && continue
    
    # Clean up app name (remove extra spaces)
    app_name=$(echo "$app_name" | xargs)
    
    # Skip excluded apps
    if is_excluded "$app_name"; then
      continue
    fi
    
    # If layout changed, output the previous group and start a new one
    if [ "$layout" != "$current_layout" ]; then
      # Output previous group if exists
      if [ -n "$current_layout" ]; then
        local label=$(get_layout_label "$current_layout")
        if [ "$first_group" = true ]; then
          output="${label} ${current_apps}"
          first_group=false
        else
          output="${output} | ${label} ${current_apps}"
        fi
      fi
      
      # Start new group
      current_layout="$layout"
      current_apps="$app_name"
    else
      # Same layout, add to current group
      current_apps="${current_apps} ${app_name}"
    fi
  done <<< "$windows"
  
  # Output the last group
  if [ -n "$current_layout" ]; then
    local label=$(get_layout_label "$current_layout")
    if [ "$first_group" = true ]; then
      output="${label} ${current_apps}"
    else
      output="${output} | ${label} ${current_apps}"
    fi
  fi
  
  echo "$output"
}

# Main execution
DISPLAY_STRING=$(build_display)

if [ -n "$DISPLAY_STRING" ]; then
  sketchybar --set "$NAME" \
    label="$DISPLAY_STRING" \
    label.drawing=on
else
  sketchybar --set "$NAME" \
    label="(empty)" \
    label.drawing=on
fi
