# tmux Setup Design

## Goal

Set up tmux with sensible defaults, seamless nvim integration, and session persistence. Use UHK right-thumb F12 as the prefix key.

## Files

| File | Action |
|---|---|
| `tmux.conf` | Create — main tmux config |
| `install.conf.yaml` | Edit — add symlink `~/.tmux.conf: tmux.conf` |
| `fish/functions/fish_user_key_bindings.fish` | Edit — remove Ctrl+H/Ctrl+L bindings |
| `nvim/lua/custom/plugins/tmux.lua` | Create — aserowy/tmux.nvim lazy spec |

## tmux.conf

- Prefix: F12
- Navigation: Ctrl+h/j/k/l (seamless tmux/nvim via aserowy/tmux.nvim)
- Resize: Alt+h/j/k/l
- Windows: Alt+u/Alt+i prev/next, Alt+y/Alt+o swap
- Copy mode: vi keys, v select, y yank, OSC-52 clipboard passthrough
- Plugins: tpm, tmux-sensible, tmux-resurrect, tmux-continuum, tmux.nvim, tmux-yank
- Settings: fish shell, escape-time 0, base-index 1, 50000 scrollback, 256color+RGB
- Status bar: minimal bottom bar

## Fish Changes

Remove Ctrl+H/Ctrl+L bindings (insert + default mode, 4 lines) from `fish_user_key_bindings.fish`. These conflict with Ctrl+h/l tmux/nvim navigation.

## nvim Plugin

`aserowy/tmux.nvim` via lazy.nvim — copy_sync disabled, navigation + resize enabled with matching keybindings.
