# VimMode Visual Mode State-Based Overhaul

## Goal

Convert visual mode from a layer-toggling approach (fn2) to a state-variable-driven system using `$mode`, mirroring the state-based delete pattern. Support character visual (v), visual-line (V), operators on selection, count support, and LED feedback.

## State Variables

Reuses existing variables from `$onInit`:

- `$mode` — 0=NORMAL, 1=INSERT, **2=VISUAL**, **3=VISUAL LINE** (2 and 3 are new active values)
- `$operator` — unchanged (0=NONE, 1=DELETE)
- `$count` — unchanged, works in visual mode for counted motions

No new variables needed.

## Mode Transitions

| From | Action | To | Side effects |
|------|--------|----|-------------|
| NORMAL (0) | Press `v` | VISUAL (2) | LED → orange |
| NORMAL (0) | Press `V` (Shift+v) | V-LINE (3) | Select current line, LED → red |
| VISUAL (2) | Press `v` | NORMAL (0) | Tap right (deselect), LED → default |
| VISUAL (2) | Press `V` | V-LINE (3) | Extend to full lines, LED → red |
| VISUAL (2) | Press `Esc` | NORMAL (0) | Tap right (deselect), LED → default |
| VISUAL (2) | Press operator (d/x/y/p) | NORMAL (0) | Act on selection, LED → default |
| V-LINE (3) | Press `V` | NORMAL (0) | Tap right (deselect), LED → default |
| V-LINE (3) | Press `v` | VISUAL (2) | LED → orange |
| V-LINE (3) | Press `Esc` | NORMAL (0) | Tap right (deselect), LED → default |
| V-LINE (3) | Press operator (d/x/y/p) | NORMAL (0) | Act on selection, LED → default |

## Motion Macro Template

Each motion macro gains `$mode` checks at the top, before existing `$operator` and normal branches:

```
// VISUAL LINE mode: horizontal motions are no-ops, j/k extend by line
if ($mode == 3)
{
    // only j and k do anything; all others are no-ops
    // (j example):
    if ($count > 0)
    {
        while ($count > 0)
        {
            tapKey LS-down
            setVar count ($count - 1)
        }
        setVar count 0
    }
    else
    {
        autoRepeat tapKey LS-down
    }
}
// VISUAL mode: shift+motion to extend character selection
else if ($mode == 2)
{
    if ($count > 0)
    {
        while ($count > 0)
        {
            <SHIFT_VERSION_OF_MOTION>
            setVar count ($count - 1)
        }
        setVar count 0
    }
    else
    {
        autoRepeat <SHIFT_VERSION_OF_MOTION>
    }
}
// DELETE operator (existing)
else if ($operator == 1)
{
    ... existing delete logic unchanged ...
}
// NORMAL motion (existing)
else
{
    ... existing normal logic unchanged ...
}
```

## Motion Shift Mappings

| Motion | Normal keystroke | Visual (Shift) keystroke | V-Line behavior |
|--------|-----------------|------------------------|-----------------|
| word (w) | `LA-right right` | `LSA-right LS-right` | no-op |
| back (b) | `LA-left` | `LSA-left` | no-op |
| end (e) | `LA-right` | `LSA-right` | no-op |
| down (j) | `down` | `LS-down` | `LS-down` |
| up (k) | `up` | `LS-up` | `LS-up` |
| left (h) | `left` | `LS-left` | no-op |
| right (l) | `right` | `LS-right` | no-op |

## Entry/Exit Macros

### `[vim] VISUAL` (v key) — rewrite

```
if ($mode == 2)
{
    // exit visual: deselect, return to normal
    tapKey right
    setVar mode 0
    setVar operator 0
    setVar count 0
    set backlight.strategy constantRgb
    set backlight.constantRgb.rgb 255 192 32
}
else if ($mode == 3)
{
    // switch from V-LINE to character visual
    setVar mode 2
    set backlight.strategy constantRgb
    set backlight.constantRgb.rgb 255 128 0
}
else
{
    // enter visual mode from normal
    setVar mode 2
    setVar operator 0
    setVar count 0
    set backlight.strategy constantRgb
    set backlight.constantRgb.rgb 255 128 0
}
```

### `[vim] VISUAL LINE` (Shift+V) — new macro

```
if ($mode == 3)
{
    // exit V-LINE: deselect, return to normal
    tapKey right
    setVar mode 0
    setVar operator 0
    setVar count 0
    set backlight.strategy constantRgb
    set backlight.constantRgb.rgb 255 192 32
}
else if ($mode == 2)
{
    // switch from character visual to V-LINE
    // extend selection to full lines
    setVar mode 3
    set backlight.strategy constantRgb
    set backlight.constantRgb.rgb 255 0 0
}
else
{
    // enter V-LINE from normal: select current line
    suppressMods
    {
        tapKey LG-left
        tapKeySeq LSG-right
    }
    setVar mode 3
    setVar operator 0
    setVar count 0
    set backlight.strategy constantRgb
    set backlight.constantRgb.rgb 255 0 0
}
```

### `[vim] escape` — update

Add at the top:
```
if ($mode == 2 || $mode == 3)
{
    tapKey right
    setVar mode 0
    setVar operator 0
    setVar count 0
    set backlight.strategy constantRgb
    set backlight.constantRgb.rgb 255 192 32
}
```

## Operators in Visual Mode

All operators check for `$mode == 2 || $mode == 3` at the top and act on the existing selection.

### `[vim] DELETE` (d key)

Add at top:
```
if ($mode == 2 || $mode == 3)
{
    tapKey backspace
    setVar mode 0
    setVar operator 0
    setVar count 0
    set backlight.strategy constantRgb
    set backlight.constantRgb.rgb 255 192 32
}
```

### `[vim] delete` (x key)

Add at top:
```
if ($mode == 2 || $mode == 3)
{
    tapKey backspace
    setVar mode 0
    setVar count 0
    set backlight.strategy constantRgb
    set backlight.constantRgb.rgb 255 192 32
}
```

### `[vim] yank` (y key)

Add at top:
```
if ($mode == 2 || $mode == 3)
{
    suppressMods
    {
        tapKey LG-c
    }
    tapKey right
    setVar mode 0
    setVar count 0
    set backlight.strategy constantRgb
    set backlight.constantRgb.rgb 255 192 32
}
```

### `[vim] paste` (p key)

Add at top:
```
if ($mode == 2 || $mode == 3)
{
    suppressMods
    {
        tapKey LG-v
    }
    setVar mode 0
    setVar count 0
    set backlight.strategy constantRgb
    set backlight.constantRgb.rgb 255 192 32
}
```

## LED Feedback

| Mode | RGB | Color |
|------|-----|-------|
| NORMAL | 255 192 32 | Warm gold (existing default from $onInit) |
| VISUAL | 255 128 0 | Orange |
| VISUAL LINE | 255 0 0 | Red |

LED commands are issued only in entry/exit macros, not in motion macros.

## Scope

### Modified macros (13)
- `[vim] word` — add $mode == 2 and $mode == 3 branches
- `[vim] back` — same
- `[vim] end` — same
- `[vim] down` — same
- `[vim] up` — same
- `[vim] left` — same
- `[vim] right` — same
- `[vim] VISUAL` — rewrite: toggle $mode instead of toggleLayer fn2
- `[vim] DELETE` — add visual mode operator check
- `[vim] delete` (x) — add visual mode operator check
- `[vim] yank` — add visual mode check
- `[vim] paste` — add visual mode check
- `[vim] escape` — add visual mode exit
- `$onInit` — update mode comments

### New macros (1)
- `[vim] VISUAL LINE` — Shift+V entry/exit

### Unchanged
- Old `[vim] VISUAL *` macros — left as unused (no longer triggered)
- `[vim] .` dot-repeat — no visual mode replay
- `[vim] 0-9` count keys — work the same in visual mode
- `[vim] CHANGE` — deferred
- `[vim] g`, `[vim] insert`, `[vim] append`, `[vim] open`, `[vim] redo`, `[vim] undo`

## Deferred Work
- Visual mode indent/outdent (`>>` / `<<`)
- `gv` (reselect last visual selection)
- Visual mode go-to (gg/G with selection)
- CHANGE operator in visual mode (c replaces selection and enters insert)
