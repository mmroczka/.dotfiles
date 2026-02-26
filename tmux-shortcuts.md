# tmux Shortcuts

## Panes

| Action              | Binding        |
|---------------------|----------------|
| Vertical split      | `Ctrl+b %`     |
| Horizontal split    | `Ctrl+b "`     |
| Navigate panes      | `Ctrl+h/j/k/l` |
| Zoom pane           | `Alt+m`        |
| Shrink pane         | `Alt+-`        |
| Grow pane           | `Alt+=`        |
| Balance panes       | `Alt++`        |
| Close pane          | `Ctrl+b x`    |

## Windows

| Action              | Binding        |
|---------------------|----------------|
| New window          | `Ctrl+b c`    |
| Previous window     | `Alt+u`        |
| Next window         | `Alt+i`        |
| Swap window left    | `Alt+y`        |
| Swap window right   | `Alt+o`        |
| Rename window       | `Ctrl+b ,`    |

## Sessions

| Action                    | Binding              |
|---------------------------|----------------------|
| Start/attach work session | `tw` (fish abbr)     |
| Session picker            | `Ctrl+b s`          |
| Detach                    | `Ctrl+q`            |

## Copy Mode

| Action              | Binding        |
|---------------------|----------------|
| Enter copy mode     | `Ctrl+b [`     |
| Start selection     | `v`            |
| Yank (copy)         | `y`            |
| Cancel              | `i`            |
| Search forward      | `/`            |
| URL search          | `Alt+/`        |

## Claude Code

| Action              | Binding          |
|---------------------|------------------|
| Open popup          | `Ctrl+b Ctrl+c` |
| Dismiss popup       | `Ctrl+q`        |

## Navigation (seamless nvim/tmux)

`Ctrl+h/j/k/l` works identically whether you're in a tmux pane or a neovim split — you never need to think about which one you're in.
