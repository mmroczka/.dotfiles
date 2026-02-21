# VimMode State-Based Delete Overhaul

## Goal

Convert the VimMode keymap from timeout/gesture-based operator-motion combos to variable-driven state, starting with the DELETE operator. All motions become operator-aware, support count, and record last-change for `.` repeat.

## State Variables (existing, defined in `$onInit`)

- `$operator` — 0=NONE, 1=DELETE (more operators later)
- `$count` — multi-digit accumulator (0-9 keys already work)
- `$lastOperator`, `$lastMotion`, `$lastCount` — for `.` repeat
- `$mode` — untouched for now (VISUAL mode deferred)

## Motion IDs

| ID | Name | Key | Normal action | Delete action |
|----|------|-----|---------------|---------------|
| 1 | WORD | w | `LA-right right` | `LSA-right LS-right` then `backspace` |
| 2 | BACK_WORD | b | `LA-left` | `LSA-left` then `backspace` |
| 3 | END_WORD | e | `LA-right` | `LSA-right` then `backspace` |
| 4 | LINE | dd | — | `LG-left`, `LSG-right`, `backspace`, `backspace` |
| 5 | TO_EOL | D | — | `LSG-right`, `backspace` |
| 6 | DOWN | j | `down` | `LG-left`, `LSG-right LS-down`, `backspace` |
| 7 | UP | k | `up` | `up`, `LG-left`, `LSG-right LS-down`, `backspace` |
| 8 | LEFT | h | `left` | `LS-left`, `backspace` |
| 9 | RIGHT | l | `right` | `LS-right`, `backspace` |

## Approach: Inline Operator Check

Every motion macro follows this template:

```
if ($operator == 1) {
    if ($count == 0) { setVar count 1 }
    setVar lastOperator 1
    setVar lastMotion <MOTION_ID>
    setVar lastCount $count
    while ($count > 0) {
        <SELECT_AND_DELETE_KEYSTROKES>
        setVar count ($count - 1)
    }
    setVar operator 0
    setVar count 0
}
else {
    if ($count > 0) {
        setVar lastOperator 0
        setVar lastMotion <MOTION_ID>
        setVar lastCount $count
        while ($count > 0) {
            <MOVE_KEYSTROKES>
            setVar count ($count - 1)
        }
        setVar count 0
    }
    else {
        autoRepeat <MOVE_KEYSTROKES>
    }
}
```

## DELETE Key Macro

Handles three cases:
1. **Shift+d (D)** — delete to end of line (motion 5), records for `.`
2. **d when operator already pending (dd)** — delete whole line (motion 4), records for `.`
3. **d otherwise** — sets `$operator = 1`

## Dot Repeat Macro

Dispatches on `$lastOperator == 1` with an if chain for each `$lastMotion` (1-9), replaying the exact delete keystrokes with `$lastCount`.

## Scope

### Modified (8 macros)
- `[vim] DELETE` — add dd/D handling
- `[vim] back` — full template (motion 2)
- `[vim] end` — full template (motion 3)
- `[vim] down` — full template (motion 6)
- `[vim] up` — full template (motion 7)
- `[vim] left` — full template (motion 8)
- `[vim] right` — full template (motion 9)
- `[vim] .` — full dispatch for motions 1-9

### Updated comments only (1 macro)
- `$onInit` — update lastMotion comments to list IDs 1-9

### Unchanged
- `[vim] word` — already converted (reference implementation)
- `[vim] delete` (lowercase x) — simple char delete
- `[vim] CHANGE`, `[vim] yank` — deferred
- `[vim] escape` — already resets state
- All `[vim] VISUAL *` macros — deferred
- `[vim] insert`, `append`, `open`, `paste`, `undo`, `redo`, `g`, `0-9`

## Deferred Work
- CHANGE operator (operator=2)
- YANK operator (operator=3)
- VISUAL mode state-based conversion
