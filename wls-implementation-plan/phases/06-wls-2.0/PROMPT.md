# Phase 6: WLS 2.0

## Objective

Implement WLS 2.0 major version with advanced narrative features, enhanced runtime, and expanded media support. Breaking changes are permitted.

## Features Overview

| Feature | Priority | Complexity | Source |
|---------|----------|------------|--------|
| Threads | P1 | Very High | Ink |
| LIST State Machines | P1 | High | Ink |
| Timed Content | P2 | Medium | SugarCube |
| External Functions | P2 | High | Ink |
| Audio/Media API | P2 | Medium | SugarCube/Chapbook |
| Text Effects | P3 | Medium | Harlowe |
| Hooks System | P3 | Medium | Harlowe |
| Parameterized Passages | P2 | Medium | Ink |

## Feature Specifications

### 1. Threads (Parallel Content)
Execute multiple narrative streams simultaneously.

```whisker
:: Dinner
-> AmbientDining
The waiter approaches your table.
+ [Order wine] -> OrderWine
+ [Order water] -> OrderWater

== AmbientDining
{~|A couple argues.|Music plays.|Glasses clink.}
-> AmbientDining
```

**Implementation:**
- Thread scheduler in runtime
- Content interleaving algorithm
- Thread-local variables (`$_thread.var`)
- Synchronization: `{await thread_name}`

### 2. LIST State Machines
Extend LIST with state transitions and queries.

```whisker
LIST doorState = (closed), locked, unlocked, open

:: Door
{doorState ? closed}
The door is closed.
+ [Unlock] {do doorState -= closed, doorState += unlocked}
{/}
{doorState >= unlocked}
You can pass through.
{/}
```

**Operators:**
- `+=` add state
- `-=` remove state
- `?` contains
- `>=` includes (superset)
- `<=` subset

### 3. Timed Content
Content that reveals over time.

```whisker
:: Suspense
You wait in the darkness.

@delay 2s {
Suddenly, footsteps.
}

@delay 4s {
+ [Hide!] -> Hide
+ [Confront] -> Confront
}
```

**Features:**
- `@delay Ns { content }`
- `@every Ns { content }`
- Pause/resume API
- Animation integration

### 4. External Functions
Call host application functions from stories.

```whisker
EXTERNAL playSound(soundId)
EXTERNAL getUserName()
EXTERNAL saveAchievement(id)

:: Victory
{do playSound("fanfare")}
Congratulations, ${getUserName()}!
{do saveAchievement("complete")}
```

**Implementation:**
- Function registration API
- Type declarations
- Sandboxing for web
- Async support

### 5. Audio/Media API
First-class audio and video controls.

```whisker
@audio: bgm = "music/theme.mp3" loop volume:0.7
@audio: sfx = "sounds/door.wav"

:: Start
{do whisker.audio.play("bgm")}
You enter the castle.

:: Battle
{do whisker.audio.crossfade("bgm", "battle_theme", 2000)}
```

**Channels:** bgm, sfx, voice, ambient

### 6. Text Effects
Dynamic text presentation.

```whisker
:: Dramatic
@transition: fade-in 1s
The truth is revealed...

@effect: typewriter 50ms {
"I am your father."
}

@effect: shake {
BOOM!
}
```

### 7. Hooks System
Named text regions for dynamic modification.

```whisker
:: Garden
You see |flowers>[beautiful flowers].

+ [Look closer] {
  @replace: flowers {
    wilted roses, petals scattered
  }
}
```

**Operations:** replace, append, prepend, show, hide

### 8. Parameterized Passages
Passages that accept arguments.

```whisker
:: Describe(item, quality)
You examine the $item.
{quality == "good"}
Excellent condition.
{else}
Seen better days.
{/}

:: Inventory
-> Describe("sword", "good") ->
-> Describe("shield", "worn") ->
```

## Implementation Phases

### Phase 2.0.1: Foundation
1. Thread scheduler architecture
2. Enhanced LIST implementation
3. Parser updates for new syntax
4. Migration tool for 1.x stories

### Phase 2.0.2: Parallel Narrative
1. Thread execution model
2. Content interleaving
3. Thread variables
4. Synchronization primitives

### Phase 2.0.3: State Machines
1. LIST transition operators
2. State queries
3. Multi-value states
4. State-based conditions

### Phase 2.0.4: Timing and Media
1. Timed content system
2. Audio API
3. Video integration
4. Animation support

### Phase 2.0.5: Extensibility
1. External function binding
2. Plugin architecture
3. Security sandboxing
4. Type system for externals

### Phase 2.0.6: Presentation
1. Text effects
2. Transitions
3. Hooks system
4. Theme API enhancements

### Phase 2.0.7: Advanced Features
1. Parameterized passages
2. Pattern matching
3. Story includes with parameters
4. Macro system

## Breaking Changes

| Change | Reason | Migration |
|--------|--------|-----------|
| LIST syntax | State machine ops | Auto-migrate tool |
| Thread keywords | Reserved words | Rename check |
| `@delay` syntax | New directive | None (additive) |
| Hook syntax | New `\|name>[content]` | Manual review |

## Key Files

**TypeScript:**
- `packages/parser/src/whisker.pegjs` - Grammar updates
- `packages/story-player/src/` - Runtime updates
- `packages/story-models/src/` - New types

**Lua:**
- `lib/whisker/parser/` - Parser updates
- `lib/whisker/runtime/` - Runtime updates

**Specification:**
- `spec/` - Updated specifications

**Migration:**
- `tools/migrate-1x-to-2x.ts`
- `tools/migrate-1x-to-2x.lua`
