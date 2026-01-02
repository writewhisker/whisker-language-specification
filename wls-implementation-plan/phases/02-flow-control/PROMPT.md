# Phase 2: Advanced Flow Control (WLS 1.1)

## Objective

Complete the advanced flow control features from Ink: gather points, tunnels, inline conditionals, and once-only text.

## Features

### 1. Gather Points
**Priority: P1 | Complexity: High**

Gather points collect divergent choice paths back together.

```whisker
:: Conversation
+ [Ask about weather]
  "Nice weather we're having."
+ [Ask about news]
  "Did you hear about the festival?"
+ [Stay silent]
  The silence stretches awkwardly.
-
The conversation continues.
+ [Leave] -> Exit
```

**Syntax:**
- `-` at start of line (same indent as choices)
- Nested gathers with increased indent
- Multiple gather levels

### 2. Tunnels
**Priority: P1 | Complexity: High**

Tunnels are subroutine-like passage calls that return.

```whisker
:: Main
Before the aside.
-> Aside ->
After the aside.
+ [Continue] -> Next

:: Aside
This is a brief tangent.
->->
```

**Syntax:**
- `-> PassageName ->` calls tunnel
- `->->` returns from tunnel
- Tunnels can be nested
- Tunnels can take parameters (WLS 2.0)

### 3. Inline Conditionals
**Priority: P2 | Complexity: Medium**

Conditional text within a line.

```whisker
:: Shop
You have {$gold > 100 ? "plenty of" | "only a few"} coins.
The merchant {$visited ? "recognizes you" | "eyes you suspiciously"}.
```

**Syntax:**
- `{condition ? true_text | false_text}`
- Can be nested
- Works in choices and content

### 4. Once-Only Text
**Priority: P2 | Complexity: Low**

Text that only displays once per playthrough.

```whisker
:: Room
{once}
You enter the room for the first time.
{/once}
The room is dusty and dark.
```

**Syntax:**
- `{once}...{/once}` block
- Tracked per passage
- Can combine with conditions

## Implementation Steps

### Step 1: Specification
Update `spec/02-FLOW-CONTROL.md`:
- Add gather point syntax
- Add tunnel syntax
- Add inline conditional syntax
- Add once-only syntax

### Step 2: Parser Updates

**TypeScript (`packages/parser/`):**
```typescript
// Add to grammar
GatherPoint = "-" _ content:Content
Tunnel = "->" _ target:PassageName _ "->"
TunnelReturn = "->->"
InlineConditional = "{" condition:Expression "?" trueText:Text "|" falseText:Text "}"
OnceBlock = "{once}" content:Content "{/once}"
```

**Lua (`lib/whisker/parser/`):**
- Add gather point parsing
- Add tunnel parsing
- Add inline conditional parsing
- Add once-only parsing

### Step 3: Runtime Updates

**Call Stack for Tunnels:**
```typescript
interface RuntimeState {
  callStack: PassageFrame[];
  // ...
}

interface PassageFrame {
  passage: string;
  returnTo?: string;
  localVariables: Map<string, any>;
}
```

**Gather Point Execution:**
- Track choice depth
- Collect paths at gather
- Continue after gather

**Once-Only Tracking:**
```typescript
interface RuntimeState {
  seenOnce: Set<string>; // "passage:lineNumber"
}
```

### Step 4: Validators
- Validate tunnel return exists
- Warn on orphan gathers
- Check inline conditional syntax

## Key Files to Modify

**Specification:**
- `spec/02-FLOW-CONTROL.md`

**TypeScript:**
- `packages/parser/src/whisker.pegjs`
- `packages/story-player/src/StoryPlayer.ts`
- `packages/story-models/src/types.ts`

**Lua:**
- `lib/whisker/parser/ws_parser.lua`
- `lib/whisker/runtime/player.lua`
- `lib/whisker/runtime/state.lua`

**Tests:**
- `phase-4-validation/test-corpus/flow-control/`

## Examples

### Complex Gather Example
```whisker
:: Investigation
You examine the crime scene.
+ [Check the body]
  ++ [Look at wounds]
     Deep cuts, likely a knife.
  ++ [Check pockets]
     Empty. Someone cleaned them out.
  --
  The body tells its story.
+ [Search the room]
  ++ [Check drawers]
     Mostly empty. One letter remains.
  ++ [Look under bed]
     Dust bunnies and a key.
  --
  The room has secrets.
-
You've gathered what you can.
+ [Report findings] -> Report
```

### Tunnel with Content
```whisker
:: Main
The story begins.
-> DescribeWeather ->
You set off on your journey.
+ [Continue] -> Path

:: DescribeWeather
{$season == "winter"}
Snow blankets the ground.
{$season == "summer"}
The sun beats down mercilessly.
{else}
The weather is mild.
{/}
->->
```

### Inline Conditional in Choice
```whisker
:: Shop
+ [Buy sword ($50)] {$gold >= 50} -> BuySword
+ [Buy sword ($50)] {$gold < 50 ? "(Not enough gold)" | ""} -> CantAfford
```
