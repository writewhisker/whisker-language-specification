# Chapter 4: Variables

**Whisker Language Specification 1.0**

---

## 4.1 Overview

Variables store and track state throughout a story. WLS provides a simple but powerful variable system with two scopes, three types, and flexible interpolation.

## 4.2 Variable Declaration

### 4.2.1 Implicit Declaration

Variables are implicitly declared on first assignment:

```whisker
:: Start
$gold = 100          // Declares and assigns $gold
$playerName = "Hero" // Declares and assigns $playerName
$hasKey = false      // Declares and assigns $hasKey
```

### 4.2.2 Header Declaration

Variables MAY be pre-declared in the story header with initial values:

```whisker
@vars
  gold: 100
  playerName: "Adventurer"
  hasKey: false
  health: 100.0

:: Start
Welcome, $playerName! You have $gold gold.
```

**Header declaration benefits:**
- Documents all story variables in one place
- Sets default values before story starts
- Enables tooling support (autocomplete, validation)

### 4.2.3 Declaration Rules

| Rule | Description |
|------|-------------|
| First assignment wins | Type is set on first assignment |
| No explicit typing | Types are inferred from values |
| No forward declaration | Variables exist after assignment |
| No hoisting | Variables are not accessible before declaration |

## 4.3 Variable Types

### 4.3.1 Number

Numbers represent numeric values, both integers and floating-point.

```whisker
$gold = 100        // Integer
$health = 75.5     // Float
$temperature = -10 // Negative
$zero = 0          // Zero
```

**Number properties:**

| Property | Value |
|----------|-------|
| Minimum | Implementation-defined (at least -2^53) |
| Maximum | Implementation-defined (at least 2^53) |
| Precision | IEEE 754 double precision |
| Special values | No NaN or Infinity in WLS |

**Number operations:**

```whisker
$a = 10 + 5      // 15
$b = 10 - 5      // 5
$c = 10 * 5      // 50
$d = 10 / 4      // 2.5
$e = 10 % 3      // 1
$f = -$a         // -15
```

### 4.3.2 String

Strings represent text values.

```whisker
$name = "Alice"
$greeting = "Hello, world!"
$empty = ""
$quoted = "She said \"Hi\""
$multiline = "Line 1\nLine 2"
```

**String properties:**

| Property | Value |
|----------|-------|
| Encoding | UTF-8 |
| Max length | Implementation-defined (at least 65535) |
| Delimiter | Double quotes only |
| Escape sequences | See Section 3.11 |

**String operations:**

```whisker
$full = $first .. " " .. $last   // Concatenation
$len = {{ string.len(whisker.state.get("name")) }}  // Length via Lua
```

### 4.3.3 Boolean

Booleans represent true/false values.

```whisker
$hasKey = true
$isComplete = false
$isAlive = true
```

**Boolean operations:**

```whisker
$result = $a and $b    // Logical AND
$result = $a or $b     // Logical OR
$result = not $a       // Logical NOT
```

### 4.3.4 List

Lists are enumerated sets of named values. They are useful for tracking states, inventory items, and flags.

```whisker
LIST moods = happy, sad, angry, neutral
LIST inventory = (sword), (shield), potion  // parentheses = initially active

{$mood = neutral}       // Set value
{$mood == happy}        // Test value
{$inventory += sword}   // Add to list
{$inventory -= sword}   // Remove from list
{$inventory ? sword}    // Check if contains
```

See Section 4.13 for complete LIST documentation.

### 4.3.5 Array

Arrays are ordered, indexed collections of values.

```whisker
ARRAY items = ["sword", "shield", "potion"]
ARRAY scores = [100, 95, 87, 92]

${$items[0]}            // Access by index (0-based)
${#$items}              // Length
{$items += "bow"}       // Append
{$items[1] = "axe"}     // Replace at index
```

See Section 4.14 for complete ARRAY documentation.

### 4.3.6 Map

Maps are key-value collections for structured data.

```whisker
MAP player = { name: "Hero", health: 100, level: 1 }

${$player.name}         // Dot access
${$player["health"]}    // Bracket access
{$player.level += 1}    // Modify property
{$player.mana = 50}     // Add property
```

See Section 4.15 for complete MAP documentation.

### 4.3.7 Type Summary

| Type | Literals | Default | Falsy Value |
|------|----------|---------|-------------|
| number | `42`, `3.14`, `-10` | `0` | `0` |
| string | `"text"` | `""` | `""` (empty) |
| boolean | `true`, `false` | `false` | `false` |
| list | `LIST name = a, b, c` | empty list | empty list |
| array | `[1, 2, 3]` | `[]` | `[]` (empty) |
| map | `{ key: value }` | `{}` | `{}` (empty) |

## 4.4 Variable Scopes

### 4.4.1 Story Scope (`$`)

Story-scoped variables persist for the entire playthrough.

```whisker
$gold = 100      // Available everywhere
$playerName = "Hero"

:: Shop
You have $gold gold.   // Accessible here

:: Dungeon
$gold -= 10            // Still accessible
```

**Characteristics:**
- Prefix: `$`
- Lifetime: Entire story session
- Saved: Included in save files
- Access: All passages

### 4.4.2 Temporary Scope (`_`)

Temporary variables exist only within the current passage.

```whisker
:: Calculate
_baseValue = 100
_modifier = 1.5
_result = _baseValue * _modifier

The result is $_result.   // "The result is 150"

+ [Continue] -> NextPassage

:: NextPassage
// _baseValue, _modifier, _result are all undefined here
```

**Characteristics:**
- Prefix: `_`
- Lifetime: Current passage only
- Saved: NOT included in save files
- Access: Current passage only
- Cleared: On passage exit

### 4.4.3 Scope Comparison

| Feature | Story (`$`) | Temporary (`_`) |
|---------|-------------|-----------------|
| Prefix | `$` | `_` |
| Lifetime | Entire session | Current passage |
| Persisted | Yes | No |
| Use case | Game state | Calculations |

### 4.4.4 Shadowing

Temporary variables MUST NOT shadow story variables:

```whisker
// INVALID: Cannot shadow
$gold = 100
_gold = 50     // Error: shadows $gold

// VALID: Different names
$gold = 100
_tempGold = 50  // OK: different name
```

## 4.5 Variable Interpolation

### 4.5.1 Simple Interpolation

Use `$` followed by the variable name to interpolate values:

```whisker
$playerName = "Alice"
$gold = 100

Hello, $playerName!           // "Hello, Alice!"
You have $gold gold coins.    // "You have 100 gold coins."
```

**Rules:**
- Variable name extends to first non-identifier character
- Interpolation occurs in passage content and choice text
- Undefined variables produce an error

### 4.5.2 Expression Interpolation

Use `${}` to interpolate complex expressions:

```whisker
$gold = 100
$bonus = 50

Total: ${$gold + $bonus}           // "Total: 150"
Double: ${$gold * 2}               // "Double: 200"
Tax: ${$gold * 0.1}                // "Tax: 10"
Random: ${whisker.random(1, 6)}    // "Random: 3" (varies)
```

**Supported in expressions:**
- Arithmetic operations
- Variable references
- Function calls
- Parenthesized expressions

### 4.5.3 Interpolation Contexts

| Context | Simple (`$var`) | Expression (`${expr}`) |
|---------|-----------------|------------------------|
| Passage content | Yes | Yes |
| Choice text | Yes | Yes |
| Choice conditions | Yes | Yes |
| Lua strings | No* | No* |
| Comments | No | No |
| Passage names | No | No |

*Use `whisker.state.get()` in Lua instead.

### 4.5.4 Preventing Interpolation

Use backslash to escape the dollar sign:

```whisker
The price is \$50.        // "The price is $50."
Variable syntax: \$name   // "Variable syntax: $name"
```

### 4.5.5 Adjacent Interpolation

Multiple interpolations can be adjacent:

```whisker
$first = "John"
$last = "Doe"

Name: $first$last         // "Name: JohnDoe"
Name: $first $last        // "Name: John Doe"
Full: ${$first} ${$last}  // "Full: John Doe"
```

## 4.6 Variable Operations

### 4.6.1 Assignment

```whisker
$gold = 100              // Simple assignment
$name = "Hero"
$active = true
```

### 4.6.2 Compound Assignment

```whisker
$gold += 50              // Add: $gold = $gold + 50
$health -= 10            // Subtract: $health = $health - 10
```

**Compound assignment rules:**
- Variable MUST exist (no implicit creation)
- Types MUST be compatible (numbers only for `+=`, `-=`)

### 4.6.3 Accessing Undefined Variables

Accessing an undefined variable MUST produce an error:

```whisker
:: Start
You have $gold gold.     // Error: $gold is undefined

// Correct approach:
$gold = 0
You have $gold gold.     // OK: "You have 0 gold."
```

### 4.6.4 Variable Deletion

Variables cannot be deleted in WLS. To "clear" a variable, set it to a default value:

```whisker
$gold = 0                // "Clear" to zero
$name = ""               // "Clear" to empty string
$hasKey = false          // "Clear" to false
```

## 4.7 Type Coercion

### 4.7.1 Explicit Coercion

WLS does NOT perform implicit type coercion. Type mismatches produce errors:

```whisker
$num = 42
$str = "hello"

// INVALID: Type mismatch
$result = $num + $str    // Error: cannot add number and string

// VALID: Explicit handling
$result = $num .. ""     // Convert number to string for concatenation
```

### 4.7.2 Coercion Rules

| Operation | Allowed Types | Result Type |
|-----------|---------------|-------------|
| `+`, `-`, `*`, `/`, `%` | number, number | number |
| `..` | string, string | string |
| `==`, `~=` | any, same type | boolean |
| `<`, `>`, `<=`, `>=` | number, number OR string, string | boolean |
| `and`, `or` | any | last evaluated |
| `not` | any | boolean |

### 4.7.3 Truthiness

For boolean contexts (conditions), values are evaluated as:

| Type | Truthy | Falsy |
|------|--------|-------|
| boolean | `true` | `false` |
| number | non-zero | `0` |
| string | non-empty | `""` |

```whisker
$gold = 0
{ $gold }           // False (0 is falsy)
  You have gold.
{/}

$name = ""
{ $name }           // False (empty string is falsy)
  Hello, $name!
{/}
```

## 4.8 Variable Naming Conventions

### 4.8.1 Recommended Conventions

| Convention | Example | Use Case |
|------------|---------|----------|
| camelCase | `$playerName` | General variables |
| UPPER_CASE | `$MAX_HEALTH` | Constants (by convention) |
| prefixed | `$inv_sword` | Categorized variables |
| boolean prefix | `$hasKey`, `$isAlive` | Boolean flags |

### 4.8.2 Reserved Prefixes

| Prefix | Reserved For |
|--------|--------------|
| `whisker_` | Engine internal use |
| `_` (single) | Temporary variables |
| `__` (double) | Implementation internal |

### 4.8.3 Examples

```whisker
// Good naming
$playerName = "Hero"
$currentHealth = 100
$maxHealth = 100
$hasKey = true
$isGameOver = false
$inv_sword = true
$inv_shield = true

// Avoid
$x = 100             // Not descriptive
$temp = "value"      // Use _temp for temporaries
$PlayerName = "Hero" // Inconsistent casing
```

## 4.9 Built-in Variables

### 4.9.1 Engine-Provided State

The engine provides read-only access to certain state via API:

| Access | Description |
|--------|-------------|
| `whisker.visited(id)` | Visit count for passage |
| `whisker.passage.current()` | Current passage object |
| `whisker.history.count()` | History length |

These are NOT variables but function calls.

### 4.9.2 No Magic Variables

WLS does not define any magic or automatic variables. All state tracking is explicit:

```whisker
// Track visits manually if needed
$caveVisits = 0

:: Cave
$caveVisits += 1
{ $caveVisits == 1 }
  First time in the cave!
{/}

// Or use the API
{ whisker.visited("Cave") == 1 }
  First time in the cave!
{/}
```

## 4.10 Variable Persistence

### 4.10.1 Session Persistence

Story variables (`$`) persist for the duration of a play session:

- Maintained across passage transitions
- Maintained during history navigation (back)
- Reset on story restart

### 4.10.2 Save/Load Persistence

When a story is saved:

| Variable Type | Saved |
|---------------|-------|
| Story (`$`) | Yes |
| Temporary (`_`) | No |

### 4.10.3 Initial State on Load

When a save is loaded:

1. Story variables are restored to saved values
2. Temporary variables are undefined
3. Current passage is restored
4. History is restored

## 4.11 Error Conditions

### 4.11.1 Variable Errors

| Error | Cause | Example |
|-------|-------|---------|
| Undefined variable | Access before assignment | `$gold` before `$gold = 100` |
| Type mismatch | Operation on incompatible types | `$num + $str` |
| Invalid name | Name doesn't follow rules | `$1stPlace` |
| Shadowing | Temp shadows story var | `_gold` when `$gold` exists |

### 4.11.2 Error Messages

Implementations SHOULD provide helpful error messages:

```
Error at line 5, column 10:
  Undefined variable: $gold

  Hint: Did you mean to initialize this variable first?

  $gold = 0  // Add this before using $gold
```

## 4.12 Implementation Notes

### 4.12.1 Storage Requirements

Implementations MUST:
- Store variable names (strings)
- Store variable values (typed)
- Track variable scope (story vs temp)
- Support at least 1000 variables per story

### 4.12.2 Performance Considerations

Implementations SHOULD:
- Use hash tables for O(1) variable lookup
- Avoid unnecessary copying of string values
- Clear temporary variables efficiently on passage exit

### 4.12.3 API Access

Variables are accessible via the Lua API:

```lua
-- Get value
local gold = whisker.state.get("gold")

-- Set value
whisker.state.set("gold", 100)

-- Check existence
if whisker.state.has("gold") then
  -- ...
end

-- Get all variables
local all = whisker.state.all()
```

## 4.13 Lists (Enumerated Sets)

### 4.13.1 Overview

Lists are enumerated sets of named values, inspired by Ink's LIST type. They are ideal for tracking states, inventory items, character traits, and other categorical data.

### 4.13.2 Declaration Syntax

```whisker
LIST listName = value1, value2, value3
LIST listName = (active1), (active2), inactive1  // parentheses = initially active
```

**Rules:**
- List values are identifiers (no quotes needed)
- Values in parentheses are initially active (in the set)
- Values without parentheses are defined but not initially active
- List names follow variable naming rules

### 4.13.3 List Operations

| Operation | Syntax | Description |
|-----------|--------|-------------|
| Add | `{$list += value}` | Add value to set |
| Remove | `{$list -= value}` | Remove value from set |
| Toggle | `{$list ~= value}` | Toggle value in/out of set |
| Contains | `{$list ? value}` | Check if value is in set |
| Set single | `{$list = value}` | Clear list and set single value |
| Clear | `{$list = ()}` | Remove all values |

### 4.13.4 List Comparisons

```whisker
{$mood == happy}         // True if only 'happy' is active
{$mood ? happy}          // True if 'happy' is among active values
{$inventory ? sword}     // True if sword is in inventory
{#$inventory == 0}       // True if inventory is empty
{#$inventory > 2}        // True if more than 2 items
```

### 4.13.5 List Examples

```whisker
// Define moods with 'neutral' initially active
LIST moods = happy, sad, angry, (neutral)

:: Start
Your mood is $moods.

+ [Feel happy] {$moods = happy}
+ [Feel sad] {$moods = sad}
+ [Mixed feelings] {$moods += happy; $moods += sad}

- Continue with your mood: $moods.

// Inventory example
LIST inventory = sword, shield, potion, key

:: Shop
{$inventory += sword}
You bought a sword!

{ $inventory ? sword }
  You already have a sword.
{/}
```

### 4.13.6 List Serialization

Lists are serialized as arrays of active value names:

```json
{
  "moods": ["happy", "neutral"],
  "inventory": ["sword", "shield"]
}
```

## 4.14 Arrays

### 4.14.1 Overview

Arrays are ordered, indexed collections of values. They support mixed types and provide efficient access by index.

### 4.14.2 Declaration Syntax

```whisker
ARRAY arrayName = [value1, value2, value3]
ARRAY empty = []
ARRAY mixed = [1, "two", true, 3.14]
```

**Rules:**
- Array literals use square brackets `[]`
- Elements are comma-separated
- Elements can be any type (number, string, boolean, or nested collections)
- Indices are 0-based

### 4.14.3 Array Access

```whisker
${$items[0]}              // First element (0-based)
${$items[#$items - 1]}    // Last element
${$items[-1]}             // Also last element (negative indexing)
```

**Negative indexing:**
- `[-1]` = last element
- `[-2]` = second-to-last
- Out of bounds access returns nil

### 4.14.4 Array Operations

| Operation | Syntax | Description |
|-----------|--------|-------------|
| Append | `{$arr += value}` | Add to end |
| Prepend | `{$arr = [value] .. $arr}` | Add to beginning |
| Set index | `{$arr[i] = value}` | Set element at index |
| Length | `${#$arr}` | Get array length |
| Pop | `{_last = whisker.array.pop($arr)}` | Remove and return last |
| Shift | `{_first = whisker.array.shift($arr)}` | Remove and return first |
| Slice | `{_sub = whisker.array.slice($arr, 1, 3)}` | Get subarray |

### 4.14.5 Array Iteration

Arrays can be iterated in conditions:

```whisker
ARRAY scores = [100, 95, 87, 92]

{ whisker.array.contains($scores, 100) }
  Perfect score achieved!
{/}

// Display all scores
{| $scores[0] | $scores[1] | $scores[2] | $scores[3] |}
```

### 4.14.6 Array Examples

```whisker
ARRAY inventory = []

:: Shop
+ [Buy sword] {$inventory += "sword"} -> Bought
+ [Buy shield] {$inventory += "shield"} -> Bought
+ [Check inventory] -> CheckInventory

:: Bought
Item added! You now have ${#$inventory} items.
-> Shop

:: CheckInventory
Your inventory:
{ #$inventory == 0 }
  Empty!
{else}
  ${#$inventory} items: $inventory
{/}
-> Shop
```

### 4.14.7 Array Serialization

Arrays are serialized as JSON arrays:

```json
{
  "inventory": ["sword", "shield", "potion"],
  "scores": [100, 95, 87]
}
```

## 4.15 Maps

### 4.15.1 Overview

Maps are key-value collections for structured data. They are ideal for representing complex objects like player stats, NPC data, or game configuration.

### 4.15.2 Declaration Syntax

```whisker
MAP mapName = { key1: value1, key2: value2 }
MAP empty = {}
MAP player = {
  name: "Hero",
  health: 100,
  level: 1,
  inventory: ["sword", "shield"]
}
```

**Rules:**
- Map literals use curly braces `{}`
- Keys are identifiers or quoted strings
- Values can be any type
- Trailing commas are allowed

### 4.15.3 Map Access

```whisker
${$player.name}           // Dot notation
${$player["name"]}        // Bracket notation
${$player.stats.strength} // Nested access
```

**Access rules:**
- Dot notation for identifier keys
- Bracket notation for dynamic keys or non-identifier keys
- Accessing undefined keys returns nil

### 4.15.4 Map Operations

| Operation | Syntax | Description |
|-----------|--------|-------------|
| Set property | `{$map.key = value}` | Set or add property |
| Delete | `{$map.key = nil}` | Remove property |
| Has key | `{$map.key ~= nil}` | Check if key exists |
| Get keys | `${whisker.map.keys($map)}` | Get array of keys |
| Get values | `${whisker.map.values($map)}` | Get array of values |
| Merge | `{$map = whisker.map.merge($map1, $map2)}` | Combine maps |

### 4.15.5 Nested Maps

```whisker
MAP game = {
  player: {
    name: "Hero",
    stats: {
      health: 100,
      mana: 50
    }
  },
  settings: {
    difficulty: "normal"
  }
}

:: Start
Welcome, ${$game.player.name}!
Health: ${$game.player.stats.health}
Difficulty: ${$game.settings.difficulty}

+ [Take damage] {$game.player.stats.health -= 10}
  You now have ${$game.player.stats.health} health.
```

### 4.15.6 Map Examples

```whisker
MAP player = {
  name: "Adventurer",
  class: "warrior",
  level: 1,
  gold: 100,
  skills: ["slash", "block"]
}

:: CharacterSheet
# ${$player.name}
Class: ${$player.class}
Level: ${$player.level}
Gold: ${$player.gold}

+ [Level up] {$player.level += 1; $player.gold -= 50}
  { $player.gold >= 50 }
    Leveled up to ${$player.level}!
  {else}
    Not enough gold!
  {/}
+ [Learn skill] {$player.skills += "power_strike"}
  Learned Power Strike!
```

### 4.15.7 Map Serialization

Maps are serialized as JSON objects:

```json
{
  "player": {
    "name": "Hero",
    "health": 100,
    "level": 1,
    "inventory": ["sword", "shield"]
  }
}
```

## 4.16 Collection Error Codes

| Code | Name | Description |
|------|------|-------------|
| WLS-TYP-006 | invalid_list_operation | Operation not valid for list type |
| WLS-TYP-007 | array_index_invalid | Array index out of bounds or invalid |
| WLS-TYP-008 | map_key_invalid | Map key is not a string or identifier |
| WLS-TYP-009 | collection_type_mismatch | Expected collection, got scalar |
| WLS-TYP-010 | nested_access_on_scalar | Attempted nested access on non-collection |

---

**Previous Chapter:** [Syntax](03-SYNTAX.md)
**Next Chapter:** [Control Flow](05-CONTROL_FLOW.md)
