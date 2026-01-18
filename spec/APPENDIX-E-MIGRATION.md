# Appendix E: Migration Guide

**Whisker Language Specification 1.0**

---

## E.1 From whisker-core (Lua)

| Old Syntax | New Syntax (WLS) |
|------------|----------------------|
| `&&` | `and` |
| `||` | `or` |
| `!` | `not` |
| `!=` | `~=` |
| `whisker.state:get()` | `whisker.state.get()` |
| `whisker.state:set()` | `whisker.state.set()` |

**Migration regex patterns:**

```
/&&/g                    → and
/\|\|/g                  → or
/!(?!=)/g                → not
/!=/g                    → ~=
/whisker\.(\w+):/g       → whisker.$1.
```

## E.2 From whisker-editor-web (TypeScript)

| Old Syntax | New Syntax (WLS) |
|------------|----------------------|
| `{{variable}}` | `$variable` |
| `{{expression}}` | `${expression}` |
| `game_state.get()` | `whisker.state.get()` |
| `game_state.set()` | `whisker.state.set()` |
| `passages.current()` | `whisker.passage.current()` |

**Migration regex patterns:**

```
/\{\{(\w+)\}\}/g         → $$1
/\{\{(.+?)\}\}/g         → ${$1}  (for expressions)
/game_state\./g          → whisker.state.
/passages\./g            → whisker.passage.
```

## E.3 From Ink

| Ink | WLS | Notes |
|-----|-----|-------|
| `=== knot_name ===` | `:: KnotName` | Passage marker |
| `= stitch_name` | `:: KnotName_StitchName` | Flatten stitches |
| `* [Choice text]` | `+ [Choice text] -> Target` | Explicit target required |
| `+ [Sticky choice]` | `* [Sticky choice] -> Target` | Opposite markers |
| `-> target` | `-> Target` | Same syntax |
| `-> DONE` | `-> END` | Different keyword |
| `{variable}` | `$variable` | Variable syntax |
| `{condition: text}` | `{$condition}text{/}` | Block conditional |
| `~ variable = value` | `$variable = value` | Assignment |
| `VAR name = value` | `$name = value` | Declaration |
| `INCLUDE file.ink` | `@include: file.ws` | Include directive |
| `{~opt1\|opt2\|opt3}` | `{~\| opt1 \| opt2 \| opt3 }` | Shuffle |
| `{&opt1\|opt2\|opt3}` | `{&\| opt1 \| opt2 \| opt3 }` | Cycle |
| `{!opt1\|opt2\|opt3}` | `{!\| opt1 \| opt2 \| opt3 }` | Once-only |

**Key differences:**
- Ink uses `*` for once-only choices; WLS uses `+`
- Ink uses `+` for sticky choices; WLS uses `*`
- WLS requires explicit navigation targets
- Ink stitches must be flattened to passages
- WLS uses `$` prefix for all variables

## E.4 From Twine (Harlowe)

| Harlowe | WLS | Notes |
|---------|-----|-------|
| `::Passage Name` | `:: PassageName` | Space in marker |
| `[[Link text->Target]]` | `+ [Link text] -> Target` | Choice syntax |
| `[[Target]]` | `+ [Target] -> Target` | Simple link |
| `$variable` | `$variable` | Same |
| `(set: $var to value)` | `$var = value` | Assignment |
| `(if: $cond)[text]` | `{$cond}text{/}` | Conditional |
| `(else:)[text]` | `{else}text{/}` | Else clause |
| `(elseif: $cond)[text]` | `{elif $cond}text{/}` | Elif clause |
| `(either: a, b, c)` | `{~\| a \| b \| c }` | Random |
| `(cycling-link:)` | `{&\| a \| b \| c }` | Cycle |
| `(display: "Passage")` | `->-> Passage` | Tunnel call |
| `(print: $var)` | `$var` | Interpolation |

## E.5 From Twine (SugarCube)

| SugarCube | WLS | Notes |
|-----------|-----|-------|
| `::Passage Name` | `:: PassageName` | Space in marker |
| `[[Link->Target]]` | `+ [Link] -> Target` | Choice syntax |
| `<<set $var to value>>` | `$var = value` | Assignment |
| `<<if $cond>>` | `{$cond}` | Conditional open |
| `<</if>>` | `{/}` | Conditional close |
| `<<else>>` | `{else}` | Else clause |
| `<<elseif $cond>>` | `{elif $cond}` | Elif clause |
| `<<include "Passage">>` | `->-> Passage` | Tunnel call |
| `<<print $var>>` | `$var` | Interpolation |
| `$var` | `$var` | Same |
| `<<script>>` | `{{ lua code }}` | Embedded script |

## E.6 From ChoiceScript

| ChoiceScript | WLS | Notes |
|--------------|-----|-------|
| `*label name` | `:: Name` | Passage marker |
| `*choice` | Multiple `+` lines | Choice block |
| `#Option text` | `+ [Option text] -> Target` | Choice option |
| `*goto label` | `-> Label` | Navigation |
| `*goto_scene scene` | `@include` + `->` | Scene navigation |
| `*set var value` | `$var = value` | Assignment |
| `*create var value` | `$var = value` | Variable creation |
| `*if (condition)` | `{$condition}` | Conditional open |
| `*else` | `{else}` | Else clause |
| `*elseif (condition)` | `{elif $condition}` | Elif clause |
| `*finish` | `-> END` | End story |
| `${var}` | `$var` | Interpolation |
| `*page_break` | (implementation-specific) | No direct equivalent |
| `*line_break` | Blank line | Line break |
| `*gosub label` | `->-> Label` | Subroutine call |
| `*return` | `->->` (bare) | Return from subroutine |

**Key differences:**
- ChoiceScript is indentation-based; WLS uses explicit markers
- ChoiceScript `*choice` blocks must be flattened
- Stats screens require explicit implementation in WLS
- Fairmath operations need Lua implementation

## E.7 Migration Checklist

- [ ] Replace C-style operators with Lua-style
- [ ] Update variable interpolation syntax
- [ ] Update API namespace calls
- [ ] Change method calls from colon to dot notation
- [ ] Flatten nested structures (Ink stitches, CS indentation)
- [ ] Add explicit navigation targets to all choices
- [ ] Test all passages for correct behavior
- [ ] Validate against WLS schema
- [ ] Run test corpus

## E.8 Breaking Changes Summary

| Category | Change | Impact |
|----------|--------|--------|
| Operators | `&&`→`and`, `||`→`or`, `!`→`not`, `!=`→`~=` | All conditions |
| Variables | `{{var}}`→`$var` | All interpolation |
| API | `game_state`→`whisker.state` | All API calls |
| Methods | `:`→`.` | All method calls |

---

**Previous Appendix:** [Error Codes](APPENDIX-D-ERROR-CODES.md)
**Next Appendix:** [Glossary](APPENDIX-F-GLOSSARY.md)
