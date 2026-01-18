# Chapter 1: Introduction

**Whisker Language Specification 1.0**
**Version:** 1.0.0
**Date:** December 29, 2025
**Status:** Draft

---

## 1.1 Purpose

This document specifies the Whisker Language Specification (WLS) version 1.0, a language for authoring interactive fiction and choice-based narratives. WLS defines the syntax, semantics, and runtime behavior that compliant implementations MUST follow.

The specification serves three audiences:

1. **Authors** writing interactive stories
2. **Implementers** building Whisker-compatible engines
3. **Tool developers** creating editors, validators, and converters

## 1.2 Scope

WLS specifies:

- **Syntax**: The textual representation of Whisker stories
- **Semantics**: The meaning and behavior of language constructs
- **API**: The Lua scripting interface for story logic
- **Formats**: Both text (`.ws`) and JSON representations
- **Compatibility**: Requirements for bi-directional platform compatibility

WLS does NOT specify:

- Presentation or rendering (implementation-specific)
- User interface design
- Network protocols
- Storage mechanisms beyond format definitions

## 1.3 Design Philosophy

WLS follows these core principles:

### 1.3.1 Prose First

Story content should read like prose, not code. Markup is minimal and unobtrusive.

```whisker
:: Garden
The garden is peaceful in the morning light.
You notice a small path leading into the woods.

+ [Follow the path] -> Woods
+ [Stay in the garden] -> GardenLater
```

### 1.3.2 Progressive Complexity

Simple stories require simple syntax. Advanced features are opt-in.

**Simple story:**
```whisker
:: Start
Hello, world!
+ [Continue] -> End

:: End
Goodbye!
```

**Complex story:**
```whisker
:: Start
$playerName = "Adventurer"
$gold = 100

Welcome, $playerName!
{ $gold >= 100 }
  You're quite wealthy.
{/}

+ { $gold >= 50 } [Buy sword] { $gold -= 50 } -> Shop
* [Look around] -> LookAround
```

### 1.3.3 Consistency

Language constructs follow predictable patterns:
- Lua-style operators throughout (`and`, `or`, `not`, `~=`)
- Unified API namespace (`whisker.*`)
- Consistent scoping rules

### 1.3.4 Portability

Stories written for WLS MUST produce identical behavior across all compliant implementations.

## 1.4 Notation Conventions

This specification uses RFC 2119 keywords:

| Keyword | Meaning |
|---------|---------|
| **MUST** | Absolute requirement |
| **MUST NOT** | Absolute prohibition |
| **SHOULD** | Recommended but not required |
| **SHOULD NOT** | Discouraged but not prohibited |
| **MAY** | Optional |

### 1.4.1 Syntax Notation

Grammar is specified in Extended Backus-Naur Form (EBNF):

```ebnf
(* Terminal symbols in quotes *)
passage_marker = "::" ;

(* Non-terminals in lowercase *)
passage = passage_header , content ;

(* Optional: [ ] *)
choice = "+" , [ condition ] , choice_text , "->" , target ;

(* Repetition: { } *)
story = { passage } ;

(* Alternation: | *)
boolean = "true" | "false" ;
```

### 1.4.2 Code Examples

Code examples use the following format:

```whisker
// This is a code example
$variable = 42
```

Expected output or behavior is shown as:

> **Result:** The variable `$variable` is set to `42`.

### 1.4.3 Error Examples

Invalid syntax or error conditions are shown as:

```whisker
// INVALID: Missing target
+ [Choice text]
```

> **Error:** Choice missing navigation target.

## 1.5 Document Structure

The WLS specification is organized as follows:

| Chapter | Title | Content |
|---------|-------|---------|
| 1 | Introduction | This chapter |
| 2 | Core Concepts | Stories, passages, choices, state |
| 3 | Syntax | Complete syntax reference |
| 4 | Variables | Variable system and interpolation |
| 5 | Control Flow | Conditionals and alternatives |
| 6 | Choices | Choice system and navigation |
| 7 | Lua API | Complete API reference |
| 8 | File Formats | Text and JSON formats |
| 9 | Examples | Comprehensive code examples |
| 10 | Best Practices | Usage guidelines |
| A | Grammar | Formal EBNF grammar |
| B | Appendices | Reference tables |

## 1.6 Terminology

| Term | Definition |
|------|------------|
| **Story** | A complete interactive narrative |
| **Passage** | A discrete unit of narrative content |
| **Choice** | A player decision point |
| **Variable** | A named storage location for state |
| **Condition** | An expression that evaluates to true or false |
| **Alternative** | Dynamic text that varies on each encounter |
| **Engine** | Software that executes Whisker stories |
| **Author** | A person writing Whisker stories |

## 1.7 Conformance

### 1.7.1 Implementation Conformance

An implementation is **WLS conformant** if it:

1. Correctly parses all valid WLS syntax
2. Correctly rejects all invalid WLS syntax with appropriate errors
3. Implements all MUST requirements in this specification
4. Implements the complete `whisker.*` API
5. Produces identical output for the WLS test corpus

### 1.7.2 Story Conformance

A story is **WLS conformant** if it:

1. Uses only syntax defined in this specification
2. Uses only API functions defined in this specification
3. Produces consistent behavior across all conformant implementations

## 1.8 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12-29 | Initial release |

### 1.8.1 Compatibility Notes

WLS introduces breaking changes from previous Whisker implementations:

| Change | Migration |
|--------|-----------|
| `&&` → `and` | Replace all occurrences |
| `||` → `or` | Replace all occurrences |
| `!` → `not` | Replace all occurrences |
| `!=` → `~=` | Replace all occurrences |
| `{{var}}` → `$var` | Replace interpolation syntax |
| `game_state.*` → `whisker.state.*` | Update API calls |

A migration tool is provided to automate these changes.

## 1.9 Reference Implementations

Two reference implementations exist for WLS:

| Implementation | Language | Platform |
|----------------|----------|----------|
| whisker-core | Lua | CLI, Desktop, Embedded |
| whisker-editor-web | TypeScript | Web browsers |

Both implementations MUST produce identical behavior for all WLS stories.

## 1.10 Version Policy

The Whisker Language Specification follows semantic versioning (semver).

### 1.10.1 Version Number Format

`MAJOR.MINOR.PATCH` (e.g., 1.0.0, 1.1.0, 2.0.0)

### 1.10.2 Version Categories

| Type | When Incremented | Compatibility |
|------|------------------|---------------|
| **MAJOR** (1.x → 2.x) | Breaking changes to syntax or semantics | Stories MAY require migration |
| **MINOR** (1.0 → 1.1) | New features, additive changes | Fully backwards compatible |
| **PATCH** (1.0.0 → 1.0.1) | Clarifications, typo fixes, test additions | No behavioral changes |

### 1.10.3 Compatibility Guarantees

1. **Forward Compatibility**: Stories written for WLS 1.x will work with all WLS 1.x implementations
2. **Implementation Versioning**: Implementations SHOULD report the WLS version they target
3. **Feature Detection**: Stories MAY use `whisker.version()` to check runtime WLS version

### 1.10.4 Deprecation Policy

Features marked `@deprecated` in one MINOR version MAY be removed in the next MAJOR version. Deprecation warnings MUST be issued for at least one MINOR release before removal.

### 1.10.5 Version API

```lua
whisker.version()
-- Returns: { major = 1, minor = 0, patch = 0, string = "1.0.0" }
```

## 1.11 Quick Start Tutorial

This 5-minute tutorial gets you writing your first Whisker story.

### 1.11.1 Hello World

Create a file called `hello.ws`:

```whisker
:: Start
Hello, World!

+ [Continue] -> Goodbye

:: Goodbye
Thanks for playing!
-> END
```

This minimal story has two passages and one choice.

### 1.11.2 Adding Variables

```whisker
:: Start
$playerName = "Hero"
$gold = 100

Welcome, $playerName! You have $gold gold.

+ [Check inventory] -> Inventory
+ [Go adventuring] -> Adventure

:: Inventory
You have $gold gold pieces.
+ [Back] -> Start

:: Adventure
You found a treasure chest!
$gold += 50
Now you have $gold gold!
+ [Continue] -> Start
```

### 1.11.3 Adding Conditions

```whisker
:: Shop
@tags: commerce

$hasSword = false

Welcome to the shop!

{$gold >= 50}
  * {not $hasSword} [Buy sword - 50g] {$gold -= 50; $hasSword = true} -> Shop
{/}

{$gold < 50}
  You don't have enough gold for anything here.
{/}

+ [Leave] -> Town
```

### 1.11.4 Using Alternatives

```whisker
:: Tavern
The bartender {| nods at you | waves | ignores you }.

"What'll it be?" {&| he asks | she asks | they ask }.

{~| A bard plays softly. | Dice clatter in the corner. | Someone laughs loudly. }

+ [Order a drink] -> Order
+ [Leave] -> Town
```

### 1.11.5 Next Steps

You now know the basics:
- **Passages**: `:: Name` defines content blocks
- **Choices**: `+` for once-only, `*` for sticky
- **Variables**: `$name` for story-wide, `_name` for temporary
- **Conditions**: `{expr}...{/}` for conditional content
- **Alternatives**: `{| a | b | c }` for dynamic text
- **Navigation**: `-> Target` moves between passages

See [Chapter 9: Examples](09-EXAMPLES.md) for complete story examples.

## 1.12 Acknowledgments

WLS draws inspiration from:

- **Twine** (Harlowe, SugarCube, Chapbook story formats)
- **Ink** (inkle's narrative scripting language)
- **Lua** (scripting language)

---

**Next Chapter:** [Core Concepts](02-CORE_CONCEPTS.md)
