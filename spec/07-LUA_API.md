# Chapter 7: Lua API

**Whisker Language Specification 1.0**

---

## 7.1 Overview

WLS uses Lua as its scripting language. The `whisker.*` API provides a unified interface for story logic, state management, and navigation.

### 7.1.1 API Namespaces

| Namespace | Purpose |
|-----------|---------|
| `whisker.state` | Variable management |
| `whisker.passage` | Passage operations |
| `whisker.history` | Navigation history |
| `whisker.choice` | Choice management |
| Top-level functions | Common utilities |

### 7.1.2 Notation Conventions

Function signatures use this format:

```
functionName(param: type, optionalParam?: type) -> returnType
```

| Symbol | Meaning |
|--------|---------|
| `?` | Optional parameter |
| `...` | Variable arguments |
| `\|` | Union type (either type) |
| `nil` | No value / nothing |

## 7.2 Embedded Lua

### 7.2.1 Inline Expressions

Use double braces for inline Lua expressions:

```whisker
$random = {{ math.random(1, 100) }}
$doubled = {{ whisker.state.get("gold") * 2 }}
```

**Rules:**
- Expression MUST return a value
- Result is assigned or interpolated
- Single expression only (no statements)

### 7.2.2 Block Scripts

Use double braces with line breaks for multi-line Lua:

```whisker
{{
  local gold = whisker.state.get("gold")
  local bonus = whisker.state.get("level") * 10
  whisker.state.set("gold", gold + bonus)
}}
```

**Rules:**
- May contain multiple statements
- Last expression value is discarded (use for side effects)
- Local variables are scoped to the block

### 7.2.3 Lifecycle Scripts

Passages can define entry and exit scripts:

```whisker
:: TreasureRoom
@onEnter: whisker.state.set("foundTreasure", true)
@onExit: whisker.state.set("gold", whisker.state.get("gold") + 100)

You found the treasure room!
```

**Execution order:**
1. `@onEnter` executes when entering passage
2. Passage content renders
3. Player selects choice
4. Choice action executes
5. `@onExit` executes when leaving passage

### 7.2.4 Expression Context

Lua expressions can appear in:

| Context | Example |
|---------|---------|
| Variable assignment | `$x = {{ expr }}` |
| Conditions | `{ {{ expr }} }` |
| Choice actions | `+ [Text] { {{ expr }} } -> Target` |
| Lifecycle scripts | `@onEnter: {{ expr }}` |

## 7.3 whisker.state

The `whisker.state` namespace manages story variables.

### 7.3.1 get

```lua
whisker.state.get(key: string) -> any | nil
```

Returns the value of a variable, or `nil` if undefined.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Variable name (without `$` prefix) |

**Returns:** The variable value, or `nil` if not set.

**Example:**

```lua
local gold = whisker.state.get("gold")
local name = whisker.state.get("playerName")

if whisker.state.get("hasKey") then
  -- player has the key
end
```

### 7.3.2 set

```lua
whisker.state.set(key: string, value: any) -> nil
```

Sets a variable value. Creates the variable if it doesn't exist.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Variable name (without `$` prefix) |
| `value` | any | Value to set (number, string, or boolean) |

**Returns:** Nothing.

**Example:**

```lua
whisker.state.set("gold", 100)
whisker.state.set("playerName", "Hero")
whisker.state.set("hasKey", true)

-- Modify existing value
local gold = whisker.state.get("gold")
whisker.state.set("gold", gold + 50)
```

### 7.3.3 has

```lua
whisker.state.has(key: string) -> boolean
```

Checks if a variable exists (has been set).

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Variable name to check |

**Returns:** `true` if variable exists, `false` otherwise.

**Example:**

```lua
if whisker.state.has("gold") then
  -- gold has been defined
else
  whisker.state.set("gold", 0)
end
```

**Note:** A variable set to `nil` is considered non-existent.

### 7.3.4 delete

```lua
whisker.state.delete(key: string) -> nil
```

Removes a variable from state.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Variable name to delete |

**Returns:** Nothing.

**Example:**

```lua
whisker.state.delete("temporaryFlag")

-- After deletion:
whisker.state.has("temporaryFlag")  -- false
whisker.state.get("temporaryFlag")  -- nil
```

### 7.3.5 all

```lua
whisker.state.all() -> table
```

Returns a table containing all story variables.

**Parameters:** None.

**Returns:** Table with variable names as keys and values as values.

**Example:**

```lua
local state = whisker.state.all()

for name, value in pairs(state) do
  print(name .. " = " .. tostring(value))
end

-- Access specific values
local gold = state.gold
local name = state.playerName
```

**Note:** The returned table is a copy. Modifying it does not affect actual state.

### 7.3.6 reset

```lua
whisker.state.reset() -> nil
```

Clears all story variables.

**Parameters:** None.

**Returns:** Nothing.

**Example:**

```lua
-- Clear all state (typically on restart)
whisker.state.reset()
```

**Warning:** This removes ALL variables. Use with caution.

## 7.4 whisker.passage

The `whisker.passage` namespace manages passages.

### 7.4.1 current

```lua
whisker.passage.current() -> Passage
```

Returns the current passage object.

**Parameters:** None.

**Returns:** Passage object (see Section 7.4.7).

**Example:**

```lua
local passage = whisker.passage.current()
print(passage.id)       -- "TreasureRoom"
print(passage.content)  -- Raw content string
```

### 7.4.2 get

```lua
whisker.passage.get(id: string) -> Passage | nil
```

Returns a passage by its identifier.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Passage identifier |

**Returns:** Passage object, or `nil` if not found.

**Example:**

```lua
local intro = whisker.passage.get("Introduction")
if intro then
  print(intro.content)
end
```

### 7.4.3 go

```lua
whisker.passage.go(id: string) -> nil
```

Navigates to a passage immediately.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Target passage identifier |

**Returns:** Nothing (navigation occurs).

**Example:**

```lua
-- Programmatic navigation
if whisker.state.get("health") <= 0 then
  whisker.passage.go("GameOver")
end
```

**Warning:** This bypasses normal choice flow. Use sparingly.

### 7.4.4 exists

```lua
whisker.passage.exists(id: string) -> boolean
```

Checks if a passage exists.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Passage identifier to check |

**Returns:** `true` if passage exists, `false` otherwise.

**Example:**

```lua
if whisker.passage.exists("SecretRoom") then
  -- Enable secret room choice
end
```

### 7.4.5 all

```lua
whisker.passage.all() -> table
```

Returns all passages as a table.

**Parameters:** None.

**Returns:** Table with passage IDs as keys and Passage objects as values.

**Example:**

```lua
local passages = whisker.passage.all()

for id, passage in pairs(passages) do
  print(id)
end
```

### 7.4.6 tags

```lua
whisker.passage.tags(tag: string) -> table
```

Returns all passages with a specific tag.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | Tag to search for |

**Returns:** Array of Passage objects with that tag.

**Example:**

```lua
local chapters = whisker.passage.tags("chapter")

for _, passage in ipairs(chapters) do
  print(passage.id)
end
```

### 7.4.7 Passage Object

The Passage object structure:

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique passage identifier |
| `content` | string | Raw passage content |
| `tags` | table | Array of tags |
| `metadata` | table | Metadata key-value pairs |

**Example:**

```lua
local p = whisker.passage.current()

print(p.id)              -- "Cave"
print(p.tags[1])         -- "dark"
print(p.metadata.color)  -- "#333333"
```

## 7.5 whisker.history

The `whisker.history` namespace manages navigation history.

### 7.5.1 back

```lua
whisker.history.back() -> boolean
```

Navigates to the previous passage.

**Parameters:** None.

**Returns:** `true` if navigation occurred, `false` if no history.

**Example:**

```lua
if not whisker.history.back() then
  -- No history to go back to
  whisker.passage.go("Start")
end
```

### 7.5.2 canBack

```lua
whisker.history.canBack() -> boolean
```

Checks if back navigation is possible.

**Parameters:** None.

**Returns:** `true` if history has entries, `false` otherwise.

**Example:**

```lua
-- Only show back option if possible
if whisker.history.canBack() then
  -- Enable back button
end
```

### 7.5.3 list

```lua
whisker.history.list() -> table
```

Returns the navigation history as an array.

**Parameters:** None.

**Returns:** Array of passage IDs, oldest first.

**Example:**

```lua
local history = whisker.history.list()

-- Most recent is last
local previous = history[#history]

-- Full history
for i, passageId in ipairs(history) do
  print(i .. ": " .. passageId)
end
```

### 7.5.4 count

```lua
whisker.history.count() -> number
```

Returns the number of entries in history.

**Parameters:** None.

**Returns:** Number of history entries.

**Example:**

```lua
local steps = whisker.history.count()
print("You've visited " .. steps .. " passages")
```

### 7.5.5 contains

```lua
whisker.history.contains(id: string) -> boolean
```

Checks if a passage is in the history.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Passage identifier to check |

**Returns:** `true` if passage is in history, `false` otherwise.

**Example:**

```lua
if whisker.history.contains("SecretRoom") then
  -- Player has been to the secret room
end
```

### 7.5.6 clear

```lua
whisker.history.clear() -> nil
```

Clears all navigation history.

**Parameters:** None.

**Returns:** Nothing.

**Example:**

```lua
-- Clear history (e.g., on chapter transition)
whisker.history.clear()
```

## 7.6 whisker.choice

The `whisker.choice` namespace manages choices in the current passage.

### 7.6.1 available

```lua
whisker.choice.available() -> table
```

Returns currently available choices.

**Parameters:** None.

**Returns:** Array of Choice objects.

**Example:**

```lua
local choices = whisker.choice.available()

for i, choice in ipairs(choices) do
  print(i .. ": " .. choice.text)
end
```

### 7.6.2 select

```lua
whisker.choice.select(index: number) -> nil
```

Programmatically selects a choice by index.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based choice index |

**Returns:** Nothing (selection and navigation occur).

**Example:**

```lua
-- Auto-select first choice
whisker.choice.select(1)

-- Random choice
local choices = whisker.choice.available()
local randomIndex = math.random(1, #choices)
whisker.choice.select(randomIndex)
```

### 7.6.3 count

```lua
whisker.choice.count() -> number
```

Returns the number of available choices.

**Parameters:** None.

**Returns:** Number of currently available choices.

**Example:**

```lua
if whisker.choice.count() == 0 then
  -- No choices available
  whisker.passage.go("Fallback")
end
```

### 7.6.4 Choice Object

The Choice object structure:

| Property | Type | Description |
|----------|------|-------------|
| `text` | string | Displayed choice text (interpolated) |
| `target` | string | Target passage identifier |
| `type` | string | `"once"` or `"sticky"` |
| `index` | number | Position in choice list |

## 7.7 Top-Level Functions

These functions are available directly on the `whisker` namespace.

### 7.7.1 visited

```lua
whisker.visited(passage?: string) -> number
```

Returns the visit count for a passage.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `passage` | string (optional) | Passage ID, or current passage if omitted |

**Returns:** Number of times the passage has been visited.

**Example:**

```lua
-- Current passage visits
local visits = whisker.visited()

-- Specific passage visits
local caveVisits = whisker.visited("Cave")

-- First visit check
if whisker.visited("Introduction") == 0 then
  -- Never been here
end
```

**Note:** Visit count increments when entering a passage, before `@onEnter` executes.

### 7.7.2 random

```lua
whisker.random(min: number, max: number) -> number
```

Returns a random integer between min and max (inclusive).

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum value (inclusive) |
| `max` | number | Maximum value (inclusive) |

**Returns:** Random integer in range [min, max].

**Example:**

```lua
-- Roll a d6
local roll = whisker.random(1, 6)

-- Random gold drop
local gold = whisker.random(10, 50)
whisker.state.set("gold", whisker.state.get("gold") + gold)
```

### 7.7.3 pick

```lua
whisker.pick(...) -> any
```

Returns a random value from the arguments.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `...` | any | Values to choose from |

**Returns:** One of the provided values, randomly selected.

**Example:**

```lua
local color = whisker.pick("red", "green", "blue")
local enemy = whisker.pick("goblin", "orc", "troll", "dragon")

whisker.state.set("randomEnemy", enemy)
```

### 7.7.4 print

```lua
whisker.print(...) -> nil
```

Outputs text to the debug console.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `...` | any | Values to print |

**Returns:** Nothing.

**Example:**

```lua
whisker.print("Debug:", whisker.state.get("gold"))
whisker.print("Entering passage:", whisker.passage.current().id)
```

**Note:** Output destination is implementation-defined. MAY be suppressed in production.

## 7.8 Lua Standard Library

### 7.8.1 Available Functions

WLS implementations MUST provide these Lua standard functions:

| Library | Functions |
|---------|-----------|
| Basic | `type`, `tostring`, `tonumber`, `pairs`, `ipairs`, `next`, `select`, `unpack` |
| String | `string.len`, `string.sub`, `string.upper`, `string.lower`, `string.find`, `string.match`, `string.gsub`, `string.format`, `string.rep`, `string.reverse` |
| Table | `table.insert`, `table.remove`, `table.concat`, `table.sort` |
| Math | `math.abs`, `math.ceil`, `math.floor`, `math.max`, `math.min`, `math.random`, `math.randomseed`, `math.sqrt`, `math.pow`, `math.sin`, `math.cos`, `math.tan` |

### 7.8.2 Restricted Functions

These functions MUST NOT be available (security):

| Function | Reason |
|----------|--------|
| `io.*` | File system access |
| `os.execute` | System command execution |
| `os.exit` | Process termination |
| `os.remove` | File deletion |
| `os.rename` | File manipulation |
| `loadfile` | Arbitrary code loading |
| `dofile` | Arbitrary code execution |
| `load` | Dynamic code execution |
| `require` | Module loading |
| `debug.*` | Debug library access |

### 7.8.3 Safe os Functions

These `os` functions MAY be provided:

| Function | Description |
|----------|-------------|
| `os.time` | Current timestamp |
| `os.date` | Date formatting |
| `os.difftime` | Time difference |
| `os.clock` | CPU time |

## 7.9 Sandboxing

### 7.9.1 Execution Environment

Lua code executes in a sandboxed environment:

| Constraint | Requirement |
|------------|-------------|
| Global access | Limited to `whisker.*` and safe stdlib |
| File access | Prohibited |
| Network access | Prohibited |
| System access | Prohibited |
| Execution time | Implementation MAY limit |
| Memory | Implementation MAY limit |

### 7.9.2 Global Variables

Scripts SHOULD NOT rely on global variable persistence between executions:

```lua
-- Avoid: Global may not persist
myGlobal = "value"

-- Prefer: Use whisker.state
whisker.state.set("myValue", "value")
```

### 7.9.3 Error Isolation

Lua errors SHOULD NOT crash the engine:

| Error Type | Handling |
|------------|----------|
| Syntax error | Report at parse time |
| Runtime error | Catch, report, continue |
| Infinite loop | Timeout (implementation-defined) |

## 7.10 Error Handling

### 7.10.1 API Errors

| Error | Cause | Example |
|-------|-------|---------|
| Invalid argument | Wrong type passed | `whisker.state.get(123)` |
| Missing argument | Required param missing | `whisker.state.set("key")` |
| Invalid passage | Passage doesn't exist | `whisker.passage.go("NoExist")` |
| Index out of range | Invalid choice index | `whisker.choice.select(999)` |

### 7.10.2 Error Messages

Implementations SHOULD provide helpful errors:

```
Error in passage "Shop" at line 5:
  whisker.state.get() requires a string argument

  Got: nil
  Expected: string
```

### 7.10.3 Defensive Coding

Authors SHOULD validate before calling:

```lua
-- Check before navigation
if whisker.passage.exists(target) then
  whisker.passage.go(target)
else
  whisker.passage.go("ErrorPassage")
end

-- Check before state access
local gold = whisker.state.get("gold") or 0
```

## 7.11 Implementation Notes

### 7.11.1 API Consistency

Implementations MUST:

1. Implement all documented functions
2. Accept documented parameter types
3. Return documented return types
4. Handle edge cases gracefully

### 7.11.2 Dot vs Colon Notation

WLS uses dot notation exclusively:

```lua
-- Correct (WLS)
whisker.state.get("gold")

-- Incorrect (not WLS)
whisker.state:get("gold")
```

### 7.11.3 Thread Safety

If implementations support concurrent execution:

- State operations MUST be atomic
- Navigation MUST be serialized
- History operations MUST be thread-safe

### 7.11.4 Performance

Implementations SHOULD:

- Cache passage lookups
- Optimize frequent state access
- Minimize memory allocation in hot paths
- Consider lazy evaluation for computed properties

## 7.12 Quick Reference

### 7.12.1 State Management

```lua
whisker.state.get(key)           -- Get variable
whisker.state.set(key, value)    -- Set variable
whisker.state.has(key)           -- Check exists
whisker.state.delete(key)        -- Remove variable
whisker.state.all()              -- Get all as table
whisker.state.reset()            -- Clear all
```

### 7.12.2 Passage Operations

```lua
whisker.passage.current()        -- Current passage
whisker.passage.get(id)          -- Get by ID
whisker.passage.go(id)           -- Navigate to
whisker.passage.exists(id)       -- Check exists
whisker.passage.all()            -- Get all passages
whisker.passage.tags(tag)        -- Get by tag
```

### 7.12.3 History

```lua
whisker.history.back()           -- Go back
whisker.history.canBack()        -- Can go back?
whisker.history.list()           -- Get history
whisker.history.count()          -- History length
whisker.history.contains(id)     -- In history?
whisker.history.clear()          -- Clear history
```

### 7.12.4 Choices

```lua
whisker.choice.available()       -- Get choices
whisker.choice.select(index)     -- Select choice
whisker.choice.count()           -- Choice count
```

### 7.12.5 Utilities

```lua
whisker.visited(passage?)        -- Visit count
whisker.random(min, max)         -- Random integer
whisker.pick(...)                -- Random selection
whisker.print(...)               -- Debug output
```

---

**Previous Chapter:** [Choices](06-CHOICES.md)
**Next Chapter:** [File Formats](08-FILE_FORMATS.md)
