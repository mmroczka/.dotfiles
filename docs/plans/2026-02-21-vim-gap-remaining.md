# UHK Vim Mode: Remaining Gap Implementation Plan

## Status

Items 1-4 from the gap analysis are **done** (committed or ready to commit):
- `$` end of line (via `[vim] 4` ifShift)
- `^`/`0` start of line (via `[vim] 0` when count==0)
- `/` search (new `[vim] search` macro, index 84)
- `s` substitute (new `[vim] substitute` macro, index 85)

Items 15 (Visual `$`/`^`) are also done — handled by the `$mode == 2` checks added to `[vim] 0` and `[vim] 4`.

## Remaining: Fully Doable (Simple key sequences)

### Batch 2: Change operator + Join

#### 5. `C` — change to end of line
- **Macro:** Modify `[vim] CHANGE` (index 48)
- **Logic:** `ifShift → suppressMods tapKeySeq LSG-right, suppressMods tapKey backspace, switchKeymap MIK`
- **Notes:** Parallels `D` in `[vim] DELETE`. Add as an `ifShift` block before the existing `ifGesture w`.

#### 6. `cc` — change entire line
- **Macro:** Modify `[vim] CHANGE` (index 48)
- **Logic:** `ifGesture c → suppressMods tapKey LG-left, suppressMods tapKeySeq LSG-right, suppressMods tapKey backspace, switchKeymap MIK`
- **Notes:** Select full line, delete contents, enter insert mode. Add as `ifGesture c` alongside existing `ifGesture w`.

#### 7. `J` — join lines
- **Macro:** New macro `[vim] join` (next available index)
- **Logic:** `suppressMods tapKeySeq LG-right delete`
- **Wire:** Vim Mode keymap, `j` key with Shift. Since `j` is currently `[vim] down` (index 51), need to add `ifShift` handling to `[vim] down` — or create a separate macro on a Shift layer.
- **Decision needed:** Handle via `ifShift` in existing `[vim] down` macro (simpler) or via a new macro on a Shift-mapped layer position.

#### 19. `S` — substitute line
- **Macro:** Modify `[vim] substitute` (index 85) or create separate
- **Logic:** `ifShift → suppressMods tapKey LG-left, suppressMods tapKeySeq LSG-right, suppressMods tapKey backspace, switchKeymap MIK`
- **Notes:** Could add `ifShift` to existing `[vim] substitute`. Same as `cc` but triggered differently.

### Batch 3: Scrolling

#### 8. `Ctrl+d` — half page down
- **Macro:** New macro `[vim] halfPageDown`
- **Logic:** Loop `tapKey down` 15 times using `repeatFor`
- **Wire:** Vim Mode keymap, need Ctrl+d binding. Options: use `fn` layer for Ctrl combos, or add `ifCtrl` check to `[vim] DELETE`.
- **Decision needed:** How to wire Ctrl+key combos in Vim Mode keymap (Ctrl layer? fn layer? ifCtrl in existing macro?)

#### 9. `Ctrl+u` — half page up
- **Macro:** New macro `[vim] halfPageUp`
- **Logic:** Loop `tapKey up` 15 times using `repeatFor`
- **Wire:** Same wiring question as Ctrl+d.

#### 10. `Ctrl+f` — page down
- **Macro:** New macro `[vim] pageDown`
- **Logic:** `tapKey pageDown`
- **Wire:** Same Ctrl-key wiring question.

#### 11. `Ctrl+b` — page up
- **Macro:** New macro `[vim] pageUp`
- **Logic:** `tapKey pageUp`
- **Wire:** Same Ctrl-key wiring question.

### Batch 4: Indent/Outdent

#### 12. `<<` — outdent
- **Macro:** New macro `[vim] outdent`
- **Logic:** `ifGesture $thisKeyId final suppressMods tapKey LSG-openBracket` + fallback (hold `<` or pass through)
- **Wire:** Vim Mode keymap, `,` key with Shift (since `<` = Shift+`,`). Needs `ifShift` to distinguish `<` from `,`.
- **Notes:** Visual mode variant (#16) should also indent selection — check `$mode` to skip line-select logic when selection exists.

#### 13. `>>` — indent
- **Macro:** New macro `[vim] indent`
- **Logic:** `ifGesture $thisKeyId final suppressMods tapKey LSG-closeBracket` + fallback
- **Wire:** Vim Mode keymap, `.` key with Shift (since `>` = Shift+`.`). But `.` is already `[vim] .` (dot repeat). Needs `ifShift` added to `[vim] .` macro.
- **Notes:** Same visual mode consideration as #12.

#### 16. Visual `<<`/`>>` — indent/outdent selection
- **Handled by:** #12 and #13 if they check `$mode == 2 || $mode == 3` and fire indent/outdent without the gesture requirement.

### Batch 5: Yank operator

#### 14. `yw`/`yb`/`yh`/`yl` — yank with motions
- **Macro:** Modify all motion macros (`[vim] word`, `[vim] back`, `[vim] end`, `[vim] left`, `[vim] right`, `[vim] up`, `[vim] down`)
- **Logic:** Add `operator == 2` (YANK) handling alongside existing `operator == 1` (DELETE):
  - Select the motion range (same selection keystrokes as delete)
  - `tapKey LG-c` (copy)
  - `tapKey left` (deselect, cursor back to start)
  - Reset operator and count
- **Also modify:** `[vim] yank` macro — first `y` press sets `operator 2`, second `y` (via `ifGesture`) does yank-line.
- **Update `$onInit`:** Add comment for `operator 2 = YANK`.
- **Scope:** This is the largest single item — touches 7+ macros. Consider updating dot repeat (`[vim] .`) as a follow-up.

### Batch 6: Word search

#### 17. `#` — find word under cursor (forward)
- **Macro:** New macro `[vim] findWord`
- **Logic:** `suppressMods tapKeySeq LA-left LSA-right LG-c LG-f LG-v` then `tapKey enter`
- **Wire:** Vim Mode keymap, `3` key with Shift (since `#` = Shift+3). Add `ifShift` to `[vim] 3`.

#### 18. `*` — find word under cursor (backward)
- **Macro:** New macro `[vim] findWordBack`
- **Logic:** Same as #17 but end with `tapKey LS-enter` instead of `tapKey enter`
- **Wire:** Vim Mode keymap, `8` key with Shift (since `*` = Shift+8). Add `ifShift` to `[vim] 8`.

## Remaining: Complex (require next-key capture)

These require fundamentally different approaches from the simple macros above.

### 20. `r` — replace character
- **Approach:** Use `ifGesture` for common characters (a-z, 0-9, space, common symbols). Each character needs its own `ifGesture` line: `ifGesture <keyid> final { tapKey delete; tapKey <scancode> }`.
- **Limitation:** Can't capture every possible key. Cover the most common ~50 characters.
- **Wire:** New macro on `r` key.

### 21. `f` + char — find character on line
- **Approach:** Same `ifGesture` approach as `r`. For each target char: `ifGesture <keyid> final { repeat Cmd+F for char }`. Or simpler: set a variable, then use Cmd+F.
- **Alternative:** Just open Cmd+F (same as `/`) since macOS doesn't have true "find on line" — may not be worth the complexity.

### 22. `R` — replace mode (overtype)
- **Approach:** Dedicated keymap where every alpha key = `tapKey delete` + `tapKey <letter>`. Would require duplicating the full alphabet.
- **Complexity:** High. Low priority.

### 23. `dt` + char — delete till character
- **Depends on:** #21 (`f` implementation). Combines find-char with delete.
- **Complexity:** Very high. Skip unless #21 is implemented.

### 24. `;` — repeat last f/t
- **Depends on:** #21. Requires storing last `f` target in a variable and re-executing.
- **Complexity:** Medium once #21 exists.

## Not Doable in UHK

These require text inspection/transformation that firmware can't do:
- `~` toggle case
- `gU`/`gu` + motion (case change)
- `Ctrl+a`/`Ctrl+x` (increment/decrement number)
- Surround (`ys`/`cs`/`ds`)
- Notion-specific overrides

## Suggested Implementation Order

1. **Batch 2** (items 5, 6, 7, 19) — Change operator + Join. High value, low complexity.
2. **Batch 4** (items 12, 13, 16) — Indent/Outdent. Moderate complexity due to Shift-key wiring.
3. **Batch 3** (items 8, 9, 10, 11) — Scrolling. Blocked on Ctrl-key wiring decision.
4. **Batch 6** (items 17, 18) — Word search. Moderate complexity.
5. **Batch 5** (item 14) — Yank operator. Largest scope, touches many macros.
6. **Complex items** (20-24) — Only if the simpler items prove valuable in practice.
