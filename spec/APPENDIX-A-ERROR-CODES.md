# Appendix A: Error Codes Reference

This appendix provides a comprehensive reference for all WLS error codes.

## Error Code Format

All WLS error codes follow the format:

```
WLS-{CATEGORY}-{NUMBER}
```

Where:
- `WLS` - Whisker Language Specification prefix
- `{CATEGORY}` - Three-letter category code
- `{NUMBER}` - Three-digit error number (001-999)

## Categories

| Code | Category | Description |
|------|----------|-------------|
| STR | Structure | Story structure and organization |
| LNK | Links | Passage links and navigation |
| VAR | Variables | Variable declarations and usage |
| EXP | Expressions | Expression syntax and evaluation |
| FLW | Flow | Story flow and logic |
| QUA | Quality | Code quality and best practices |
| SYN | Syntax | General syntax errors |
| AST | Assets | Media and asset handling |
| META | Metadata | Story metadata |
| SCR | Scripts | Script blocks and Lua code |
| COL | Collections | LIST, ARRAY, MAP declarations |
| MOD | Modules | INCLUDE, FUNCTION, NAMESPACE |
| PRS | Presentation | Rich text, CSS, media, theming |
| DEV | Developer | Developer tools and debugging |

## Severity Levels

| Level | Description | Exit Code |
|-------|-------------|-----------|
| error | Must be fixed, prevents execution | 1 |
| warning | Should be fixed, may cause issues | 0 |
| info | Informational, best practices | 0 |

---

## Structure (STR)

### WLS-STR-001: missing_start_passage

**Severity:** error

**Message:** No start passage defined

**Description:** Every story must have a passage named "Start" or specify a start passage via `@start:` directive.

**Example (invalid):**
```whisker
@title: My Story

:: Chapter1
You begin your journey...
```

**Fix:**
```whisker
@title: My Story

:: Start
You begin your journey...
```

Or use the `@start:` directive:
```whisker
@title: My Story
@start: Chapter1

:: Chapter1
You begin your journey...
```

---

### WLS-STR-002: unreachable_passage

**Severity:** warning

**Message:** Passage "{passageName}" is unreachable

**Description:** This passage cannot be reached from the start passage through any path of choices.

**Example:**
```whisker
:: Start
Welcome!
+ [Continue] -> Chapter1

:: Chapter1
The adventure begins.

:: SecretEnding
-- This passage has no links pointing to it
You found the secret!
```

**Fix:** Either add a link to the passage or remove it if unused.

---

### WLS-STR-003: duplicate_passage

**Severity:** error

**Message:** Duplicate passage name: "{passageName}"

**Description:** Multiple passages have the same name.

**Example (invalid):**
```whisker
:: Start
First passage.

:: Start
Duplicate passage!
```

**Fix:** Give each passage a unique name.

---

### WLS-STR-004: empty_passage

**Severity:** warning

**Message:** Passage "{passageName}" is empty

**Description:** This passage has no content and no choices.

**Example:**
```whisker
:: EmptyRoom
```

**Fix:** Add content or choices, or remove the passage.

---

### WLS-STR-005: orphan_passage

**Severity:** info

**Message:** Passage "{passageName}" has no incoming links

**Description:** No other passages link to this passage (except if it's the start passage).

---

### WLS-STR-006: no_terminal

**Severity:** info

**Message:** Story has no terminal passages

**Description:** The story has no passages that end the story (via `-> END` or having no choices).

---

## Links (LNK)

### WLS-LNK-001: dead_link

**Severity:** error

**Message:** Choice links to non-existent passage: "{targetPassage}"

**Description:** The target passage does not exist in the story.

**Example (invalid):**
```whisker
:: Start
+ [Go to shop] -> Shopp
```

**Fix:**
```whisker
:: Start
+ [Go to shop] -> Shop

:: Shop
Welcome to the shop!
```

---

### WLS-LNK-002: self_link_no_change

**Severity:** warning

**Message:** Choice links to same passage without state change

**Description:** This choice links back to the same passage without any action, potentially causing an infinite loop.

**Example:**
```whisker
:: Loop
You are stuck.
+ [Try again] -> Loop
```

**Fix:** Add a state change or use a different target:
```whisker
:: Loop
You are stuck.
+ [Try again] {do $attempts += 1} -> Loop
```

---

### WLS-LNK-003: special_target_case

**Severity:** warning

**Message:** Special target "{actual}" should be "{expected}"

**Description:** Special targets (END, BACK, RESTART) must be uppercase.

**Example (invalid):**
```whisker
+ [End game] -> end
```

**Fix:**
```whisker
+ [End game] -> END
```

---

### WLS-LNK-004: back_on_start

**Severity:** warning

**Message:** BACK used on start passage

**Description:** Using BACK on the start passage has no effect since there's no history.

---

### WLS-LNK-005: empty_choice_target

**Severity:** error

**Message:** Choice has no target

**Description:** Every choice must have a target passage or special target.

---

## Variables (VAR)

### WLS-VAR-001: undefined_variable

**Severity:** error

**Message:** Undefined variable: "{variableName}"

**Description:** This variable is used before it is defined.

**Example (invalid):**
```whisker
:: Start
You have ${gold} gold.
```

**Fix:**
```whisker
@vars
  $gold = 100
@/vars

:: Start
You have ${gold} gold.
```

---

### WLS-VAR-002: unused_variable

**Severity:** warning

**Message:** Unused variable: "{variableName}"

**Description:** This variable is declared but never used.

---

### WLS-VAR-003: invalid_variable_name

**Severity:** error

**Message:** Invalid variable name: "{variableName}"

**Description:** Variable names must start with a letter or underscore and contain only alphanumerics.

---

### WLS-VAR-004: reserved_prefix

**Severity:** warning

**Message:** Variable uses reserved prefix: "{variableName}"

**Description:** Variables starting with "whisker_" or "__" are reserved.

---

### WLS-VAR-005: shadowing

**Severity:** warning

**Message:** Temporary variable shadows story variable: "{variableName}"

**Description:** A temp variable (`$_var`) has the same name as a story variable (`$var`).

---

### WLS-VAR-006: lone_dollar

**Severity:** warning

**Message:** Lone $ not followed by variable name

**Description:** A `$` character appears but is not followed by a valid variable name.

---

### WLS-VAR-007: unclosed_interpolation

**Severity:** error

**Message:** Unclosed expression interpolation

**Description:** An expression interpolation `${` is not closed with `}`.

---

### WLS-VAR-008: temp_cross_passage

**Severity:** error

**Message:** Temp variable used in different passage: "{variableName}"

**Description:** Temporary variables (`$_var`) are only valid within the passage where they are defined.

---

## Expressions (EXP)

### WLS-EXP-001: empty_expression

**Severity:** error

**Message:** Empty expression

**Description:** An expression block `${}` or condition `{}` is empty.

---

### WLS-EXP-002: unclosed_block

**Severity:** error

**Message:** Unclosed conditional block

**Description:** A conditional block `{` is not closed with `{/}`.

---

### WLS-EXP-003: assignment_in_condition

**Severity:** warning

**Message:** Assignment in condition (did you mean ==?)

**Description:** Single `=` (assignment) used in a condition where `==` (comparison) was likely intended.

---

### WLS-EXP-004: missing_operand

**Severity:** error

**Message:** Missing operand in expression

**Description:** A binary operator is missing an operand.

---

### WLS-EXP-005: invalid_operator

**Severity:** error

**Message:** Invalid operator: "{operator}"

**Description:** An unknown or invalid operator is used.

---

### WLS-EXP-006: unmatched_parenthesis

**Severity:** error

**Message:** Unmatched parenthesis

**Description:** Parentheses are not balanced.

---

### WLS-EXP-007: incomplete_expression

**Severity:** error

**Message:** Incomplete expression

**Description:** Expression is syntactically incomplete.

---

## Flow (FLW)

### WLS-FLW-001: dead_end

**Severity:** info

**Message:** Passage "{passageName}" is a dead end

**Description:** This passage has no choices and is not a terminal passage.

---

### WLS-FLW-002: bottleneck

**Severity:** info

**Message:** Passage "{passageName}" is a bottleneck

**Description:** All paths through the story must pass through this passage.

---

### WLS-FLW-003: cycle_detected

**Severity:** info

**Message:** Story contains cycles

**Description:** The story contains cycles (loops back to earlier passages).

---

### WLS-FLW-004: infinite_loop

**Severity:** warning

**Message:** Potential infinite loop in "{passageName}"

**Description:** A potential infinite loop exists with no exit condition.

---

### WLS-FLW-005: unreachable_choice

**Severity:** warning

**Message:** Choice condition is always false

**Description:** This choice can never be selected because its condition is always false.

---

### WLS-FLW-006: always_true_condition

**Severity:** info

**Message:** Choice condition is always true

**Description:** This choice condition is always true and could be simplified.

---

## Quality (QUA)

### WLS-QUA-001: low_branching

**Severity:** info

**Message:** Low branching factor ({value})

**Description:** Average choices per passage is below threshold.

---

### WLS-QUA-002: high_complexity

**Severity:** info

**Message:** High story complexity

**Description:** Story complexity score exceeds threshold.

---

### WLS-QUA-003: long_passage

**Severity:** info

**Message:** Passage "{passageName}" is very long ({wordCount} words)

**Description:** This passage exceeds the word count threshold.

---

### WLS-QUA-004: deep_nesting

**Severity:** warning

**Message:** Deep conditional nesting ({depth} levels)

**Description:** Conditional nesting exceeds recommended depth.

---

### WLS-QUA-005: many_variables

**Severity:** info

**Message:** Story has many variables ({count})

**Description:** Story has more variables than threshold.

---

## Syntax (SYN)

### WLS-SYN-001: syntax_error

**Severity:** error

**Message:** Syntax error in "{passageName}"

**Description:** Parse error in passage content.

---

### WLS-SYN-002: unmatched_braces

**Severity:** error

**Message:** Unmatched braces in stylesheet

**Description:** Opening and closing braces are not balanced.

---

### WLS-SYN-003: unmatched_keywords

**Severity:** error

**Message:** Unmatched Lua keywords

**Description:** Lua keywords like `function`/`end` or `if`/`then` are not balanced.

---

## Assets (AST)

### WLS-AST-001 through WLS-AST-007

Asset-related errors for missing IDs, paths, broken references, and unused assets.

---

## Metadata (META)

### WLS-META-001 through WLS-META-005

Metadata errors for missing or invalid IFID, dimensions, and reserved keys.

---

## Scripts (SCR)

### WLS-SCR-001 through WLS-SCR-004

Script errors for empty scripts, syntax errors, unsafe functions, and large scripts.

---

## Collections (COL) - WLS Gap 3

### WLS-COL-001: duplicate_list_value

**Severity:** error

**Message:** Duplicate value "{value}" in LIST "{listName}"

**Description:** LIST declarations cannot have duplicate values.

---

### WLS-COL-002 through WLS-COL-010

Collection errors for empty lists, invalid values, duplicate indices/keys, and undefined collections.

---

## Modules (MOD) - WLS Gap 4

### WLS-MOD-001: include_not_found

**Severity:** error

**Message:** Include file not found: "{path}"

**Description:** The file specified in INCLUDE directive does not exist.

---

### WLS-MOD-002 through WLS-MOD-008

Module errors for circular includes, undefined functions, namespace conflicts, and unmatched END NAMESPACE.

---

## Presentation (PRS) - WLS Gap 5

### WLS-PRS-001: invalid_markdown

**Severity:** error

**Message:** Invalid markdown syntax: {detail}

**Description:** The markdown formatting is malformed.

---

### WLS-PRS-002 through WLS-PRS-008

Presentation errors for invalid CSS classes, missing media, invalid themes, and style issues.

---

## Developer Experience (DEV) - WLS Gap 6

### WLS-DEV-001: lsp_connection_failed

**Severity:** error

**Message:** Failed to connect to language server

**Description:** The language server could not be started or connected to.

---

### WLS-DEV-002: debug_adapter_error

**Severity:** error

**Message:** Debug adapter protocol error: {detail}

**Description:** An error occurred in the debug adapter.

---

### WLS-DEV-003: format_parse_error

**Severity:** error

**Message:** Cannot format: file has parse errors

**Description:** The file cannot be formatted because it contains syntax errors.

---

### WLS-DEV-004: preview_runtime_error

**Severity:** warning

**Message:** Error during story preview: {detail}

**Description:** A runtime error occurred while previewing the story.

---

### WLS-DEV-005: breakpoint_invalid_location

**Severity:** warning

**Message:** Breakpoint at invalid location: line {line}

**Description:** A breakpoint was set at a location that cannot be executed.

---

## Error Message Format

WLS uses a standardized error message format:

```
WLS-XXX-NNN: Brief description at line L, column C

  L-2 | context line before
  L-1 | context line before
> L   | source line with error
           ^^^^
           Explanation of the error

Suggestion: How to fix
See: https://wls.whisker.dev/errors/WLS-XXX-NNN
```

### Example

```
WLS-LNK-001: Choice links to non-existent passage at line 5, column 8

  3 | Welcome to the adventure!
  4 |
> 5 | + [Go to shop] -> Shopp
                         ^^^^^
                         Passage "Shopp" does not exist

Suggestion: Did you mean "Shop"?
See: https://wls.whisker.dev/errors/WLS-LNK-001
```
