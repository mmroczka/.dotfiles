# tmux Setup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Set up tmux with F12 prefix, seamless nvim navigation, session persistence, and vi-style copy mode.

**Architecture:** tmux config with TPM for plugin management. `aserowy/tmux.nvim` bridges nvim splits and tmux panes so Ctrl+h/j/k/l works across both. tmux-resurrect + tmux-continuum handle session persistence. Fish Ctrl+H/Ctrl+L bindings removed to avoid conflict.

**Tech Stack:** tmux 3.6a, TPM, lazy.nvim, aserowy/tmux.nvim, fish shell

---

### Task 1: Install TPM (tmux plugin manager)

**Files:**
- Create: `.gitmodules` entry for tpm

**Step 1: Add TPM as a git submodule**

Run:
```bash
cd ~/.dotfiles && git submodule add https://github.com/tmux-plugins/tpm tpm
```

**Step 2: Add TPM symlink to dotbot config**

In `install.conf.yaml`, add to the `link` section:
```yaml
    ~/.tmux/plugins/tpm: tpm
```

**Step 3: Commit**

```bash
git add .gitmodules tpm
git commit -m "feat: add TPM as git submodule"
```

---

### Task 2: Create tmux.conf

**Files:**
- Create: `tmux.conf`

**Step 1: Create the tmux config file**

```
# Prefix: F12 (UHK right thumb key)
set -g prefix F12
unbind C-b
bind F12 send-prefix

# General settings
set -g mouse on
set -g mode-keys vi
set -g base-index 1
setw -g pane-base-index 1
set -g history-limit 50000
set -sg escape-time 0
set -g focus-events on
set-option -g default-shell "/usr/local/bin/fish"

# Terminal colors
set -g default-terminal "tmux-256color"
set -as terminal-features ",xterm-256color:RGB"

# Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Session persistence
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'on'
set -g @resurrect-capture-pane-contents 'on'

# Seamless nvim/tmux navigation
set -g @plugin 'aserowy/tmux.nvim'
set -g @tmux-nvim-navigation true
set -g @tmux-nvim-navigation-cycle true
set -g @tmux-nvim-navigation-keybinding-left 'C-h'
set -g @tmux-nvim-navigation-keybinding-down 'C-j'
set -g @tmux-nvim-navigation-keybinding-up 'C-k'
set -g @tmux-nvim-navigation-keybinding-right 'C-l'
set -g @tmux-nvim-resize true
set -g @tmux-nvim-resize-step-x 50
set -g @tmux-nvim-resize-step-y 10
set -g @tmux-nvim-resize-keybinding-left 'M-h'
set -g @tmux-nvim-resize-keybinding-down 'M-j'
set -g @tmux-nvim-resize-keybinding-up 'M-k'
set -g @tmux-nvim-resize-keybinding-right 'M-l'

# Yanking / copy mode
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @yank_action 'copy-pipe'
bind C-b copy-mode
bind -T copy-mode-vi i send-keys -X cancel
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'yank > #{pane_tty}'
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'yank > #{pane_tty}'
set -s set-clipboard on
setw -g allow-passthrough on

# Zoom pane
bind-key -n M-Space resize-pane -Z

# Window navigation
bind-key -n M-u previous-window
bind-key -n M-i next-window
bind-key -n M-y swap-window -t -1\; select-window -t -1
bind-key -n M-o swap-window -t +1\; select-window -t +1

# URL search
bind-key -n M-/ copy-mode \; send-keys -X search-backward '(https?://|git@|git://|ssh://|ftp://|file:///)[[:alnum:]?=%/_.:,;~@!#$&()*+-]*'

# Status bar
set -g status-position bottom
set -g status-style fg=colour137,bg=colour234,dim
set -g status-left ''
set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
set -g status-right-length 50
set -g status-left-length 20
setw -g window-status-current-style fg=colour81,bg=colour238,bold
setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50] '
setw -g window-status-style fg=colour138,bg=colour235
setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244] '
setw -g window-status-bell-style fg=colour255,bg=colour1,bold

# Initialize TPM (MUST be at the bottom)
run '~/.tmux/plugins/tpm/tpm'
```

**Step 2: Commit**

```bash
git add tmux.conf
git commit -m "feat: add tmux config with F12 prefix and nvim integration"
```

---

### Task 3: Wire tmux.conf into dotbot

**Files:**
- Modify: `install.conf.yaml`

**Step 1: Add symlinks to the link section**

Add these two lines to the `link:` block in `install.conf.yaml`:
```yaml
    ~/.tmux.conf: tmux.conf
    ~/.tmux/plugins/tpm: tpm
```

**Step 2: Commit**

```bash
git add install.conf.yaml
git commit -m "feat: add tmux symlinks to dotbot config"
```

---

### Task 4: Add aserowy/tmux.nvim to neovim

**Files:**
- Create: `nvim/lua/plugins/tmux.lua`

**Step 1: Create the lazy.nvim plugin spec**

```lua
return {
  "aserowy/tmux.nvim",
  config = function()
    require("tmux").setup({
      copy_sync = {
        enable = false,
      },
      navigation = {
        enable_default_keybindings = true,
        cycle_navigation = true,
      },
      resize = {
        enable_default_keybindings = true,
        resize_step_x = 50,
        resize_step_y = 10,
      },
    })
  end,
}
```

**Step 2: Commit**

```bash
git add nvim/lua/plugins/tmux.lua
git commit -m "feat: add tmux.nvim plugin for seamless pane navigation"
```

---

### Task 5: Remove conflicting fish keybindings

**Files:**
- Modify: `fish/functions/fish_user_key_bindings.fish`

**Step 1: Remove the Ctrl+H/Ctrl+L bindings**

Remove these 4 lines from `fish_user_key_bindings.fish`:
```fish
    # prev/next directory bindings
    bind --mode insert \ch prevd-or-backward-word
    bind --mode insert \cl nextd-or-forward-word

    bind --mode default \ch prevd-or-backward-word
    bind --mode default \cl nextd-or-forward-word
```

**Step 2: Commit**

```bash
git add fish/functions/fish_user_key_bindings.fish
git commit -m "feat: remove fish Ctrl+H/L bindings to free them for tmux navigation"
```

---

### Task 6: Install and verify

**Step 1: Run dotbot to create symlinks**

Run:
```bash
cd ~/.dotfiles && ./install_dotfiles
```
Expected: symlinks created for `~/.tmux.conf` and `~/.tmux/plugins/tpm`

**Step 2: Install tmux plugins**

Run:
```bash
~/.tmux/plugins/tpm/bin/install_plugins
```
Expected: TPM downloads tmux-sensible, tmux-resurrect, tmux-continuum, tmux.nvim, tmux-yank

**Step 3: Start tmux and verify**

Run:
```bash
tmux new -s test
```

Verify:
- F12 is the prefix (F12 then `c` should create a new window)
- Ctrl+h/j/k/l navigates between panes (F12 then `%` to split first)
- Alt+u/Alt+i switches windows
- Alt+Space zooms a pane
- Status bar visible at bottom

**Step 4: Verify nvim integration**

Inside tmux, run `nvim`, split a pane with F12+%, then use Ctrl+l to move from nvim to the tmux pane.

**Step 5: Commit any fixes if needed**
