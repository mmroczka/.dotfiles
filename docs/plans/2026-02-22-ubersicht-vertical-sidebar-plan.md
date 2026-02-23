# Übersicht Vertical Sidebar Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a 40px vertical sidebar on the left screen edge showing AeroSpace workspace indicators (1-5) as filled/hollow dots, updated via event-driven hooks.

**Architecture:** An Übersicht JSX widget renders workspace dots using output from `aerospace list-workspaces --focused`. AeroSpace's `exec-on-workspace-change` triggers an osascript refresh. The widget file lives in the dotfiles repo and is symlinked by dotbot.

**Tech Stack:** Übersicht (JSX/React widgets), AeroSpace CLI, dotbot

---

### Task 1: Install Übersicht

**Step 1: Install via Homebrew**

Run: `brew install --cask ubersicht`

**Step 2: Verify installation**

Run: `ls /Applications/Übersicht.app` or `ls "/Applications/Übersicht.app"`
Expected: App exists

**Step 3: Launch Übersicht**

Run: `open "/Applications/Übersicht.app"`

**Step 4: Verify widgets directory exists**

Run: `ls ~/Library/Application\ Support/Übersicht/widgets/`
Expected: Directory exists (may be empty)

---

### Task 2: Create the widget

**Files:**
- Create: `ubersicht/aerospace-workspaces.jsx`

**Step 1: Create widget directory**

Run: `mkdir -p /Users/michaelmroczka/.dotfiles/ubersicht`

**Step 2: Write the widget**

Create `ubersicht/aerospace-workspaces.jsx`:

```jsx
import { css } from "uebersicht";

export const command = "/opt/homebrew/bin/aerospace list-workspaces --focused 2>/dev/null || /usr/local/bin/aerospace list-workspaces --focused 2>/dev/null";

export const refreshFrequency = 10000;

const WORKSPACES = [1, 2, 3, 4, 5];

const containerStyle = css`
  position: fixed;
  top: 0;
  left: 0;
  width: 40px;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16px;
  z-index: 1;
`;

const dotStyle = (active) => css`
  width: 12px;
  height: 12px;
  border-radius: 50%;
  border: 2px solid rgba(255, 255, 255, 0.9);
  background: ${active ? "rgba(255, 255, 255, 0.9)" : "transparent"};
  transition: background 0.15s ease;
`;

export const className = css`
  pointer-events: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 40px;
  height: 100%;
`;

export const render = ({ output }) => {
  const focused = parseInt(output?.trim(), 10);
  return (
    <div className={containerStyle}>
      {WORKSPACES.map((ws) => (
        <div key={ws} className={dotStyle(ws === focused)} />
      ))}
    </div>
  );
};
```

**Step 3: Verify file exists**

Run: `ls -la /Users/michaelmroczka/.dotfiles/ubersicht/aerospace-workspaces.jsx`
Expected: File listed

---

### Task 3: Symlink widget via dotbot

**Files:**
- Modify: `install.conf.yaml`

**Step 1: Add Übersicht widgets directory and symlink**

In `install.conf.yaml`, add to the `- create:` section:
```yaml
    - ~/Library/Application Support/Übersicht/widgets
```

Add to the `- link:` section:
```yaml
    ~/Library/Application Support/Übersicht/widgets/aerospace-workspaces.jsx: ubersicht/aerospace-workspaces.jsx
```

**Step 2: Run dotbot to create the symlink**

Run: `cd /Users/michaelmroczka/.dotfiles && ./install_dotfiles`
Expected: Symlink created successfully

**Step 3: Verify symlink**

Run: `ls -la ~/Library/Application\ Support/Übersicht/widgets/aerospace-workspaces.jsx`
Expected: Symlink pointing to dotfiles repo

---

### Task 4: Update AeroSpace config

**Files:**
- Modify: `aerospace.toml`

**Step 1: Replace exec-on-workspace-change with Übersicht refresh**

Replace the existing `exec-on-workspace-change` block (lines 19-24) with:

```toml
# Hook to refresh Übersicht workspace widget on workspace change
exec-on-workspace-change = [
  '/bin/bash',
  '-c',
  'osascript -e "tell application id \"tracesOf.Uebersicht\" to refresh widget id \"aerospace-workspaces-jsx\""',
]
```

**Step 2: Remove stale sketchybar comments**

Delete the commented-out on-focus-changed and on-mode-changed blocks (lines 26-31).

**Step 3: Update outer.left gap**

Change `outer.left` from `10` to `50` and update the comment on `outer.top`:

```toml
outer.left = 50       # 40px for Übersicht sidebar + 10px padding
outer.bottom = 10
outer.top = 10
outer.right = 10
```

**Step 4: Reload AeroSpace config**

Run: `aerospace reload-config`

---

### Task 5: Test end-to-end

**Step 1: Verify widget is visible**

Look at the left edge of the screen — a dark 40px sidebar with 5 dots should appear, with the current workspace dot filled.

**Step 2: Test workspace switching**

Run: `aerospace workspace 3`
Expected: Dot for workspace 3 becomes filled, workspace 1 becomes hollow.

Run: `aerospace workspace 1`
Expected: Dot for workspace 1 becomes filled again.

**Step 3: Commit**

```bash
git add ubersicht/aerospace-workspaces.jsx aerospace.toml install.conf.yaml
git commit -m "feat: add Übersicht vertical sidebar for AeroSpace workspace indicators"
```
