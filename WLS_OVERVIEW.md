# Whisker Language Specification (WLS)

**Status**: Final
**Generated**: 2026-01-12

---

## Executive Summary

The Whisker Language Specification (WLS) is a comprehensive interactive fiction authoring language designed for creating branching narratives. It provides a human-readable syntax for writing stories while supporting advanced features like variables, conditionals, Lua scripting, and presentation hooks.

**Important**: This specification is unified as simply "WLS" or "Whisker Language Specification." There are no version distinctions (1.0, 2.0, etc.) - all features including hooks are part of the single WLS specification.

### Design Philosophy

1. **Prose First**: Story text is the default; code is marked explicitly
2. **Progressive Complexity**: Simple stories need only simple syntax
3. **Consistency**: Similar constructs use similar syntax
4. **Portability**: Stories run identically across all conformant implementations

### Reference Implementations

| Implementation | Language | Platform |
|----------------|----------|----------|
| whisker-core | Lua | CLI, Desktop, Embedded |
| whisker-editor-web | TypeScript | Web browsers |

---

## Specification Status

The WLS specification is **complete and finalized** with:

| Component | Status | Documentation |
|-----------|--------|---------------|
| Core Syntax | Complete | 14 chapters |
| Formal Grammar | Complete | 411-line EBNF |
| Lua API | Complete | 6 namespaces |
| File Formats | Complete | .ws text, JSON |
| Error Codes | Complete | 56 codes |
| Test Corpus | Complete | 250+ cases |
| Examples | Complete | 8 categories |
| Best Practices | Complete | 7 sections |
| Hooks System | Complete | 5 operations |
| CSS Transitions | Complete | Browser only |
| Thread Integration | Complete | Timed content |

---

## Documents in This Directory

| Document | Purpose |
|----------|---------|
| [WLS_OVERVIEW.md](./WLS_OVERVIEW.md) | This document - specification overview |
| [WLS_QUICK_REFERENCE.md](./WLS_QUICK_REFERENCE.md) | Syntax cheat sheet |
| [GRAMMAR.ebnf](./GRAMMAR.ebnf) | Formal EBNF grammar (411 lines) |
| [HOOKS.md](./HOOKS.md) | Hooks system documentation |
| [COMPLETENESS.md](./COMPLETENESS.md) | Completeness assessment |

---

## Language Features Summary

### Story Structure

```whisker
@title: My Adventure
@author: Jane Doe
@start: Beginning

@vars
  gold: 100
  playerName: "Hero"
  hasKey: false

:: Beginning
Welcome to the adventure, $playerName!
You have $gold gold pieces.

+ [Go to the forest] -> Forest
+ [Visit the town] -> Town
```

### Variables

| Type | Syntax | Scope |
|------|--------|-------|
| Story Variable | `$varName` | Persistent across passages |
| Temp Variable | `_varName` | Current passage only |

```whisker
$gold = 100            // Assignment
$gold += 50            // Add-assign
$health -= 10          // Subtract-assign
_temp = $gold * 2      // Temporary
```

### Expressions

| Category | Examples |
|----------|----------|
| Arithmetic | `$gold + 50`, `$health * 2` |
| Comparison | `$gold >= 100`, `$level == 5` |
| Logical | `$hasKey and $hasMap`, `not $isLocked` |
| String | `"Hello " .. $name` |

### Operator Precedence

| Precedence | Operators |
|------------|-----------|
| 1 (highest) | `not`, unary `-` |
| 2 | `*`, `/`, `%` |
| 3 | `+`, `-`, `..` |
| 4 | `<`, `>`, `<=`, `>=` |
| 5 | `==`, `~=` |
| 6 | `and` |
| 7 (lowest) | `or` |

### Conditionals

**Block Conditional**:
```whisker
{ $hasKey }
  You unlock the door.
{elif $strength > 15}
  You break down the door.
{else}
  The door is locked.
{/}
```

**Inline Conditional**:
```whisker
The door is {$hasKey: unlocked | locked}.
```

### Text Alternatives

| Syntax | Behavior |
|--------|----------|
| `{\| a \| b \| c }` | Sequence: a, then b, then c forever |
| `{&\| a \| b \| c }` | Cycle: a, b, c, a, b, c... |
| `{~\| a \| b \| c }` | Shuffle: random each time |
| `{!\| a \| b \| c }` | Once-only: a, b, c, then nothing |

### Choices

```whisker
+ [Simple choice] -> Target
* [Sticky choice] -> Target
+ { $gold >= 50 } [Buy sword] -> Shop
+ [Take gold] { $gold += 100 } -> Next
```

| Marker | Behavior |
|--------|----------|
| `+` | Once-only: disappears after selection |
| `*` | Sticky: always available |

### Special Targets

| Target | Action |
|--------|--------|
| `-> PassageName` | Navigate to passage |
| `-> END` | End the story |
| `-> BACK` | Return to previous passage |
| `-> RESTART` | Restart from beginning |

### Embedded Lua

```whisker
// Inline Lua expression
$random = {{ math.random(1, 100) }}

// Block Lua code
{{
  local bonus = whisker.state.get("level") * 10
  whisker.state.set("gold", whisker.state.get("gold") + bonus)
}}
```

### Lua API Namespaces

| Namespace | Functions |
|-----------|-----------|
| `whisker.state` | get, set, has, delete, all, reset |
| `whisker.passage` | current, get, go, exists, all, tags |
| `whisker.history` | back, canBack, list, count, contains, clear |
| `whisker.choice` | available, select, count |
| `whisker.hook` | define, get, replace, append, prepend, show, hide |
| Top-level | visited, random, pick, print |

---

## Hooks System

The hooks system provides presentation layer control for dynamic content manipulation.

### Hook Definition

```whisker
|hookName>[This content can be modified]
```

### Hook Operations

| Operation | Syntax | Effect |
|-----------|--------|--------|
| Replace | `@replace: hookName { new content }` | Replace hook content |
| Append | `@append: hookName { additional }` | Add after hook content |
| Prepend | `@prepend: hookName { before }` | Add before hook content |
| Show | `@show: hookName` | Make hook visible |
| Hide | `@hide: hookName` | Make hook invisible |

### Example

```whisker
:: Room
|description>[The room is dark and quiet.]

+ [Light torch] { @replace: description { The room is illuminated. } } -> Room
+ [Look around] { @append: description { You see a door to the north. } } -> Room
```

See [HOOKS.md](./HOOKS.md) for complete documentation.

---

## File Formats

### Text Format (.ws)

Human-readable source format for authoring.

```whisker
@title: Adventure
@start: Start

:: Start
Welcome to the adventure!

+ [Begin] -> Chapter1
```

### JSON Format

Machine-readable format for runtime and storage.

```json
{
  "title": "Adventure",
  "start": "Start",
  "passages": [
    {
      "name": "Start",
      "content": "Welcome to the adventure!",
      "choices": [
        { "text": "Begin", "target": "Chapter1" }
      ]
    }
  ]
}
```

---

## Conformance Requirements

### Implementation Conformance

An implementation is **WLS conformant** if it:

1. Correctly parses all valid WLS syntax
2. Correctly rejects all invalid WLS syntax with appropriate errors
3. Implements all MUST requirements in the specification
4. Implements the complete `whisker.*` API
5. Produces identical output for the WLS test corpus

### Story Conformance

A story is **WLS conformant** if it:

1. Uses only syntax defined in the specification
2. Uses only API functions defined in the specification
3. Produces consistent behavior across all conformant implementations

---

## Error Codes

56 error codes across 10 categories:

| Category | Prefix | Description |
|----------|--------|-------------|
| Structure | STR | Story structure issues |
| Navigation | LNK | Links and navigation |
| Variables | VAR | Variable usage |
| Expressions | EXP | Expression syntax |
| Types | TYP | Type checking |
| Control Flow | FLW | Control flow issues |
| Quality | QUA | Quality metrics |
| Syntax | SYN | Parse errors |
| Assets | AST | Asset references |
| Metadata | META | Metadata issues |

---

## Source Documentation Location

The complete WLS specification resides in:

```
spec/
├── 01-INTRODUCTION.md       # Chapter 1
├── 02-CORE_CONCEPTS.md      # Chapter 2
├── 03-SYNTAX.md             # Chapter 3
├── 04-VARIABLES.md          # Chapter 4
├── 05-CONTROL_FLOW.md       # Chapter 5
├── 06-CHOICES.md            # Chapter 6
├── 07-LUA_API.md            # Chapter 7
├── 08-FILE_FORMATS.md       # Chapter 8
├── 09-EXAMPLES.md           # Chapter 9
├── 10-BEST_PRACTICES.md     # Chapter 10
├── 11-VALIDATION.md         # Chapter 11 (Error codes)
├── 12-MODULES.md            # Chapter 12
├── 13-PRESENTATION.md       # Chapter 13
├── 14-DEVELOPER-EXPERIENCE.md # Chapter 14
├── APPENDICES.md            # Appendices A-G
└── APPENDIX-A-ERROR-CODES.md # Error codes reference
```

Supporting files in root:
- `GRAMMAR.ebnf` - Formal grammar (411 lines)
- `HOOKS.md` - Hooks system documentation
- `WLS_OVERVIEW.md` - This overview document

**Note**: WLS is a unified specification with no version distinctions.
