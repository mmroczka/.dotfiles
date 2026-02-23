# Übersicht Vertical Sidebar — Design

## Goal

Add a slim vertical sidebar on the left edge of the screen showing AeroSpace workspace indicators (1-5). Keep the native macOS menu bar.

## Decisions

- **Tool:** Übersicht (JSX/CSS widgets, free positioning)
- **Content:** Workspace numbers 1-5 only, always shown
- **Active indicator:** Filled white circle; inactive: hollow circle (outline only)
- **Bar width:** 40px, dark semi-transparent background
- **Updates:** Event-driven via AeroSpace `exec-on-workspace-change` hook, with 10s fallback poll
- **Position:** Left edge, full screen height

## File Structure

```
ubersicht/
  aerospace-workspaces.jsx   # Übersicht widget
```

## Widget Details

- **Command:** `aerospace list-workspaces --focused`
- **Render:** Maps workspaces [1,2,3,4,5], highlights the focused one
- **Style:** 40px wide, full height, `rgba(0,0,0,0.5)` background, dots ~12px vertically centered

## AeroSpace Changes

- `exec-on-workspace-change`: Add `osascript` call to refresh Übersicht widget
- `outer.left` gap: 10 → 50 (40px bar + 10px padding)

## Dotbot Changes

- Create `~/.config/ubersicht/` directory
- Symlink `ubersicht/` widget files to Übersicht widgets directory (`~/Library/Application Support/Übersicht/widgets/`)

## Install

- `brew install --cask ubersicht`
