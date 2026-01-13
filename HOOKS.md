# WLS Hooks System

**Whisker Language Specification - Presentation Hooks**

---

## Overview

The hooks system extends WLS with presentation layer control, allowing dynamic modification of displayed content without changing the underlying story state. Hooks are named text regions that can be modified using hook operations.

### Design Goals

1. **Separation of Concerns**: Presentation separate from story logic
2. **Dynamic Updates**: Modify displayed content without page refresh
3. **Progressive Enhancement**: Stories work without hooks; hooks enhance presentation
4. **Platform Compatibility**: Works in both Lua and TypeScript implementations

---

## Hook Definition

A hook creates a named text region that can be targeted by operations.

### Syntax

```ebnf
hook_definition = "|" , hook_name , ">" , "[" , hook_content , "]" ;
hook_name = identifier ;
hook_content = { any_char - "]" | escaped_bracket } ;
escaped_bracket = "\[" | "\]" ;
```

### Examples

```whisker
:: Room
|description>[The room is dark and quiet.]

The walls are made of |material>[rough stone].

|statusBar>[Health: 100 | Gold: 50]
```

### Rules

- Hook names MUST be valid identifiers (letters, digits, underscores)
- Hook names SHOULD be unique within a passage
- Hook content MAY contain any text including variable interpolation
- Nested hooks are NOT supported

---

## Hook Operations

Hook operations modify the content of defined hooks.

### Syntax

```ebnf
hook_operation = "@" , operation_type , ":" , whitespace , hook_name , whitespace , "{" , operation_content , "}" ;
operation_type = "replace" | "append" | "prepend" | "show" | "hide" ;
```

### Operation Types

| Operation | Effect | Content Required |
|-----------|--------|------------------|
| `replace` | Replace hook content entirely | Yes |
| `append` | Add content after hook content | Yes |
| `prepend` | Add content before hook content | Yes |
| `show` | Make hidden hook visible | No |
| `hide` | Make hook invisible | No |

---

## Replace Operation

Replaces the entire content of a hook.

### Syntax

```whisker
@replace: hookName { new content }
```

### Example

```whisker
:: Room
|description>[The room is dark and quiet.]

+ [Light torch] { @replace: description { The room is now brightly lit. } } -> Room
+ [Open curtains] { @replace: description { Sunlight floods the room. } } -> Room
```

### Behavior

- Previous content is completely removed
- New content becomes the hook's content
- If hook doesn't exist, operation is ignored (no error)

---

## Append Operation

Adds content after the existing hook content.

### Syntax

```whisker
@append: hookName { additional content }
```

### Example

```whisker
:: Room
|description>[The room is dark.]

+ [Look around] { @append: description { You see a door to the north. } } -> Room
+ [Examine walls] { @append: description { Ancient runes cover the walls. } } -> Room
```

### Behavior

- Original content is preserved
- New content is added after existing content
- Multiple appends accumulate
- A space is NOT automatically inserted; include if needed

---

## Prepend Operation

Adds content before the existing hook content.

### Syntax

```whisker
@prepend: hookName { content to add }
```

### Example

```whisker
:: Room
|description>[You stand in a dark room.]

+ [Remember] { @prepend: description { You recall being here before. } } -> Room
```

### Behavior

- Original content is preserved
- New content is added before existing content
- Multiple prepends accumulate
- A space is NOT automatically inserted; include if needed

---

## Show Operation

Makes a hidden hook visible.

### Syntax

```whisker
@show: hookName
```

### Example

```whisker
:: Room
|secretDoor hidden>[A hidden door is revealed!]

+ [Search room] { @show: secretDoor } -> Room
```

### Behavior

- Hook content becomes visible
- If hook is already visible, no change
- If hook doesn't exist, operation is ignored

---

## Hide Operation

Makes a visible hook invisible.

### Syntax

```whisker
@hide: hookName
```

### Example

```whisker
:: Room
|message>[Welcome to the room!]

+ [Dismiss message] { @hide: message } -> Room
```

### Behavior

- Hook content becomes invisible (not removed)
- Content can be shown again with `@show`
- If hook is already hidden, no change

---

## Hook State

Hooks maintain internal state:

| Property | Type | Description |
|----------|------|-------------|
| `name` | string | Hook identifier |
| `content` | string | Current content |
| `visible` | boolean | Visibility state |
| `initialContent` | string | Original content |

### State Persistence

- Hook state is NOT persisted across page loads by default
- Implementations MAY provide persistence options
- Story save/load SHOULD preserve hook state

---

## CSS Transitions (Browser Only)

The TypeScript implementation supports CSS transitions for hook operations.

### Configuration

```typescript
const hookManager = createHookManager({
  transitions: {
    replace: { duration: 300, easing: 'ease-out' },
    append: { duration: 200, easing: 'ease-in' },
    hide: { duration: 150, easing: 'linear' }
  }
});
```

### Accessibility

- Transitions respect `prefers-reduced-motion`
- When reduced motion is preferred, transitions are instant
- Essential transitions (loading indicators) always play

---

## Thread Integration

Hook operations can be scheduled using the thread system.

### Timed Operations

```whisker
:: Room
|status>[Waiting...]

{{
  whisker.thread.after(3000, function()
    whisker.hook.replace("status", "Ready!")
  end)
}}
```

### Repeating Operations

```whisker
:: Clock
|time>[12:00]

{{
  whisker.thread.every(1000, function()
    whisker.hook.replace("time", os.date("%H:%M:%S"))
  end)
}}
```

---

## Lua API

The Lua implementation exposes hooks through the `whisker.hook` namespace.

### Functions

| Function | Description |
|----------|-------------|
| `whisker.hook.define(name, content)` | Create a hook |
| `whisker.hook.get(name)` | Get hook content |
| `whisker.hook.replace(name, content)` | Replace content |
| `whisker.hook.append(name, content)` | Append content |
| `whisker.hook.prepend(name, content)` | Prepend content |
| `whisker.hook.show(name)` | Show hook |
| `whisker.hook.hide(name)` | Hide hook |
| `whisker.hook.exists(name)` | Check if hook exists |
| `whisker.hook.isVisible(name)` | Check visibility |
| `whisker.hook.reset(name)` | Reset to initial content |
| `whisker.hook.clear()` | Remove all hooks |

### Example

```lua
-- In embedded Lua
{{
  -- Define a hook programmatically
  whisker.hook.define("counter", "0")

  -- Modify hook content
  local count = tonumber(whisker.hook.get("counter")) + 1
  whisker.hook.replace("counter", tostring(count))

  -- Check visibility
  if whisker.hook.isVisible("message") then
    whisker.hook.hide("message")
  end
}}
```

---

## TypeScript API

The TypeScript implementation uses a HookManager class.

### Interface

```typescript
interface HookManager {
  define(name: string, content: string, options?: HookOptions): void;
  get(name: string): string | undefined;
  replace(name: string, content: string): void;
  append(name: string, content: string): void;
  prepend(name: string, content: string): void;
  show(name: string): void;
  hide(name: string): void;
  exists(name: string): boolean;
  isVisible(name: string): boolean;
  reset(name: string): void;
  clear(): void;

  // Events
  on(event: 'change', handler: (name: string) => void): void;
  on(event: 'visibility', handler: (name: string, visible: boolean) => void): void;
}

interface HookOptions {
  visible?: boolean;
  transition?: TransitionConfig;
}
```

### Example

```typescript
import { createHookManager } from '@whisker/core';

const hooks = createHookManager();

// Define a hook
hooks.define('status', 'Loading...', { visible: true });

// Modify content
hooks.replace('status', 'Ready!');
hooks.append('status', ' Click to continue.');

// Listen for changes
hooks.on('change', (name) => {
  console.log(`Hook ${name} changed`);
});
```

---

## Parser Support

### AST Node Types

**Hook Definition Node**:
```typescript
interface HookDefinitionNode {
  type: 'hook_definition';
  name: string;
  content: string;
  position: number;
}
```

**Hook Operation Node**:
```typescript
interface HookOperationNode {
  type: 'hook_operation';
  operation: 'replace' | 'append' | 'prepend' | 'show' | 'hide';
  target: string;
  content?: string;
  position: number;
}
```

### Parsing

The parser recognizes hook syntax and generates AST nodes:

```
Input:  |desc>[Hello]
Output: { type: 'hook_definition', name: 'desc', content: 'Hello' }

Input:  @replace: desc { World }
Output: { type: 'hook_operation', operation: 'replace', target: 'desc', content: 'World' }
```

---

## Best Practices

### Naming Conventions

```whisker
// Good: Descriptive, lowercase with underscores
|room_description>[...]
|player_status>[...]
|inventory_list>[...]

// Avoid: Short, cryptic names
|rd>[...]
|ps>[...]
```

### Content Organization

```whisker
// Good: Meaningful initial content
|description>[The room is dark and quiet.]

// Avoid: Empty hooks
|description>[]
```

### Operation Grouping

```whisker
// Good: Related operations together
+ [Search room] {
  @replace: description { You find a hidden passage. }
  @show: secret_door
} -> Room

// Avoid: Scattered operations
+ [Search] { @replace: desc { Found! } } -> Room
```

### Error Handling

```whisker
// Operations on non-existent hooks are silently ignored
@replace: nonexistent { This has no effect }

// Check existence if needed
{{
  if whisker.hook.exists("target") then
    whisker.hook.replace("target", "New content")
  end
}}
```

---

## Implementation Status

| Feature | whisker-core (Lua) | whisker-editor-web (TS) |
|---------|-------------------|-------------------------|
| Hook Definition | Complete | Complete |
| Hook Operations | Complete | Complete |
| Lua API | Complete | N/A |
| TypeScript API | N/A | Complete |
| CSS Transitions | N/A | Complete |
| Thread Integration | Complete | Complete |
| Parser Support | Complete | **Gap** (tests only) |

### Known Gap

The TypeScript parser does not yet generate `HookDefinitionNode` and `HookOperationNode` AST types. Runtime support is complete, but parsing hook syntax from .ws files requires implementation.

---

## Adding Hooks to Stories

Hooks are optional presentation enhancements. To add hooks to a story:

1. Identify text that should be dynamic
2. Wrap in hook definition: `|name>[content]`
3. Add operations in choices/actions: `@replace: name { new }`
