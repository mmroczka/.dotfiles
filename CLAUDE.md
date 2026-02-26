# Dotfiles

## Keyboard Configuration

My keyboard is an Ultimate Hacking Keyboard (UHK). When I ask about remapping keys or changing keyboard behavior, use the UHK configuration — **not** Karabiner, Goku, or LeaderKey.

Key files:
- `uhk/UserConfiguration.json` — my current UHK keymap and settings
- `uhk/knowledge.md` — reference documentation for the UHK extended macro engine and configuration language

Always read both files before making keyboard-related changes.

## tmux + Neovim

My tmux and neovim configs are tightly integrated via `aserowy/tmux.nvim`.

Key files:
- `tmux.conf` — tmux config (Ctrl+b prefix, TPM plugins, Claude Code popup)
- `nvim/lua/plugins/tmux.lua` — lazy.nvim spec for tmux.nvim
- `nvim/lua/config/keymaps.lua` — Ctrl+h/j/k/l overrides (required because LazyVim defaults override tmux.nvim)

Important: LazyVim's default `<C-h/j/k/l>` keymaps override tmux.nvim. Any navigation changes must go in `keymaps.lua`, not the plugin spec.

My neovim uses LazyVim with fzf-lua (not telescope) as the picker.
