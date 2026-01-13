# WLS Quick Reference

**Whisker Language Specification**

---

## Story Structure

```whisker
@title: Story Title
@author: Author Name
@version: 1.0.0
@ifid: 550e8400-e29b-41d4-a716-446655440000
@start: StartPassage

@vars
  gold: 100
  name: "Hero"
  hasKey: false

:: StartPassage
Content here...
```

---

## Passages

```whisker
:: PassageName
@tags: important, chapter1
@color: #ff0000
Content of the passage.
```

---

## Variables

| Syntax | Type | Scope |
|--------|------|-------|
| `$varName` | Story | Persistent |
| `_varName` | Temp | Current passage |

### Assignment

```whisker
$gold = 100        // Set
$gold += 50        // Add
$gold -= 10        // Subtract
```

### Interpolation

```whisker
You have $gold gold.           // Simple
Total: ${$gold + $bonus}       // Expression
```

---

## Operators

### Arithmetic
| Op | Name | Example |
|----|------|---------|
| `+` | Add | `$a + $b` |
| `-` | Subtract | `$a - $b` |
| `*` | Multiply | `$a * $b` |
| `/` | Divide | `$a / $b` |
| `%` | Modulo | `$a % $b` |

### Comparison
| Op | Name | Example |
|----|------|---------|
| `==` | Equal | `$a == $b` |
| `~=` | Not equal | `$a ~= $b` |
| `<` | Less | `$a < $b` |
| `>` | Greater | `$a > $b` |
| `<=` | Less/equal | `$a <= $b` |
| `>=` | Greater/equal | `$a >= $b` |

### Logical
| Op | Name | Example |
|----|------|---------|
| `and` | AND | `$a and $b` |
| `or` | OR | `$a or $b` |
| `not` | NOT | `not $a` |

### String
| Op | Name | Example |
|----|------|---------|
| `..` | Concat | `"a" .. "b"` |

### Precedence (high to low)
1. `not`, unary `-`
2. `*`, `/`, `%`
3. `+`, `-`, `..`
4. `<`, `>`, `<=`, `>=`
5. `==`, `~=`
6. `and`
7. `or`

---

## Conditionals

### Block Conditional

```whisker
{ $condition }
  True branch.
{elif $other}
  Elif branch.
{else}
  Else branch.
{/}
```

### Inline Conditional

```whisker
{$hasKey: unlocked | locked}
```

---

## Text Alternatives

| Syntax | Type | Behavior |
|--------|------|----------|
| `{\| a \| b }` | Sequence | a, b, b, b... |
| `{&\| a \| b }` | Cycle | a, b, a, b... |
| `{~\| a \| b }` | Shuffle | Random |
| `{!\| a \| b }` | Once | a, b, nothing |

```whisker
{| First. | Second. | Third and beyond. }
{&| tick | tock }
{~| heads | tails }
{!| Welcome! | Hello again. | }
```

---

## Choices

### Basic Choices

```whisker
+ [Once-only choice] -> Target
* [Sticky choice] -> Target
```

### Conditional Choice

```whisker
+ { $gold >= 50 } [Buy sword] -> Shop
```

### Choice with Action

```whisker
+ [Take gold] { $gold += 100 } -> Next
```

### Combined

```whisker
+ { $hasKey } [Unlock door] { $doorOpen = true } -> Inside
```

### Special Targets

| Target | Action |
|--------|--------|
| `-> PassageName` | Go to passage |
| `-> END` | End story |
| `-> BACK` | Previous passage |
| `-> RESTART` | Start over |

---

## Links

```whisker
[[PassageName]]              // Short form
[[Display Text->Target]]     // Full form
```

---

## Comments

```whisker
// Single line comment

/* Multi-line
   comment */

$gold = 100  // Inline comment
```

---

## Escape Sequences

| Sequence | Result |
|----------|--------|
| `\\` | Backslash |
| `\$` | Dollar sign |
| `\{` | Open brace |
| `\}` | Close brace |
| `\[` | Open bracket |
| `\]` | Close bracket |
| `\n` | Newline |
| `\t` | Tab |
| `\"` | Double quote |

---

## Embedded Lua

### Inline

```whisker
$random = {{ math.random(1, 100) }}
```

### Block

```whisker
{{
  local bonus = 10
  whisker.state.set("gold", whisker.state.get("gold") + bonus)
}}
```

---

## Lua API

### whisker.state
| Function | Description |
|----------|-------------|
| `get(name)` | Get variable value |
| `set(name, value)` | Set variable |
| `has(name)` | Check if exists |
| `delete(name)` | Remove variable |
| `all()` | Get all variables |
| `reset()` | Clear all |

### whisker.passage
| Function | Description |
|----------|-------------|
| `current()` | Current passage name |
| `get(name)` | Get passage object |
| `go(name)` | Navigate to passage |
| `exists(name)` | Check if exists |
| `all()` | Get all passages |
| `tags(name)` | Get passage tags |

### whisker.history
| Function | Description |
|----------|-------------|
| `back()` | Go to previous |
| `canBack()` | Can go back? |
| `list()` | Get history list |
| `count()` | History length |
| `contains(name)` | In history? |
| `clear()` | Clear history |

### whisker.choice
| Function | Description |
|----------|-------------|
| `available()` | Get available choices |
| `select(index)` | Select choice |
| `count()` | Number of choices |

### Top-Level Functions
| Function | Description |
|----------|-------------|
| `visited(name)` | Visit count |
| `random(min, max)` | Random integer |
| `pick(...)` | Random from args |
| `print(...)` | Output text |

---

## Hooks System

### Hook Definition

```whisker
|hookName>[Content that can be modified]
```

### Hook Operations

| Operation | Syntax |
|-----------|--------|
| Replace | `@replace: hookName { new content }` |
| Append | `@append: hookName { additional }` |
| Prepend | `@prepend: hookName { before }` |
| Show | `@show: hookName` |
| Hide | `@hide: hookName` |

### Example

```whisker
:: Room
|desc>[The room is dark.]

+ [Light torch] { @replace: desc { The room is bright. } } -> Room
```

---

## Keywords

Reserved (cannot be used as identifiers):

```
and   or    not
true  false
else  elif
END   BACK  RESTART
```

---

## File Extensions

| Extension | Format |
|-----------|--------|
| `.ws` | WLS text format |
| `.json` | JSON format |

---

## MIME Types

| Type | Format |
|------|--------|
| `text/x-whisker` | .ws files |
| `application/json` | JSON |
