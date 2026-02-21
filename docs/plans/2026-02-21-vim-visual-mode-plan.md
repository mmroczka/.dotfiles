# VimMode Visual Mode Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Convert visual mode from layer-toggling (fn2) to state-variable-driven using `$mode`, with character visual (v), visual-line (V), operators on selection, count support, and LED feedback.

**Architecture:** Each motion macro gains `$mode == 2` (visual) and `$mode == 3` (visual-line) checks at the top, before existing `$operator` and normal branches. Visual motions add Shift to movement keystrokes to extend selection. Operators in visual mode act on the current selection and return to normal mode. LED color changes on mode entry/exit.

**Tech Stack:** UHK extended macro language, JSON configuration

**Design doc:** `docs/plans/2026-02-21-vim-visual-mode-design.md`

**Important context:** All macros live in `uhk/UserConfiguration.json` in the `macros` array. Each macro's code is a single JSON string with `\n` for newlines inside the `"command"` field. `{` and `}` must be on their own lines — never inline like `{ command }`. Testing is manual on the keyboard. The default backlight color is `255 192 32` (warm gold). The existing `VimMode` macro already demonstrates the `set backlight.constantRgb.rgb` pattern without needing to set `backlight.strategy`.

**Reference:** The `[vim] word` macro (line ~6559) shows the pattern with the existing `$operator` check, and each motion (back, end, down, up, left, right) follows the same structure.

---

### Task 1: Update `$onInit` mode comments

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `$onInit` macro (line ~6581)

**Step 1: Update the mode comment block**

Find the existing comment block in the `$onInit` command string:

```
// mode meanings:\n// 0 = NORMAL   (default; motions/operators/commands)\n// 1 = INSERT   (keys pass through as typing; Esc returns to NORMAL)\n// 2 = VISUAL   (selection mode; motions extend selection; operator acts on selection)\n// 3 = REPLACE  (optional later; like Vim R)\n// 4 = COMMAND  (optional later; \":\" / ex-like command entry)\nsetVar mode 0
```

Replace with:

```
// mode meanings:\n// 0 = NORMAL   (default; motions/operators/commands)\n// 1 = INSERT   (keys pass through as typing; Esc returns to NORMAL)\n// 2 = VISUAL   (character selection; motions extend selection with Shift)\n// 3 = VISUAL LINE (full-line selection; j/k extend by line)\n// 4 = REPLACE  (optional later; like Vim R)\n// 5 = COMMAND  (optional later; \":\" / ex-like command entry)\nsetVar mode 0
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): update onInit mode comments for visual modes"
```

---

### Task 2: Rewrite `[vim] VISUAL` macro (v key)

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] VISUAL` macro (line ~6438)

**Step 1: Replace the command string**

Find:

```
"command": "toggleLayer fn2"
```

Replace with:

```
"command": "if ($mode == 2)\n{\n    // exit visual: deselect, return to normal\n    tapKey right\n    setVar mode 0\n    setVar operator 0\n    setVar count 0\n    set backlight.constantRgb.rgb 255 192 32\n}\nelse if ($mode == 3)\n{\n    // switch from V-LINE to character visual\n    setVar mode 2\n    set backlight.constantRgb.rgb 255 128 0\n}\nelse\n{\n    // enter visual mode from normal\n    setVar mode 2\n    setVar operator 0\n    setVar count 0\n    set backlight.constantRgb.rgb 255 128 0\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): rewrite VISUAL macro to use mode state variable"
```

---

### Task 3: Create `[vim] VISUAL LINE` macro (Shift+V)

**Files:**
- Modify: `uhk/UserConfiguration.json` — add new macro to the `macros` array

**Step 1: Add the new macro**

Insert a new macro entry immediately after the `[vim] VISUAL yank` macro (after line ~6554). Find the closing of `[vim] VISUAL yank`:

```
          "command": "suppressMods tapKey LG-c\nuntoggleLayer"
        }
      ]
    },
    {
      "isLooped": false,
      "isPrivate": true,
      "name": "[vim] word",
```

Replace with:

```
          "command": "suppressMods tapKey LG-c\nuntoggleLayer"
        }
      ]
    },
    {
      "isLooped": false,
      "isPrivate": true,
      "name": "[vim] VISUAL LINE",
      "macroActions": [
        {
          "macroActionType": "command",
          "command": "if ($mode == 3)\n{\n    // exit V-LINE: deselect, return to normal\n    tapKey right\n    setVar mode 0\n    setVar operator 0\n    setVar count 0\n    set backlight.constantRgb.rgb 255 192 32\n}\nelse if ($mode == 2)\n{\n    // switch from character visual to V-LINE\n    setVar mode 3\n    set backlight.constantRgb.rgb 255 0 0\n}\nelse\n{\n    // enter V-LINE from normal: select current line\n    suppressMods\n    {\n        tapKey LG-left\n        tapKeySeq LSG-right\n    }\n    setVar mode 3\n    setVar operator 0\n    setVar count 0\n    set backlight.constantRgb.rgb 255 0 0\n}"
        }
      ]
    },
    {
      "isLooped": false,
      "isPrivate": true,
      "name": "[vim] word",
```

**Step 2: Note for implementer**

After creating the macro in the JSON, you will also need to bind Shift+V to this macro on the VIM keymap. This requires finding the V key in the VIM keymap's base layer and adding a shifted binding. However, the current `[vim] VISUAL` macro is bound to a key — we need to check if Shift+V is already handled there or needs a separate key binding. The UHK macro engine supports `ifShift` inside the `[vim] VISUAL` macro, so an alternative is to handle Shift+V inside the existing `[vim] VISUAL` macro. Let's use that approach instead — see revised Task 2 alternative below.

**Step 2 (revised): Merge VISUAL LINE into [vim] VISUAL macro**

Instead of a separate macro, update the `[vim] VISUAL` command from Task 2 to handle Shift+V:

Go back to the `[vim] VISUAL` macro and replace the command from Task 2 with:

```
"command": "noOp\n\n// Shift+V = visual-line mode\nifShift final\n{\n    if ($mode == 3)\n    {\n        // exit V-LINE: deselect, return to normal\n        suppressMods\n        {\n            tapKey right\n        }\n        setVar mode 0\n        setVar operator 0\n        setVar count 0\n        set backlight.constantRgb.rgb 255 192 32\n    }\n    else if ($mode == 2)\n    {\n        // switch from character visual to V-LINE\n        setVar mode 3\n        set backlight.constantRgb.rgb 255 0 0\n    }\n    else\n    {\n        // enter V-LINE from normal: select current line\n        suppressMods\n        {\n            tapKey LG-left\n            tapKeySeq LSG-right\n        }\n        setVar mode 3\n        setVar operator 0\n        setVar count 0\n        set backlight.constantRgb.rgb 255 0 0\n    }\n}\n\n// v = character visual mode\nif ($mode == 2)\n{\n    // exit visual: deselect, return to normal\n    tapKey right\n    setVar mode 0\n    setVar operator 0\n    setVar count 0\n    set backlight.constantRgb.rgb 255 192 32\n}\nelse if ($mode == 3)\n{\n    // switch from V-LINE to character visual\n    setVar mode 2\n    set backlight.constantRgb.rgb 255 128 0\n}\nelse\n{\n    // enter visual mode from normal\n    setVar mode 2\n    setVar operator 0\n    setVar count 0\n    set backlight.constantRgb.rgb 255 128 0\n}"
```

This means Task 3 (separate VISUAL LINE macro) is **no longer needed**. Both v and Shift+V are handled in one macro.

**Step 3: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): add visual mode and visual-line mode entry/exit with LED"
```

---

### Task 4: Update `[vim] escape` for visual mode exit

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] escape` macro (line ~6317)

**Step 1: Replace the command string**

Find:

```
"command": "setVar operator 0\nsetVar count 0\nsetVar mode 0   // if you want Esc to always return to NORMAL\ntapKey escape"
```

Replace with:

```
"command": "// exit visual modes: deselect and return to normal\nif ($mode == 2 || $mode == 3)\n{\n    tapKey right\n    setVar mode 0\n    setVar operator 0\n    setVar count 0\n    set backlight.constantRgb.rgb 255 192 32\n}\nelse\n{\n    setVar operator 0\n    setVar count 0\n    setVar mode 0\n    tapKey escape\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): update escape to exit visual modes with LED reset"
```

---

### Task 5: Update `[vim] DELETE` for visual mode

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] DELETE` macro (line ~6284)

**Step 1: Replace the command string**

Find the current command (the full string starting with `"command": "noOp\n\n// Shift+d`):

```
"command": "noOp\n\n// Shift+d = D (delete to end of line)\nifShift final {\n    suppressMods {\n        if ($count == 0) {\n        setVar count 1\n    }\n        setVar lastOperator 1\n        setVar lastMotion 5\n        setVar lastCount $count\n        while ($count > 0) {\n            tapKeySeq LSG-right\n            tapKey backspace\n            setVar count ($count - 1)\n        }\n        setVar operator 0\n        setVar count 0\n    }\n}\n\n// dd = delete whole line (operator already pending)\nif ($operator == 1) {\n    if ($count == 0) {\n        setVar count 1\n    }\n    setVar lastOperator 1\n    setVar lastMotion 4\n    setVar lastCount $count\n    while ($count > 0) {\n        tapKey LG-left\n        tapKeySeq LSG-right\n        tapKey backspace\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\nelse {\n    // First press: enter delete operator mode\n    setVar operator 1\n}"
```

Replace with:

```
"command": "noOp\n\n// Visual mode: delete selection\nif ($mode == 2 || $mode == 3)\n{\n    tapKey backspace\n    setVar mode 0\n    setVar operator 0\n    setVar count 0\n    set backlight.constantRgb.rgb 255 192 32\n}\n\n// Shift+d = D (delete to end of line)\nifShift final\n{\n    suppressMods\n    {\n        if ($count == 0)\n        {\n            setVar count 1\n        }\n        setVar lastOperator 1\n        setVar lastMotion 5\n        setVar lastCount $count\n        while ($count > 0)\n        {\n            tapKeySeq LSG-right\n            tapKey backspace\n            setVar count ($count - 1)\n        }\n        setVar operator 0\n        setVar count 0\n    }\n}\n\n// dd = delete whole line (operator already pending)\nif ($operator == 1)\n{\n    if ($count == 0)\n    {\n        setVar count 1\n    }\n    setVar lastOperator 1\n    setVar lastMotion 4\n    setVar lastCount $count\n    while ($count > 0)\n    {\n        tapKey LG-left\n        tapKeySeq LSG-right\n        tapKey backspace\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\nelse\n{\n    // First press: enter delete operator mode\n    setVar operator 1\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): add visual mode delete to DELETE macro"
```

---

### Task 6: Update `[vim] delete` (x key) for visual mode

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] delete` macro (line ~6273)

**Step 1: Replace the command string**

Find:

```
"command": "// give the modifier state one scan to settle\nnoOp\n\n// Shift held means Vim \"X\", delete left\nifShift final holdKey backspace\n\n// otherwise Vim \"x\", delete right\nholdKey delete"
```

Replace with:

```
"command": "// give the modifier state one scan to settle\nnoOp\n\n// Visual mode: delete selection\nif ($mode == 2 || $mode == 3)\n{\n    tapKey backspace\n    setVar mode 0\n    setVar count 0\n    set backlight.constantRgb.rgb 255 192 32\n}\n\n// Shift held means Vim \"X\", delete left\nifShift final holdKey backspace\n\n// otherwise Vim \"x\", delete right\nholdKey delete"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): add visual mode delete to x macro"
```

---

### Task 7: Update `[vim] yank` for visual mode

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] yank` macro (line ~6570)

**Step 1: Replace the command string**

Find:

```
"command": "noOp\n\n// Shift + y  → copy from cursor to end of line, then restore cursor\nifShift final {\n    suppressMods {\n        tapKeySeq LSG-right\n        tapKey LG-c\n        tapKey left\n    }\n}\n\n// yy → copy full line\nifGesture y final {\n    suppressMods {\n        tapKey LG-left\n        tapKeySeq LSG-right\n        tapKey LG-c\n        tapKey LG-right\n    }\n}\n\nholdKey y"
```

Replace with:

```
"command": "noOp\n\n// Visual mode: yank selection, deselect\nif ($mode == 2 || $mode == 3)\n{\n    suppressMods\n    {\n        tapKey LG-c\n    }\n    tapKey right\n    setVar mode 0\n    setVar count 0\n    set backlight.constantRgb.rgb 255 192 32\n}\n\n// Shift + y  → copy from cursor to end of line, then restore cursor\nifShift final\n{\n    suppressMods\n    {\n        tapKeySeq LSG-right\n        tapKey LG-c\n        tapKey left\n    }\n}\n\n// yy → copy full line\nifGesture y final\n{\n    suppressMods\n    {\n        tapKey LG-left\n        tapKeySeq LSG-right\n        tapKey LG-c\n        tapKey LG-right\n    }\n}\n\nholdKey y"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): add visual mode yank support"
```

---

### Task 8: Update `[vim] paste` for visual mode

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] paste` macro (line ~6372)

**Step 1: Replace the command string**

Find:

```
"command": "ifShift suppressMods {\n    tapKey LG-v\n}\nelse suppressMods {\n    tapKey right\n    tapKey LG-v\n}"
```

Replace with:

```
"command": "noOp\n\n// Visual mode: paste over selection\nif ($mode == 2 || $mode == 3)\n{\n    suppressMods\n    {\n        tapKey LG-v\n    }\n    setVar mode 0\n    setVar count 0\n    set backlight.constantRgb.rgb 255 192 32\n}\n\nifShift final suppressMods\n{\n    tapKey LG-v\n}\n\nsuppressMods\n{\n    tapKey right\n    tapKey LG-v\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): add visual mode paste support"
```

---

### Task 9: Convert `[vim] word` macro for visual mode

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] word` macro (line ~6559)

**Step 1: Replace the command string**

Find the current command string (starts with `"command": "if ($operator == 1){\n`).

Replace with:

```
"command": "// VISUAL LINE mode: word motion is no-op in V-LINE\nif ($mode == 3)\n{\n    // no-op for horizontal motions in visual-line mode\n}\n// VISUAL mode: shift+motion to extend selection\nelse if ($mode == 2)\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKeySeq LSA-right LS-right\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKeySeq LSA-right LS-right\n    }\n}\n// DELETE operator\nelse if ($operator == 1)\n{\n    if ($count == 0)\n    {\n        setVar count 1\n    }\n    setVar lastOperator 1\n    setVar lastMotion 1\n    setVar lastCount $count\n    while ($count > 0)\n    {\n        tapKeySeq LSA-right LS-right\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\n// NORMAL motion\nelse\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKeySeq LA-right right\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKeySeq LA-right right\n    }\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): add visual mode support to word macro"
```

---

### Task 10: Convert `[vim] back` macro for visual mode

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] back` macro (line ~6251)

**Step 1: Replace the command string**

Find the current command string (starts with `"command": "if ($operator == 1) {\n`).

Replace with:

```
"command": "// VISUAL LINE mode: back motion is no-op\nif ($mode == 3)\n{\n    // no-op for horizontal motions in visual-line mode\n}\n// VISUAL mode: shift+motion to extend selection\nelse if ($mode == 2)\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKey LSA-left\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKey LSA-left\n    }\n}\n// DELETE operator\nelse if ($operator == 1)\n{\n    if ($count == 0)\n    {\n        setVar count 1\n    }\n    setVar lastOperator 1\n    setVar lastMotion 2\n    setVar lastCount $count\n    while ($count > 0)\n    {\n        tapKeySeq LSA-left\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\n// NORMAL motion\nelse\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKey LA-left\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKey LA-left\n    }\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): add visual mode support to back macro"
```

---

### Task 11: Convert `[vim] end` macro for visual mode

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] end` macro (line ~6306)

**Step 1: Replace the command string**

Find the current command string.

Replace with:

```
"command": "// VISUAL LINE mode: end motion is no-op\nif ($mode == 3)\n{\n    // no-op for horizontal motions in visual-line mode\n}\n// VISUAL mode: shift+motion to extend selection\nelse if ($mode == 2)\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKey LSA-right\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKey LSA-right\n    }\n}\n// DELETE operator\nelse if ($operator == 1)\n{\n    if ($count == 0)\n    {\n        setVar count 1\n    }\n    setVar lastOperator 1\n    setVar lastMotion 3\n    setVar lastCount $count\n    while ($count > 0)\n    {\n        tapKeySeq LSA-right\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\n// NORMAL motion\nelse\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKey LA-right\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKey LA-right\n    }\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): add visual mode support to end macro"
```

---

### Task 12: Convert `[vim] down` macro for visual mode

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] down` macro (line ~6295)

**Step 1: Replace the command string**

Find the current command string.

Replace with:

```
"command": "// VISUAL LINE mode: extend line selection down\nif ($mode == 3)\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKey LS-down\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKey LS-down\n    }\n}\n// VISUAL mode: extend selection down\nelse if ($mode == 2)\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKey LS-down\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKey LS-down\n    }\n}\n// DELETE operator\nelse if ($operator == 1)\n{\n    if ($count == 0)\n    {\n        setVar count 1\n    }\n    setVar lastOperator 1\n    setVar lastMotion 6\n    setVar lastCount $count\n    while ($count > 0)\n    {\n        tapKey LG-left\n        tapKeySeq LSG-right LS-down\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\n// NORMAL motion\nelse\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKey down\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKey down\n    }\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): add visual mode support to down macro"
```

---

### Task 13: Convert `[vim] up` macro for visual mode

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] up` macro (line ~6427)

**Step 1: Replace the command string**

Find the current command string.

Replace with:

```
"command": "// VISUAL LINE mode: extend line selection up\nif ($mode == 3)\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKey LS-up\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKey LS-up\n    }\n}\n// VISUAL mode: extend selection up\nelse if ($mode == 2)\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKey LS-up\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKey LS-up\n    }\n}\n// DELETE operator\nelse if ($operator == 1)\n{\n    if ($count == 0)\n    {\n        setVar count 1\n    }\n    setVar lastOperator 1\n    setVar lastMotion 7\n    setVar lastCount $count\n    while ($count > 0)\n    {\n        tapKey up\n        tapKey LG-left\n        tapKeySeq LSG-right LS-down\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\n// NORMAL motion\nelse\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKey up\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKey up\n    }\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): add visual mode support to up macro"
```

---

### Task 14: Convert `[vim] left` macro for visual mode

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] left` macro (line ~6350)

**Step 1: Replace the command string**

Find the current command string.

Replace with:

```
"command": "// VISUAL LINE mode: left motion is no-op\nif ($mode == 3)\n{\n    // no-op for horizontal motions in visual-line mode\n}\n// VISUAL mode: extend selection left\nelse if ($mode == 2)\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKey LS-left\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKey LS-left\n    }\n}\n// DELETE operator\nelse if ($operator == 1)\n{\n    if ($count == 0)\n    {\n        setVar count 1\n    }\n    setVar lastOperator 1\n    setVar lastMotion 8\n    setVar lastCount $count\n    while ($count > 0)\n    {\n        tapKeySeq LS-left\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\n// NORMAL motion\nelse\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKey left\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKey left\n    }\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): add visual mode support to left macro"
```

---

### Task 15: Convert `[vim] right` macro for visual mode

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] right` macro (line ~6394)

**Step 1: Replace the command string**

Find the current command string.

Replace with:

```
"command": "// VISUAL LINE mode: right motion is no-op\nif ($mode == 3)\n{\n    // no-op for horizontal motions in visual-line mode\n}\n// VISUAL mode: extend selection right\nelse if ($mode == 2)\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKey LS-right\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKey LS-right\n    }\n}\n// DELETE operator\nelse if ($operator == 1)\n{\n    if ($count == 0)\n    {\n        setVar count 1\n    }\n    setVar lastOperator 1\n    setVar lastMotion 9\n    setVar lastCount $count\n    while ($count > 0)\n    {\n        tapKeySeq LS-right\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\n// NORMAL motion\nelse\n{\n    if ($count > 0)\n    {\n        while ($count > 0)\n        {\n            tapKey right\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else\n    {\n        autoRepeat tapKey right\n    }\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): add visual mode support to right macro"
```

---

### Task 16: Final review and JSON validation

**Step 1: Validate JSON**

```bash
python3 -c "import json; json.load(open('uhk/UserConfiguration.json'))"
```

Expected: no output (valid JSON).

**Step 2: Review the full diff**

```bash
git diff HEAD~14..HEAD -- uhk/UserConfiguration.json
```

Verify:
- All 7 motion macros have `$mode == 3`, `$mode == 2`, `$operator == 1`, and normal branches in that order
- `[vim] VISUAL` handles both v and Shift+V with LED color changes
- `[vim] escape` exits visual modes
- Operators (DELETE, delete, yank, paste) check for visual mode at the top
- `$onInit` mode comments are updated
- No JSON syntax errors
- `{` and `}` are on their own lines in all macro command strings

**Step 3: Squash into a single commit (optional, user preference)**

If desired:

```bash
git rebase -i HEAD~14
```

Mark all but the first as `squash`, use message: `feat(vim): add visual mode state-based support with LED feedback`
