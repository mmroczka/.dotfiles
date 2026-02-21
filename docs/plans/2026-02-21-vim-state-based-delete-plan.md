# VimMode State-Based Delete Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Convert all VimMode motion macros to be DELETE-operator-aware with count support and dot-repeat.

**Architecture:** Each motion macro in `uhk/UserConfiguration.json` gets an inline `if ($operator == 1)` check following the template established by `[vim] word`. The DELETE key macro gains dd/D support via state checks. The dot-repeat macro dispatches on all motion IDs.

**Tech Stack:** UHK extended macro language, JSON configuration

**Design doc:** `docs/plans/2026-02-21-vim-state-based-delete-design.md`

**Important context:** All macros live in `uhk/UserConfiguration.json` in the `macros` array. Each macro's code is a single JSON string with `\n` for newlines inside the `"command"` field. There is no automated test framework — testing is manual on the keyboard. The file is ~6700 lines of JSON.

**Reference implementation:** The `[vim] word` macro (line ~6559) shows the exact pattern every motion should follow.

---

### Task 1: Update `$onInit` motion ID comments

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `$onInit` macro (line ~6582)

**Step 1: Update the lastMotion comment block**

Find the existing comment block in the `$onInit` command string:

```
// motion meanings:\n// 0 = NONE\n// 1 = WORD (w)\n// 2 = BACK_WORD (b)\n// 3 = END_WORD (e)\n// 4 = LINE (dd)\n// 5 = TO_EOL (D)\nsetVar lastMotion 0
```

Replace with:

```
// motion meanings:\n// 0 = NONE\n// 1 = WORD (w)\n// 2 = BACK_WORD (b)\n// 3 = END_WORD (e)\n// 4 = LINE (dd)\n// 5 = TO_EOL (D)\n// 6 = DOWN (j)\n// 7 = UP (k)\n// 8 = LEFT (h)\n// 9 = RIGHT (l)\nsetVar lastMotion 0
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): add motion IDs 6-9 to onInit comments"
```

---

### Task 2: Convert `[vim] DELETE` macro

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] DELETE` macro (line ~6284)

**Step 1: Replace the command string**

Find the current command:

```
"command": "setVar operator 1 // enable Delete Mode"
```

Replace with:

```
"command": "noOp\n\n// Shift+d = D (delete to end of line)\nifShift final {\n    suppressMods {\n        if ($count == 0) { setVar count 1 }\n        setVar lastOperator 1\n        setVar lastMotion 5\n        setVar lastCount $count\n        while ($count > 0) {\n            tapKeySeq LSG-right\n            tapKey backspace\n            setVar count ($count - 1)\n        }\n        setVar operator 0\n        setVar count 0\n    }\n}\n\n// dd = delete whole line (operator already pending)\nif ($operator == 1) {\n    if ($count == 0) { setVar count 1 }\n    setVar lastOperator 1\n    setVar lastMotion 4\n    setVar lastCount $count\n    while ($count > 0) {\n        tapKey LG-left\n        tapKeySeq LSG-right\n        tapKey backspace\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\nelse {\n    // First press: enter delete operator mode\n    setVar operator 1\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): add dd and D support to DELETE macro"
```

---

### Task 3: Convert `[vim] back` macro

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] back` macro (line ~6251)

**Step 1: Replace the command string**

Find:

```
"command": "holdKey LA-left"
```

Replace with:

```
"command": "if ($operator == 1) {\n    if ($count == 0) { setVar count 1 }\n    setVar lastOperator 1\n    setVar lastMotion 2\n    setVar lastCount $count\n    while ($count > 0) {\n        tapKeySeq LSA-left\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\nelse {\n    if ($count > 0) {\n        setVar lastOperator 0\n        setVar lastMotion 2\n        setVar lastCount $count\n        while ($count > 0) {\n            tapKey LA-left\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else {\n        autoRepeat tapKey LA-left\n    }\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): convert back motion to state-based pattern"
```

---

### Task 4: Convert `[vim] end` macro

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] end` macro (line ~6306)

**Step 1: Replace the command string**

Find:

```
"command": "autoRepeat tapKey LA-right"
```

Replace with:

```
"command": "if ($operator == 1) {\n    if ($count == 0) { setVar count 1 }\n    setVar lastOperator 1\n    setVar lastMotion 3\n    setVar lastCount $count\n    while ($count > 0) {\n        tapKeySeq LSA-right\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\nelse {\n    if ($count > 0) {\n        setVar lastOperator 0\n        setVar lastMotion 3\n        setVar lastCount $count\n        while ($count > 0) {\n            tapKey LA-right\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else {\n        autoRepeat tapKey LA-right\n    }\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): convert end motion to state-based pattern"
```

---

### Task 5: Convert `[vim] down` macro

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] down` macro (line ~6295)

**Step 1: Replace the command string**

Find:

```
"command": "holdKey down"
```

Replace with:

```
"command": "if ($operator == 1) {\n    if ($count == 0) { setVar count 1 }\n    setVar lastOperator 1\n    setVar lastMotion 6\n    setVar lastCount $count\n    while ($count > 0) {\n        tapKey LG-left\n        tapKeySeq LSG-right LS-down\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\nelse {\n    if ($count > 0) {\n        setVar lastOperator 0\n        setVar lastMotion 6\n        setVar lastCount $count\n        while ($count > 0) {\n            tapKey down\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else {\n        autoRepeat tapKey down\n    }\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): convert down motion to state-based pattern"
```

---

### Task 6: Convert `[vim] up` macro

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] up` macro (line ~6427)

**Step 1: Replace the command string**

Find:

```
"command": "holdKey up"
```

Replace with:

```
"command": "if ($operator == 1) {\n    if ($count == 0) { setVar count 1 }\n    setVar lastOperator 1\n    setVar lastMotion 7\n    setVar lastCount $count\n    while ($count > 0) {\n        tapKey up\n        tapKey LG-left\n        tapKeySeq LSG-right LS-down\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\nelse {\n    if ($count > 0) {\n        setVar lastOperator 0\n        setVar lastMotion 7\n        setVar lastCount $count\n        while ($count > 0) {\n            tapKey up\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else {\n        autoRepeat tapKey up\n    }\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): convert up motion to state-based pattern"
```

---

### Task 7: Convert `[vim] left` macro

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] left` macro (line ~6350)

**Step 1: Replace the command string**

Find:

```
"command": "holdKey left"
```

Replace with:

```
"command": "if ($operator == 1) {\n    if ($count == 0) { setVar count 1 }\n    setVar lastOperator 1\n    setVar lastMotion 8\n    setVar lastCount $count\n    while ($count > 0) {\n        tapKeySeq LS-left\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\nelse {\n    if ($count > 0) {\n        setVar lastOperator 0\n        setVar lastMotion 8\n        setVar lastCount $count\n        while ($count > 0) {\n            tapKey left\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else {\n        autoRepeat tapKey left\n    }\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): convert left motion to state-based pattern"
```

---

### Task 8: Convert `[vim] right` macro

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] right` macro (line ~6394)

**Step 1: Replace the command string**

Find:

```
"command": "holdKey right"
```

Replace with:

```
"command": "if ($operator == 1) {\n    if ($count == 0) { setVar count 1 }\n    setVar lastOperator 1\n    setVar lastMotion 9\n    setVar lastCount $count\n    while ($count > 0) {\n        tapKeySeq LS-right\n        tapKey backspace\n        setVar count ($count - 1)\n    }\n    setVar operator 0\n    setVar count 0\n}\nelse {\n    if ($count > 0) {\n        setVar lastOperator 0\n        setVar lastMotion 9\n        setVar lastCount $count\n        while ($count > 0) {\n            tapKey right\n            setVar count ($count - 1)\n        }\n        setVar count 0\n    }\n    else {\n        autoRepeat tapKey right\n    }\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): convert right motion to state-based pattern"
```

---

### Task 9: Update `[vim] .` dot-repeat macro

**Files:**
- Modify: `uhk/UserConfiguration.json` — the `[vim] .` macro (line ~6119)

**Step 1: Replace the command string**

Find the current command (handles only operator=1 + motion=1).

Replace with the full dispatch:

```
"command": "if ($lastOperator == 1) {\n    setVar count $lastCount\n\n    // WORD (1)\n    if ($lastMotion == 1) {\n        while ($count > 0) {\n            tapKeySeq LSA-right LS-right\n            tapKey backspace\n            setVar count ($count - 1)\n        }\n    }\n    // BACK_WORD (2)\n    if ($lastMotion == 2) {\n        while ($count > 0) {\n            tapKeySeq LSA-left\n            tapKey backspace\n            setVar count ($count - 1)\n        }\n    }\n    // END_WORD (3)\n    if ($lastMotion == 3) {\n        while ($count > 0) {\n            tapKeySeq LSA-right\n            tapKey backspace\n            setVar count ($count - 1)\n        }\n    }\n    // LINE (4)\n    if ($lastMotion == 4) {\n        while ($count > 0) {\n            tapKey LG-left\n            tapKeySeq LSG-right\n            tapKey backspace\n            tapKey backspace\n            setVar count ($count - 1)\n        }\n    }\n    // TO_EOL (5)\n    if ($lastMotion == 5) {\n        while ($count > 0) {\n            tapKeySeq LSG-right\n            tapKey backspace\n            setVar count ($count - 1)\n        }\n    }\n    // DOWN (6)\n    if ($lastMotion == 6) {\n        while ($count > 0) {\n            tapKey LG-left\n            tapKeySeq LSG-right LS-down\n            tapKey backspace\n            setVar count ($count - 1)\n        }\n    }\n    // UP (7)\n    if ($lastMotion == 7) {\n        while ($count > 0) {\n            tapKey up\n            tapKey LG-left\n            tapKeySeq LSG-right LS-down\n            tapKey backspace\n            setVar count ($count - 1)\n        }\n    }\n    // LEFT (8)\n    if ($lastMotion == 8) {\n        while ($count > 0) {\n            tapKeySeq LS-left\n            tapKey backspace\n            setVar count ($count - 1)\n        }\n    }\n    // RIGHT (9)\n    if ($lastMotion == 9) {\n        while ($count > 0) {\n            tapKeySeq LS-right\n            tapKey backspace\n            setVar count ($count - 1)\n        }\n    }\n}"
```

**Step 2: Commit**

```bash
git add uhk/UserConfiguration.json
git commit -m "feat(vim): expand dot-repeat to handle all motion IDs"
```

---

### Task 10: Final review commit

**Step 1: Review the full diff**

```bash
git diff HEAD~9..HEAD -- uhk/UserConfiguration.json
```

Verify:
- All 8 modified macros have the correct operator/count/lastChange pattern
- Motion IDs are consistent between motions and dot-repeat
- No JSON syntax errors (valid JSON)

**Step 2: Validate JSON**

```bash
python3 -c "import json; json.load(open('uhk/UserConfiguration.json'))"
```

Expected: no output (valid JSON).

**Step 3: Squash into a single commit (optional, user preference)**

If desired:

```bash
git rebase -i HEAD~9
```

Mark all but the first as `squash`, use message: `feat(vim): convert all motions to state-based delete pattern`
