# Appendices

**Whisker Language Specification 1.0**

---

## Appendix A: Keywords

### A.1 Reserved Keywords

These words are reserved and cannot be used as identifiers:

| Keyword | Category | Description |
|---------|----------|-------------|
| `and` | Logical | Logical AND operator |
| `or` | Logical | Logical OR operator |
| `not` | Logical | Logical NOT operator |
| `true` | Literal | Boolean true value |
| `false` | Literal | Boolean false value |
| `else` | Control | Else clause in conditionals |
| `elif` | Control | Else-if clause in conditionals |
| `END` | Navigation | Special target: end story |
| `BACK` | Navigation | Special target: go back |
| `RESTART` | Navigation | Special target: restart story |

### A.2 Contextual Keywords

These words have special meaning in specific contexts but may be used as identifiers:

| Keyword | Context | Description |
|---------|---------|-------------|
| `whisker` | Lua | API namespace |

### A.3 Directive Keywords

Used in story and passage headers:

| Directive | Context | Description |
|-----------|---------|-------------|
| `@title` | Story | Story title |
| `@author` | Story | Author name |
| `@version` | Story | Story version |
| `@ifid` | Story | Interactive Fiction ID |
| `@start` | Story | Start passage |
| `@description` | Story | Story description |
| `@created` | Story | Creation date |
| `@modified` | Story | Modification date |
| `@vars` | Story | Variable declarations block |
| `@tags` | Passage | Passage tags |
| `@color` | Passage | Editor color |
| `@position` | Passage | Editor position |
| `@notes` | Passage | Author notes |
| `@onEnter` | Passage | Entry script |
| `@onExit` | Passage | Exit script |
| `@fallback` | Passage | Fallback passage |

---

## Appendix B: Operator Reference

### B.1 Operator Precedence

From highest to lowest precedence:

| Level | Operators | Associativity | Description |
|-------|-----------|---------------|-------------|
| 1 | `not`, `-` (unary) | Right | Logical NOT, negation |
| 2 | `*`, `/`, `%` | Left | Multiplication, division, modulo |
| 3 | `+`, `-` | Left | Addition, subtraction |
| 4 | `..` | Right | String concatenation |
| 5 | `<`, `>`, `<=`, `>=` | Left | Comparison |
| 6 | `==`, `~=` | Left | Equality |
| 7 | `and` | Left | Logical AND |
| 8 | `or` | Left | Logical OR |

### B.2 Arithmetic Operators

| Operator | Operation | Example | Result |
|----------|-----------|---------|--------|
| `+` | Addition | `5 + 3` | `8` |
| `-` | Subtraction | `10 - 4` | `6` |
| `*` | Multiplication | `6 * 7` | `42` |
| `/` | Division | `15 / 4` | `3.75` |
| `%` | Modulo | `17 % 5` | `2` |
| `-` (unary) | Negation | `-5` | `-5` |

### B.3 Comparison Operators

| Operator | Operation | Example | Result |
|----------|-----------|---------|--------|
| `==` | Equal | `5 == 5` | `true` |
| `~=` | Not equal | `5 ~= 3` | `true` |
| `<` | Less than | `3 < 5` | `true` |
| `>` | Greater than | `5 > 3` | `true` |
| `<=` | Less or equal | `5 <= 5` | `true` |
| `>=` | Greater or equal | `5 >= 3` | `true` |

### B.4 Logical Operators

| Operator | Operation | Example | Result |
|----------|-----------|---------|--------|
| `and` | Logical AND | `true and false` | `false` |
| `or` | Logical OR | `true or false` | `true` |
| `not` | Logical NOT | `not true` | `false` |

### B.5 String Operators

| Operator | Operation | Example | Result |
|----------|-----------|---------|--------|
| `..` | Concatenation | `"Hello" .. " World"` | `"Hello World"` |

### B.6 Assignment Operators

| Operator | Operation | Example | Equivalent |
|----------|-----------|---------|------------|
| `=` | Assignment | `$x = 5` | - |
| `+=` | Add-assign | `$x += 3` | `$x = $x + 3` |
| `-=` | Subtract-assign | `$x -= 2` | `$x = $x - 2` |

---

## Appendix C: Escape Sequences

### C.1 String Escape Sequences

| Sequence | Character | Description |
|----------|-----------|-------------|
| `\\` | `\` | Backslash |
| `\"` | `"` | Double quote |
| `\n` | (newline) | Line feed |
| `\r` | (return) | Carriage return |
| `\t` | (tab) | Horizontal tab |

### C.2 Content Escape Sequences

| Sequence | Character | Description |
|----------|-----------|-------------|
| `\$` | `$` | Literal dollar sign |
| `\{` | `{` | Literal open brace |
| `\}` | `}` | Literal close brace |
| `\[` | `[` | Literal open bracket |
| `\]` | `]` | Literal close bracket |
| `\|` | `\|` | Literal pipe (in alternatives) |
| `\\` | `\` | Literal backslash |

---

## Appendix D: Error Codes

### D.1 Parse Errors

| Code | Name | Description |
|------|------|-------------|
| `E001` | INVALID_PASSAGE_NAME | Passage name doesn't follow naming rules |
| `E002` | DUPLICATE_PASSAGE | Multiple passages with same name |
| `E003` | UNTERMINATED_STRING | String literal not closed |
| `E004` | UNTERMINATED_COMMENT | Multi-line comment not closed |
| `E005` | INVALID_OPERATOR | Unknown or invalid operator |
| `E006` | UNEXPECTED_TOKEN | Unexpected token in input |
| `E007` | UNCLOSED_CONDITIONAL | Conditional block missing `{/}` |
| `E008` | ORPHAN_CLOSE | `{/}` without matching open |
| `E009` | ORPHAN_ELSE | `{else}` without conditional block |
| `E010` | INVALID_EXPRESSION | Malformed expression |

### D.2 Runtime Errors

| Code | Name | Description |
|------|------|-------------|
| `R001` | UNDEFINED_VARIABLE | Variable accessed before definition |
| `R002` | UNDEFINED_PASSAGE | Navigation to non-existent passage |
| `R003` | TYPE_MISMATCH | Operation on incompatible types |
| `R004` | DIVISION_BY_ZERO | Division or modulo by zero |
| `R005` | INVALID_ARGUMENT | Wrong argument type to function |
| `R006` | SHADOWING | Temp variable shadows story variable |
| `R007` | STACK_OVERFLOW | Too many nested calls |
| `R008` | TIMEOUT | Script execution timeout |

### D.3 Validation Errors

| Code | Name | Description |
|------|------|-------------|
| `V001` | MISSING_START | No start passage defined |
| `V002` | INVALID_TARGET | Choice targets non-existent passage |
| `V003` | NO_PASSAGES | Story contains no passages |
| `V004` | INVALID_IFID | IFID is not valid UUID format |
| `V005` | CIRCULAR_ONLY | Only circular navigation paths |

### D.4 Error Message Format

Implementations SHOULD format errors as:

```
Error [CODE] at line L, column C:
  MESSAGE

  CONTEXT_LINE
  ^^^^^ indicator

  Hint: SUGGESTION
```

**Example:**

```
Error [E001] at line 5, column 4:
  Invalid passage name: names cannot start with a digit

  :: 1stPassage
     ^^^^^^^^^^

  Hint: Passage names must start with a letter or underscore.
```

---

## Appendix E: Migration Guide

### E.1 From whisker-core (Lua)

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

### E.2 From whisker-editor-web (TypeScript)

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

### E.3 From Ink

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
| `{!opt1\|opt2\|opt3}` | `{\!\| opt1 \| opt2 \| opt3 }` | Once-only |

**Key differences:**
- Ink uses `*` for once-only choices; WLS uses `+`
- Ink uses `+` for sticky choices; WLS uses `*`
- WLS requires explicit navigation targets
- Ink stitches must be flattened to passages
- WLS uses `$` prefix for all variables

### E.4 From Twine (Harlowe)

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

### E.5 From Twine (SugarCube)

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

### E.6 From ChoiceScript

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

### E.7 Migration Checklist

- [ ] Replace C-style operators with Lua-style
- [ ] Update variable interpolation syntax
- [ ] Update API namespace calls
- [ ] Change method calls from colon to dot notation
- [ ] Flatten nested structures (Ink stitches, CS indentation)
- [ ] Add explicit navigation targets to all choices
- [ ] Test all passages for correct behavior
- [ ] Validate against WLS schema
- [ ] Run test corpus

### E.8 Breaking Changes Summary

| Category | Change | Impact |
|----------|--------|--------|
| Operators | `&&`→`and`, `||`→`or`, `!`→`not`, `!=`→`~=` | All conditions |
| Variables | `{{var}}`→`$var` | All interpolation |
| API | `game_state`→`whisker.state` | All API calls |
| Methods | `:`→`.` | All method calls |

---

## Appendix F: Glossary

| Term | Definition |
|------|------------|
| **Action Block** | Code in `{...}` after choice text that executes when choice is selected |
| **Alternative** | Dynamic text that varies based on visit count or randomization |
| **Author** | A person writing Whisker stories |
| **BOM** | Byte Order Mark - optional UTF-8 prefix (EF BB BF) that is tolerated but stripped |
| **Choice** | A player decision point that navigates to a target passage |
| **Choice Guard** | A condition `{expr}` before choice text that controls visibility |
| **Compound Assignment** | Operators like `+=`, `-=` that combine operation with assignment |
| **Condition** | An expression that evaluates to true or false |
| **Conformance** | Whether an implementation correctly follows the WLS specification |
| **Content** | Narrative text within a passage, rendered to the player |
| **Cycle** | An alternative type (`{&| }`) that loops through options forever |
| **Directive** | A metadata declaration starting with `@` (e.g., `@tags:`, `@onEnter:`) |
| **EBNF** | Extended Backus-Naur Form - notation for specifying grammar |
| **Engine** | Software that executes Whisker stories |
| **Escape Sequence** | Backslash-prefixed codes for special characters (e.g., `\n`, `\$`) |
| **Expression** | A combination of values, variables, and operators that produces a value |
| **Fallback** | A passage specified with `@fallback:` for when no choices are available |
| **History** | The stack of previously visited passages |
| **Hook** | A script that runs on passage entry (`@onEnter`) or exit (`@onExit`) |
| **IFID** | Interactive Fiction Identifier - a UUID uniquely identifying a story |
| **Implementation** | A software system that parses and executes WLS stories |
| **Inline Conditional** | Short-form conditional `{$cond: yes | no}` for inline text |
| **Interpolation** | Inserting variable or expression values into text using `$var` or `${expr}` |
| **Literal** | A fixed value written directly in code (number, string, boolean) |
| **LSP** | Language Server Protocol - standard for IDE language support |
| **Lua** | The scripting language used for embedded code in `{{ }}` blocks |
| **Navigation** | Moving from one passage to another using `->` or `->->` |
| **NFC** | Unicode Normalization Form C (Canonical Composition) |
| **Once-only Choice** | A choice marked with `+` that disappears after selection |
| **Passage** | A discrete unit of narrative content, marked with `:: Name` |
| **Passage Marker** | The `::` prefix that begins a passage definition |
| **Scope** | The visibility and lifetime of a variable (story or temporary) |
| **Sequence** | An alternative type (`{| }`) that progresses and stops at last option |
| **Shadowing** | When a temp variable uses the same name as a story variable (warning) |
| **Shuffle** | An alternative type (`{~| }`) that randomly selects options |
| **Special Target** | Reserved navigation targets: `END`, `BACK`, `RESTART` |
| **State** | The collection of variables tracking story progress |
| **Sticky Choice** | A choice marked with `*` that remains available after selection |
| **Story** | A complete interactive narrative |
| **Story-scoped** | Variables (prefix `$`) that persist across passages |
| **Tag** | A label attached to passages via `@tags:` for categorization |
| **Temporary** | Variables (prefix `_`) that exist only in current passage |
| **Test Oracle** | Expected output for conformance testing |
| **Truthiness** | How non-boolean values are evaluated in boolean context |
| **Tunnel** | A navigation pattern (`->->`) that returns to the calling passage |
| **UTF-8** | The required character encoding for WLS source files |
| **Visit Count** | The number of times a passage has been entered |
| **WLS** | Whisker Language Specification |

---

## Appendix G: Quick Reference Card

### G.1 Variable Syntax

```whisker
$storyVar = 100          // Story-scoped
_tempVar = 50            // Passage-scoped (temporary)

$gold += 10              // Compound assignment
$health -= 5

Hello, $name!            // Simple interpolation
Total: ${$a + $b}        // Expression interpolation
```

### G.2 Conditional Syntax

```whisker
// Block conditional
{ $condition }
  Content when true.
{elif $other}
  Other content.
{else}
  Default content.
{/}

// Inline conditional
The door is {$hasKey: open | closed}.
```

### G.3 Alternative Syntax

```whisker
{| First | Second | Third }      // Sequence (stops at last)
{&| A | B | C }                   // Cycle (loops forever)
{~| X | Y | Z }                   // Shuffle (random)
{!| One | Two | Three }           // Once-only (each once, then empty)
```

### G.4 Choice Syntax

```whisker
+ [Once-only choice] -> Target
* [Sticky choice] -> Target
+ { $condition } [Conditional] -> Target
+ [With action] { $gold -= 50 } -> Target
+ { $gold >= 50 } [Full syntax] { $gold -= 50 } -> Target
```

### G.5 Special Targets

```whisker
+ [End story] -> END
+ [Go back] -> BACK
+ [Restart] -> RESTART
```

### G.6 Passage Syntax

```whisker
:: PassageName
@tags: tag1, tag2
@color: #ff0000
@onEnter: whisker.state.set("visited", true)

Passage content here.

+ [Choice] -> Target
```

### G.7 Embedded Lua

```whisker
$x = {{ math.random(1, 6) }}     // Inline expression

{{                                // Block script
  local a = whisker.state.get("gold")
  whisker.state.set("gold", a + 100)
}}
```

### G.8 API Quick Reference

```lua
-- State
whisker.state.get(key)
whisker.state.set(key, value)
whisker.state.has(key)
whisker.state.delete(key)
whisker.state.all()
whisker.state.reset()

-- Passage
whisker.passage.current()
whisker.passage.get(id)
whisker.passage.go(id)
whisker.passage.exists(id)
whisker.passage.all()
whisker.passage.tags(tag)

-- History
whisker.history.back()
whisker.history.canBack()
whisker.history.list()
whisker.history.count()
whisker.history.contains(id)
whisker.history.clear()

-- Utilities
whisker.visited(passage?)
whisker.random(min, max)
whisker.pick(...)
whisker.print(...)
```

---

**Previous Chapter:** [Best Practices](10-BEST_PRACTICES.md)
