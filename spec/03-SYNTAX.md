# Chapter 3: Syntax

**Whisker Language Specification 1.0**

---

## 3.1 Overview

This chapter provides a complete reference for WLS syntax. It covers lexical structure, tokens, operators, expressions, statements, and all syntactic constructs.

## 3.2 Lexical Structure

### 3.2.1 Character Set

WLS source files MUST be encoded in UTF-8. All Unicode characters are permitted in:

- String literals
- Comments
- Passage content

Identifiers are restricted to ASCII characters.

### 3.2.2 Line Structure

Lines are terminated by:

- Line Feed (LF, `\n`) - Unix
- Carriage Return + Line Feed (CRLF, `\r\n`) - Windows
- Carriage Return (CR, `\r`) - Legacy Mac

Implementations MUST normalize all line endings.

### 3.2.3 Whitespace

| Character | Name | Code Point |
|-----------|------|------------|
| Space | SPACE | U+0020 |
| Tab | HORIZONTAL TAB | U+0009 |
| LF | LINE FEED | U+000A |
| CR | CARRIAGE RETURN | U+000D |

**Whitespace Significance:**

- **Significant**: Between tokens where required for separation
- **Insignificant**: Within expressions, around operators
- **Preserved**: In passage content and strings

```whisker
// Whitespace is insignificant in expressions
{ $gold>=50 }        // Valid
{ $gold >= 50 }      // Also valid (preferred)
{$gold   >=   50}    // Also valid

// Whitespace is preserved in content
The quick brown fox.    // Spaces preserved
```

### 3.2.4 Indentation

Indentation is **not semantically significant** in WLS. It is used for readability only.

```whisker
// Both are equivalent
{ $hasKey }
The door opens.
{/}

{ $hasKey }
  The door opens.
{/}
```

## 3.3 Comments

### 3.3.1 Single-Line Comments

Single-line comments begin with `//` and extend to the end of the line.

```whisker
// This is a comment
$gold = 100  // Inline comment
```

### 3.3.2 Multi-Line Comments

Multi-line comments begin with `/*` and end with `*/`.

```whisker
/* This is a
   multi-line comment */

$gold = /* inline */ 100
```

### 3.3.3 Comment Rules

- Comments MUST NOT nest
- Comments are stripped during parsing
- Comments MAY appear anywhere except within string literals

```whisker
// INVALID: Nested comments
/* outer /* inner */ still outer */

// VALID: Comment markers in strings
$text = "Use // for comments"
```

## 3.4 Tokens

### 3.4.1 Token Categories

| Category | Examples |
|----------|----------|
| Keywords | `and`, `or`, `not`, `true`, `false` |
| Identifiers | `playerName`, `_temp`, `gold` |
| Literals | `42`, `"hello"`, `true` |
| Operators | `+`, `-`, `==`, `>=` |
| Delimiters | `::`, `+`, `*`, `{`, `}`, `[`, `]` |
| Special | `$`, `_`, `->`, `{/}` |

### 3.4.2 Keywords

The following are reserved keywords:

| Keyword | Usage |
|---------|-------|
| `and` | Logical AND |
| `or` | Logical OR |
| `not` | Logical NOT |
| `true` | Boolean true |
| `false` | Boolean false |
| `else` | Else clause |
| `elif` | Else-if clause |

Keywords are case-sensitive and MUST NOT be used as identifiers.

### 3.4.3 Identifiers

Identifiers name variables and passages.

**Syntax:**
```ebnf
identifier = letter , { letter | digit | "_" } ;
letter = "a"..."z" | "A"..."Z" | "_" ;
digit = "0"..."9" ;
```

**Rules:**
- MUST start with a letter or underscore
- MAY contain letters, digits, and underscores
- Case-sensitive
- No length limit (implementations SHOULD support at least 255 characters)

**Valid:**
```
name
playerName
_private
item1
MAX_VALUE
```

**Invalid:**
```
1stItem      // Starts with digit
my-variable  // Contains hyphen
my variable  // Contains space
```

#### 3.4.3.1 Identifier Limits and Edge Cases

**Length Requirements:**
| Limit | Minimum | Recommended | Notes |
|-------|---------|-------------|-------|
| Identifier length | 255 chars | 1024 chars | Applies to all identifier types |
| Nested scope depth | 16 levels | 64 levels | Function call depth |
| Unique identifiers | 1,000 | 65,536 | Per compilation unit |

**Reserved Identifier Patterns:**

Identifiers matching these patterns have special meaning:
- `_` (single underscore): Discard placeholder, cannot be referenced
- `__*` (double underscore prefix): Reserved for implementation
- `*__` (double underscore suffix): Reserved for implementation

**Edge Cases:**

| Input | Behavior | Error Code |
|-------|----------|------------|
| Empty string `""` | Error | WLS-SYN-020 |
| Whitespace only | Error | WLS-SYN-020 |
| Starts with digit | Error | WLS-SYN-021 |
| Contains hyphen | Error | WLS-SYN-022 |
| Unicode letters | Error (ASCII only) | WLS-SYN-023 |
| Length > limit | Error | WLS-SYN-024 |
| Reserved keyword | Error | WLS-SYN-025 |
| `__reserved__` | Warning (reserved) | WLS-SYN-026 |

**Identifier Shadowing:**

Inner scopes may shadow outer scope identifiers:
```whisker
{let name = "outer"}
{passage inner}
  {let name = "inner"}  // Shadows outer 'name'
  {name}                // Outputs "inner"
{end}
{name}                  // Outputs "outer"
```

Implementations SHOULD emit a warning for shadowed identifiers when enabled.

### 3.4.4 Literals

#### Number Literals

```ebnf
number = integer | float ;
integer = [ "-" ] , digit , { digit } ;
float = [ "-" ] , digit , { digit } , "." , digit , { digit } ;
```

**Examples:**
```whisker
42        // Integer
-17       // Negative integer
3.14159   // Float
-0.5      // Negative float
0         // Zero
```

**Rules:**
- No octal or hexadecimal literals
- No scientific notation (1e10)
- No underscores in numbers (1_000)

#### String Literals

```ebnf
string = '"' , { string_char } , '"' ;
string_char = any_char - '"' - '\' | escape_sequence ;
```

**Examples:**
```whisker
"Hello, world!"
"Line 1\nLine 2"
"She said \"Hello\""
""                    // Empty string
```

**Rules:**
- Enclosed in double quotes only (no single quotes)
- May span multiple lines with escape sequences
- MUST escape internal double quotes

#### Boolean Literals

```ebnf
boolean = "true" | "false" ;
```

**Examples:**
```whisker
$hasKey = true
$isComplete = false
```

## 3.5 Operators

### 3.5.1 Arithmetic Operators

| Operator | Name | Example | Result |
|----------|------|---------|--------|
| `+` | Addition | `5 + 3` | `8` |
| `-` | Subtraction | `5 - 3` | `2` |
| `*` | Multiplication | `5 * 3` | `15` |
| `/` | Division | `5 / 2` | `2.5` |
| `%` | Modulo | `5 % 3` | `2` |
| `-` (unary) | Negation | `-5` | `-5` |

**Division Rules:**
- Division by zero MUST produce an error
- Integer division produces float if not evenly divisible

### 3.5.2 Comparison Operators

| Operator | Name | Example | Result |
|----------|------|---------|--------|
| `==` | Equal | `5 == 5` | `true` |
| `~=` | Not equal | `5 ~= 3` | `true` |
| `<` | Less than | `3 < 5` | `true` |
| `>` | Greater than | `5 > 3` | `true` |
| `<=` | Less or equal | `3 <= 3` | `true` |
| `>=` | Greater or equal | `5 >= 5` | `true` |

**Comparison Rules:**
- Numbers compared numerically
- Strings compared lexicographically (Unicode code points)
- Booleans: `false < true`
- Mixed types: MUST produce an error (no implicit coercion)

### 3.5.3 Logical Operators

| Operator | Name | Example | Result |
|----------|------|---------|--------|
| `and` | Logical AND | `true and false` | `false` |
| `or` | Logical OR | `true or false` | `true` |
| `not` | Logical NOT | `not true` | `false` |

**Short-Circuit Evaluation:**
- `and`: Returns first falsy operand or last operand
- `or`: Returns first truthy operand or last operand

```whisker
// Short-circuit examples
{ $x > 0 and $y / $x > 1 }   // Safe: $y/$x only evaluated if $x > 0
{ $default or $fallback }     // Returns $default if truthy
```

### 3.5.4 Assignment Operators

| Operator | Name | Example | Equivalent |
|----------|------|---------|------------|
| `=` | Assignment | `$x = 5` | - |
| `+=` | Add-assign | `$x += 5` | `$x = $x + 5` |
| `-=` | Subtract-assign | `$x -= 5` | `$x = $x - 5` |

### 3.5.5 String Operators

| Operator | Name | Example | Result |
|----------|------|---------|--------|
| `..` | Concatenation | `"a" .. "b"` | `"ab"` |

### 3.5.6 Operator Precedence

From highest to lowest:

| Precedence | Operators | Associativity |
|------------|-----------|---------------|
| 1 | `not`, unary `-` | Right |
| 2 | `*`, `/`, `%` | Left |
| 3 | `+`, `-`, `..` | Left |
| 4 | `<`, `>`, `<=`, `>=` | Left |
| 5 | `==`, `~=` | Left |
| 6 | `and` | Left |
| 7 | `or` | Left |

**Examples:**
```whisker
// Precedence examples
not $a and $b       // (not $a) and $b
$a or $b and $c     // $a or ($b and $c)
$a + $b * $c        // $a + ($b * $c)
$a == $b and $c     // ($a == $b) and $c
```

**Parentheses** override precedence:
```whisker
($a or $b) and $c   // Explicit grouping
```

## 3.6 Expressions

### 3.6.1 Expression Types

| Type | Example |
|------|---------|
| Literal | `42`, `"hello"`, `true` |
| Variable | `$gold`, `_temp` |
| Arithmetic | `$gold + 50` |
| Comparison | `$gold >= 100` |
| Logical | `$hasKey and $hasTorch` |
| Grouped | `($a + $b) * $c` |
| Function call | `whisker.random(1, 6)` |

### 3.6.2 Expression Grammar

```ebnf
expression = or_expr ;
or_expr = and_expr , { "or" , and_expr } ;
and_expr = equality_expr , { "and" , equality_expr } ;
equality_expr = comparison_expr , { ( "==" | "~=" ) , comparison_expr } ;
comparison_expr = additive_expr , { ( "<" | ">" | "<=" | ">=" ) , additive_expr } ;
additive_expr = multiplicative_expr , { ( "+" | "-" | ".." ) , multiplicative_expr } ;
multiplicative_expr = unary_expr , { ( "*" | "/" | "%" ) , unary_expr } ;
unary_expr = ( "not" | "-" ) , unary_expr | primary_expr ;
primary_expr = literal | variable | function_call | "(" , expression , ")" ;
```

### 3.6.3 Variable Expressions

```ebnf
variable = "$" , identifier | "_" , identifier ;
```

**Examples:**
```whisker
$playerName      // Story variable
$gold            // Story variable
_tempValue       // Temporary variable
```

### 3.6.4 Function Call Expressions

```ebnf
function_call = namespace , "." , identifier , "(" , [ arguments ] , ")" ;
arguments = expression , { "," , expression } ;
```

**Examples:**
```whisker
whisker.random(1, 10)
whisker.visited("Cave")
whisker.state.get("gold")
```

## 3.7 Statements

### 3.7.1 Assignment Statement

```ebnf
assignment = variable , assign_op , expression ;
assign_op = "=" | "+=" | "-=" ;
```

**Examples:**
```whisker
$gold = 100
$health -= 10
$score += $bonus
_temp = $gold * 2
```

### 3.7.2 Passage Declaration

```ebnf
passage_decl = "::" , identifier , newline , { directive } , content ;
directive = "@" , directive_name , ":" , directive_value , newline ;
```

**Examples:**
```whisker
:: MyPassage
Content here.

:: AnnotatedPassage
@tags: important, chapter1
@color: #ff0000
Content with metadata.
```

### 3.7.3 Choice Statement

```ebnf
choice = choice_marker , [ condition ] , "[" , choice_text , "]" , [ action ] , "->" , identifier ;
choice_marker = "+" | "*" ;
condition = "{" , expression , "}" ;
action = "{" , lua_code , "}" ;
```

**Examples:**
```whisker
+ [Simple choice] -> Target
* [Sticky choice] -> Target
+ { $gold >= 50 } [Buy item] -> Shop
+ [Take gold] { $gold += 100 } -> Next
+ { $hasKey } [Unlock] { $doorOpen = true } -> Inside
```

## 3.8 Conditional Blocks

### 3.8.1 Block Conditional

```ebnf
conditional = "{" , expression , "}" , content , [ else_clause ] , "{/}" ;
else_clause = "{else}" , content | "{elif" , expression , "}" , content , [ else_clause ] ;
```

**Examples:**
```whisker
// Simple if
{ $hasKey }
  You unlock the door.
{/}

// If-else
{ $gold >= 100 }
  You can afford it.
{else}
  You need more gold.
{/}

// If-elif-else
{ $health > 75 }
  You feel great!
{elif $health > 25}
  You're getting tired.
{else}
  You're badly wounded.
{/}
```

### 3.8.2 Inline Conditional

```ebnf
inline_conditional = "{" , expression , ":" , true_content , [ "|" , false_content ] , "}" ;
```

**Examples:**
```whisker
The door is {$hasKey: unlocked | locked}.
You have {$gold} gold {$gold == 1: piece | pieces}.
{$isNight: The moon shines. | The sun is bright.}
```

### 3.8.3 Brace Construct Disambiguation

The `{` character begins several constructs. Parsers distinguish them by lookahead:

| After `{` | Construct | Example |
|-----------|-----------|---------|
| `\|` | Alternative | `{\| a \| b }` |
| `$`/`_` then `:` then non-`:` | Inline conditional | `{$x: yes \| no}` |
| `$`/`_` then `=` | Action block | `{$x = 1}` |
| `@` | Hook operation | `{@show: name}` |
| identifier `:` value | Map literal | `{key: val}` |
| expression `}` newline | Conditional block | `{$flag}` |

**Parsing Strategy:**

1. Consume `{`
2. If next is `|`, parse as alternative
3. If next is `@`, parse as hook operation
4. Parse expression/identifier
5. Lookahead for `:`, `=`, `}`, or `|`
6. Dispatch based on lookahead

**Maximum Lookahead:** 3 tokens

**Examples:**
```whisker
{| a | b }              // Alternative (starts with |)
{$flag}                 // Conditional (variable + })
{$x: yes | no}          // Inline conditional (variable + :)
{$gold += 50}           // Action block (variable + =)
{key: "value"}          // Map literal (identifier + :)
```

## 3.9 Text Alternatives

### 3.9.1 Syntax

```ebnf
alternative = "{" , alt_type , "|" , alt_content , { "|" , alt_content } , "}" ;
alt_type = "" | "&" | "~" | "!" ;
```

### 3.9.2 Alternative Types

| Syntax | Type | Behavior |
|--------|------|----------|
| `{\| a \| b \| c }` | Sequence | Shows a, then b, then c, then stays on c |
| `{&\| a \| b \| c }` | Cycle | Shows a, b, c, a, b, c, ... |
| `{~\| a \| b \| c }` | Shuffle | Random selection each time |
| `{!\| a \| b \| c }` | Once-only | Shows a, then b, then c, then nothing |

**Examples:**
```whisker
// Sequence (stopping)
{| First visit. | Second visit. | You've been here many times. }

// Cycle
The light is {&| red | yellow | green }.

// Shuffle
You see {~| a bird | a squirrel | nothing | a shadow } in the trees.

// Once-only
{!| "Welcome!" | "Nice to see you again." | "Hello." }
```

### 3.9.3 Multi-line Alternatives

```whisker
{|
  | This is the first option
    with multiple lines.
  | This is the second option.
  | And the third.
}
```

## 3.10 Variable Interpolation

### 3.10.1 Simple Interpolation

```ebnf
simple_interpolation = "$" , identifier ;
```

**Example:**
```whisker
Hello, $playerName! You have $gold gold.
```

### 3.10.2 Expression Interpolation

```ebnf
expr_interpolation = "${" , expression , "}" ;
```

**Example:**
```whisker
Double gold: ${$gold * 2}
Random: ${whisker.random(1, 6)}
Total: ${$base + $bonus}
```

### 3.10.3 Interpolation Context

Interpolation is performed in:

- Passage content
- Choice text
- String literals (in Lua blocks)

Interpolation is NOT performed in:

- Comments
- Passage names
- Directive values

## 3.11 Escape Sequences

### 3.11.1 Escape Sequence Table

| Sequence | Result | Description |
|----------|--------|-------------|
| `\\` | `\` | Backslash |
| `\$` | `$` | Dollar sign (prevents interpolation) |
| `\{` | `{` | Open brace |
| `\}` | `}` | Close brace |
| `\[` | `[` | Open bracket |
| `\]` | `]` | Close bracket |
| `\n` | newline | Line feed |
| `\t` | tab | Horizontal tab |
| `\"` | `"` | Double quote (in strings) |

### 3.11.2 Examples

```whisker
// Escaping special characters
The price is \$50.           // Shows: The price is $50.
Use \{ and \} for blocks.    // Shows: Use { and } for blocks.
Path: C:\\Users\\Name        // Shows: Path: C:\Users\Name

// In strings
$message = "She said \"Hello\""
$path = "C:\\Program Files"
```

### 3.11.3 Context-Specific Escaping

| Context | Characters Requiring Escape |
|---------|---------------------------|
| Prose text | `$`, `{`, `}`, `\` |
| String literals | `"`, `\`, `$` |
| Choice text | `[`, `]`, `$`, `{`, `}` |
| Comments | None (no escaping needed) |

### 3.11.4 Unicode Escapes

```whisker
// Unicode code point escapes
$heart = "\u{2764}"      // ❤
$emoji = "\u{1F600}"     // 😀
$nbsp = "\u{00A0}"       // Non-breaking space

// Invalid Unicode escapes result in error WLS-SYN-004
$bad = "\u{GGGGGG}"      // Error: invalid hex
$bad = "\u{110000}"      // Error: code point > 10FFFF
```

### 3.11.5 Raw Strings

For content with many special characters, use raw strings:

```whisker
$regex = `\d+\.\d+`      // No escaping needed
$path = `C:\Users\Name`  // Backslashes literal
$json = `{"key": "value"}`  // Braces literal
```

### 3.11.6 Invalid Escapes

| Input | Behavior |
|-------|----------|
| `\x` (unknown) | Error WLS-SYN-004 |
| `\` at end of line | Line continuation |
| `\` at end of file | Error WLS-SYN-004 |

## 3.12 Embedded Lua

### 3.12.1 Inline Lua

```ebnf
inline_lua = "{{" , lua_code , "}}" ;
```

**Example:**
```whisker
$random = {{ math.random(1, 100) }}
$upper = {{ string.upper(whisker.state.get("name")) }}
```

### 3.12.2 Block Lua

```ebnf
block_lua = "{{" , newline , lua_code , newline , "}}" ;
```

**Example:**
```whisker
{{
  local bonus = 0
  if whisker.state.get("level") > 10 then
    bonus = 50
  end
  whisker.state.set("gold", whisker.state.get("gold") + bonus)
}}
```

### 3.12.3 Lua Sandboxing

Embedded Lua runs in a sandboxed environment:

**Available:**
- All standard Lua operators
- `math` library
- `string` library
- `table` library (limited)
- `whisker.*` API

**Not Available:**
- File I/O (`io`)
- Operating system (`os` except `os.time`, `os.date`)
- Debug library
- `load`, `loadfile`, `dofile`
- `require`

## 3.13 Navigation Syntax

### 3.13.1 Choice Navigation

```ebnf
navigation = "->" , target ;
target = identifier | "END" | "BACK" | "RESTART" ;
```

**Examples:**
```whisker
+ [Go north] -> NorthRoom
+ [End game] -> END
+ [Go back] -> BACK
+ [Start over] -> RESTART
```

### 3.13.2 Special Targets

| Target | Behavior |
|--------|----------|
| `END` | Terminates the story |
| `BACK` | Returns to previous passage |
| `RESTART` | Restarts from beginning |

## 3.14 Passage Links

### 3.14.1 Full Link Syntax

```ebnf
link = "[[" , link_text , "->" , target , "]]" ;
```

**Example:**
```whisker
Go to the [[forest->Forest]] or the [[mountain->Mountain]].
```

### 3.14.2 Short Link Syntax

```ebnf
short_link = "[[" , identifier , "]]" ;
```

**Example:**
```whisker
Visit the [[Garden]] or the [[Library]].
// Equivalent to: [[Garden->Garden]] or [[Library->Library]]
```

## 3.15 Story Header

### 3.15.1 Header Syntax

```ebnf
header = { header_directive } ;
header_directive = "@" , directive_name , ":" , directive_value , newline ;
```

### 3.15.2 Header Directives

| Directive | Type | Description |
|-----------|------|-------------|
| `@title:` | string | Story title |
| `@author:` | string | Author name |
| `@version:` | string | Version (semver) |
| `@ifid:` | string | Unique ID (UUID) |
| `@start:` | identifier | Start passage name |

**Example:**
```whisker
@title: The Great Adventure
@author: Jane Doe
@version: 1.0.0
@ifid: 550e8400-e29b-41d4-a716-446655440000
@start: Prologue

:: Prologue
Your journey begins...
```

### 3.15.3 Variable Initialization

```ebnf
vars_section = "@vars" , newline , { var_init } ;
var_init = identifier , ":" , literal , newline ;
```

**Example:**
```whisker
@vars
  gold: 100
  playerName: "Adventurer"
  hasKey: false

:: Start
Welcome, $playerName!
```

## 3.16 Complete Grammar Summary

See [GRAMMAR.ebnf](../GRAMMAR.ebnf) for the complete formal grammar.

### 3.16.1 Top-Level Structure

```ebnf
story = [ header ] , { passage } ;
header = { header_directive } ;
passage = passage_header , { directive } , content ;
content = { content_element } ;
content_element = text | conditional | alternative | choice | assignment | link | embedded_lua ;
```

## 3.17 Comprehensive Edge Cases

This section consolidates edge case behaviors for all major constructs.

### 3.17.1 String Edge Cases

| Scenario | Input | Behavior | Error |
|----------|-------|----------|-------|
| Empty string | `""` | Valid, zero length | - |
| Null character | `"\0"` | Error | WLS-SYN-040 |
| Very long string | 10MB+ | Impl-dependent | WLS-LIM-001 |
| Unclosed string | `"abc` | Error | WLS-SYN-003 |
| Multiline unescaped | `"line1\nline2"` | Valid | - |
| Raw string unclosed | `` `abc `` | Error | WLS-SYN-003 |

### 3.17.2 Number Edge Cases

| Scenario | Input | Behavior | Error |
|----------|-------|----------|-------|
| Leading zeros | `007` | Valid, equals 7 | - |
| Trailing decimal | `42.` | Error | WLS-SYN-041 |
| Leading decimal | `.5` | Error | WLS-SYN-041 |
| Multiple decimals | `1.2.3` | Error | WLS-SYN-041 |
| Hex notation | `0xFF` | Not supported | WLS-SYN-042 |
| Scientific | `1e10` | Not supported | WLS-SYN-042 |
| Infinity | `Infinity` | Via Lua only | - |
| NaN | `NaN` | Via Lua only | - |

### 3.17.3 Conditional Edge Cases

| Scenario | Input | Behavior |
|----------|-------|----------|
| Empty condition | `{}` | Error WLS-SYN-043 |
| Nested 10+ deep | `{{{...}}}` | Valid but perf warning |
| Else without if | `{else}...{/}` | Error WLS-SYN-044 |
| Multiple else | `{else}...{else}` | Error WLS-SYN-045 |
| Unclosed | `{$x}...` | Error WLS-SYN-002 |
| Empty branches | `{$x}{else}{/}` | Valid |

### 3.17.4 Choice Edge Cases

| Scenario | Input | Behavior |
|----------|-------|----------|
| Empty choice text | `* []` | Valid, invisible choice |
| No target | `* [Go]` | Error WLS-NAV-001 |
| Self-target | `* [Again] -> CurrentPassage` | Valid |
| Recursive sticky | `+ [Loop] -> CurrentPassage` | Valid, shows each visit |
| 1000+ choices | Large choice list | Valid, scroll warning |
| Duplicate text | Two `* [Same]` | Valid, both shown |

### 3.17.5 Navigation Edge Cases

| Scenario | Input | Behavior |
|----------|-------|----------|
| Undefined passage | `-> Missing` | Error WLS-NAV-002 |
| Empty passage name | `->` | Error WLS-SYN-046 |
| Circular navigation | `A -> B -> A` | Valid, continues |
| Deep tunnel stack | 100+ tunnels | Impl limit check |
| END from tunnel | `-> END` inside `->->` | Ends story, clears stack |

### 3.17.6 Variable Edge Cases

| Scenario | Input | Behavior |
|----------|-------|----------|
| Undefined read | `{$missing}` | nil (no error) |
| Type coercion | `{$num .. $str}` | Number to string |
| Self-reference | `{$x = $x + 1}` | Valid |
| Circular reference | Object A refs B refs A | Serialization error |
| Reserved name | `{$__internal = 1}` | Warning |

### 3.17.7 Whitespace Edge Cases

| Scenario | Input | Behavior |
|----------|-------|----------|
| Tab vs spaces | Mixed | Warning (style) |
| Trailing whitespace | `line   ` | Trimmed in output |
| Leading whitespace | `   line` | Preserved |
| Blank lines in prose | Multiple `\n\n` | Collapsed to one |
| CRLF mixed with LF | Windows/Unix | Normalized |

### 3.17.8 Comment Edge Cases

| Scenario | Input | Behavior |
|----------|-------|----------|
| Nested `/* */` | `/* /* */ */` | Not nested, first `*/` ends |
| Comment in string | `"/* not a comment */"` | String content |
| Unclosed block | `/* no end` | Error WLS-SYN-047 |
| Empty comment | `//` | Valid |
| Comment at EOF | `// no newline` | Valid |

---

**Previous Chapter:** [Core Concepts](02-CORE_CONCEPTS.md)
**Next Chapter:** [Variables](04-VARIABLES.md)
