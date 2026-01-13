# Chapter 2: Core Concepts

**Whisker Language Specification 1.0**

---

## 2.1 Overview

This chapter defines the fundamental concepts that form the foundation of WLS. Understanding these concepts is essential for both authors and implementers.

The core concepts are:

1. **Stories** - Complete interactive narratives
2. **Passages** - Discrete units of content
3. **Choices** - Player decision points
4. **State** - Game variables and tracking
5. **Execution Model** - How stories run
6. **Lifecycle Events** - Hooks for custom behavior

## 2.2 Stories

### 2.2.1 Definition

A **story** is the top-level container for an interactive narrative. A story consists of:

- **Metadata** - Title, author, version, and other descriptive information
- **Passages** - The content units that make up the narrative
- **Variables** - Initial state definitions
- **Assets** - Optional media resources (images, audio)
- **Settings** - Configuration options

### 2.2.2 Story Structure

```
Story
├── Metadata
│   ├── title
│   ├── author
│   ├── version
│   ├── ifid (Interactive Fiction ID)
│   └── description
├── Variables (initial definitions)
├── Passages[]
│   ├── Passage 1
│   ├── Passage 2
│   └── ...
├── Assets[] (optional)
└── Settings (optional)
```

### 2.2.3 Story Metadata

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `title` | string | SHOULD | Story title |
| `author` | string | SHOULD | Author name |
| `version` | string | MAY | Story version (semver) |
| `ifid` | string | SHOULD | Unique story identifier (UUID) |
| `description` | string | MAY | Brief story description |
| `created` | datetime | MAY | Creation timestamp |
| `modified` | datetime | MAY | Last modification timestamp |

**Example:**

```whisker
@title: The Enchanted Forest
@author: Jane Author
@version: 1.0.0
@ifid: 12345678-1234-1234-1234-123456789ABC

:: Start
Your adventure begins...
```

### 2.2.4 Start Passage

Every story MUST have a designated start passage. The start passage is determined by:

1. Explicit `@start:` directive in story header
2. First passage in the story (if no directive)
3. A passage named `Start` (case-sensitive)

```whisker
@start: Prologue

:: Prologue
The story begins here, not at "Start".

:: Start
This passage is not the start in this story.
```

## 2.3 Passages

### 2.3.1 Definition

A **passage** is a discrete unit of narrative content. Passages are the building blocks of stories, analogous to pages in a book or scenes in a play.

A passage contains:

- **Identifier** - Unique name within the story
- **Content** - Text, conditionals, and inline elements
- **Choices** - Optional navigation options
- **Metadata** - Tags, color, notes (optional)
- **Scripts** - Lifecycle scripts (optional)

### 2.3.2 Passage Declaration

Passages are declared with the `::` marker followed by a name:

```whisker
:: PassageName
Content goes here.
```

**Naming Rules:**

- MUST start with a letter (a-z, A-Z) or underscore (_)
- MAY contain letters, digits (0-9), and underscores
- MUST NOT contain spaces or special characters
- Case-sensitive (`Start` ≠ `start` ≠ `START`)
- SHOULD be descriptive and readable

**Valid names:**
```
Start
_hidden_passage
Chapter1
my_passage_2
```

**Invalid names:**
```
1stPassage      // Cannot start with digit
My Passage      // Cannot contain spaces
passage-name    // Cannot contain hyphens
```

### 2.3.3 Passage Content

Passage content is everything between the passage declaration and the next passage (or end of file).

Content can include:

| Element | Description |
|---------|-------------|
| Plain text | Narrative prose |
| Variable interpolation | `$variable` or `${expression}` |
| Conditionals | `{ condition }...{/}` blocks |
| Alternatives | `{| a | b | c }` dynamic text |
| Choices | `+ [text] -> target` navigation |
| Comments | `//` or `/* */` |
| Embedded Lua | `{{ code }}` |

**Example:**

```whisker
:: Garden
The garden is beautiful in $timeOfDay light.

{ $hasVisitedBefore }
  You remember this place fondly.
{else}
  Everything here feels new and exciting.
{/}

The fountain makes {~| gentle | soft | peaceful } sounds.

+ [Smell the roses] -> Roses
+ [Sit on the bench] -> Bench
* [Look around] -> GardenLook
```

### 2.3.4 Passage Metadata

Passages MAY have metadata specified with directives:

| Directive | Type | Description |
|-----------|------|-------------|
| `@tags:` | string[] | Comma-separated tags |
| `@color:` | string | Editor display color (hex) |
| `@position:` | number[] | Editor position [x, y] |
| `@notes:` | string | Author notes (not displayed) |

**Example:**

```whisker
:: ImportantScene
@tags: chapter1, dramatic, boss-fight
@color: #ff0000
@notes: This is the climax of chapter 1

The dragon roars!
```

### 2.3.5 Passage Lifecycle Scripts

Passages MAY define scripts that execute at specific points:

| Script | Timing |
|--------|--------|
| `@onEnter:` | Executes when entering the passage |
| `@onExit:` | Executes when leaving the passage |

**Example:**

```whisker
:: TreasureRoom
@onEnter: whisker.state.set("foundTreasure", true)
@onExit: whisker.state.set("gold", whisker.state.get("gold") + 100)

You found the treasure room!
```

## 2.4 Choices

### 2.4.1 Definition

A **choice** represents a decision point where the player selects from available options. Each choice navigates to a target passage.

### 2.4.2 Choice Components

A choice consists of:

| Component | Required | Description |
|-----------|----------|-------------|
| Marker | Yes | `+` (once-only) or `*` (sticky) |
| Condition | No | `{ expression }` visibility condition |
| Text | Yes | `[displayed text]` shown to player |
| Action | No | `{ code }` executed on selection |
| Target | Yes | `-> PassageName` navigation target |

**Syntax:**

```
marker [condition] [text] [action] -> target
```

**Examples:**

```whisker
// Simple choice
+ [Go north] -> NorthRoom

// Sticky choice (repeatable)
* [Look around] -> LookAround

// Conditional choice
+ { $hasKey } [Unlock the door] -> InsideRoom

// Choice with action
+ [Buy sword] { $gold -= 50 } -> Inventory

// Full example
+ { $gold >= 100 } [Purchase armor ($100)] { $gold -= 100 } -> ArmorEquipped
```

### 2.4.3 Once-Only vs Sticky Choices

| Marker | Type | Behavior |
|--------|------|----------|
| `+` | Once-only | Disappears after selection |
| `*` | Sticky | Remains available |

**Example:**

```whisker
:: Shop
Welcome to the shop!

+ [Buy the special sword] -> BuySword    // Gone after purchase
* [Ask about prices] -> AskPrices        // Can ask repeatedly
* [Browse inventory] -> BrowseInventory  // Can browse repeatedly
+ [Leave shop] -> Exit                   // One-time exit
```

### 2.4.4 Choice Visibility

Choices are visible when:

1. No condition specified (always visible)
2. Condition evaluates to `true`
3. For once-only choices: not previously selected in this playthrough

Choices are hidden when:

1. Condition evaluates to `false`
2. For once-only choices: previously selected

### 2.4.5 Fallback Behavior

If all choices become unavailable (hidden or exhausted), the engine SHOULD:

1. Display a message indicating no choices remain
2. Or automatically proceed to a designated fallback passage

Implementations MAY provide configuration for this behavior.

## 2.5 State

### 2.5.1 Definition

**State** refers to the collection of variables that track story progress and player decisions. State persists across passage transitions and can be saved/restored.

### 2.5.2 Variable Types

WLS supports three primitive types:

| Type | Description | Examples |
|------|-------------|----------|
| `number` | Integer or floating-point | `42`, `3.14`, `-10` |
| `string` | Text enclosed in quotes | `"Hello"`, `"Player 1"` |
| `boolean` | True or false | `true`, `false` |

### 2.5.3 Variable Scopes

| Scope | Prefix | Lifetime |
|-------|--------|----------|
| Story | `$` | Entire playthrough |
| Temporary | `_` | Current passage only |

**Example:**

```whisker
:: Calculate
$totalScore = 100        // Persists across passages
_tempBonus = 25          // Cleared when leaving this passage

Final score: ${$totalScore + _tempBonus}
```

### 2.5.4 Initial State

Variables MAY be initialized in the story header:

```whisker
@vars
  gold: 100
  playerName: "Adventurer"
  hasKey: false
```

Or within passages:

```whisker
:: Start
$gold = 100
$playerName = "Adventurer"
$hasKey = false
```

### 2.5.5 State Access

State is accessed via:

1. **Interpolation** in content: `$variable` or `${expression}`
2. **Conditions**: `{ $variable > 10 }`
3. **Lua API**: `whisker.state.get("variable")`

### 2.5.6 Built-in State

The engine automatically tracks:

| Property | Access | Description |
|----------|--------|-------------|
| Visit count | `whisker.visited(passageId)` | Times passage visited |
| Current passage | `whisker.passage.current()` | Current passage object |
| History | `whisker.history.list()` | Navigation history |

## 2.6 Execution Model

### 2.6.1 Story Lifecycle

```
┌─────────────┐
│ Story Load  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Initialize  │ ← Set initial variables
│   State     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Enter Start │ ← Navigate to start passage
│  Passage    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────┐
│         Main Loop                    │
│  ┌─────────────┐                    │
│  │ Display     │                    │
│  │ Passage     │                    │
│  └──────┬──────┘                    │
│         │                           │
│         ▼                           │
│  ┌─────────────┐                    │
│  │ Evaluate    │                    │
│  │ Choices     │                    │
│  └──────┬──────┘                    │
│         │                           │
│         ▼                           │
│  ┌─────────────┐     ┌───────────┐ │
│  │ Wait for    │────►│ Navigate  │ │
│  │ Selection   │     │ to Target │ │
│  └─────────────┘     └─────┬─────┘ │
│         ▲                  │       │
│         └──────────────────┘       │
└─────────────────────────────────────┘
       │
       ▼
┌─────────────┐
│  Story End  │ ← No choices or END reached
└─────────────┘
```

### 2.6.2 Passage Execution

When a passage is entered:

1. **onEnter script** executes (if defined)
2. **Variable assignments** are processed (top to bottom)
3. **Content is rendered**:
   - Variable interpolation performed
   - Conditionals evaluated
   - Alternatives resolved
4. **Choices are evaluated**:
   - Conditions checked
   - Available choices presented
5. **Player selects** a choice
6. **Choice action** executes (if defined)
7. **onExit script** executes (if defined)
8. **Navigation** to target passage

### 2.6.3 Expression Evaluation

Expressions are evaluated left-to-right with operator precedence:

| Precedence | Operators | Associativity |
|------------|-----------|---------------|
| 1 (highest) | `not`, unary `-` | Right |
| 2 | `*`, `/`, `%` | Left |
| 3 | `+`, `-` | Left |
| 4 | `<`, `>`, `<=`, `>=` | Left |
| 5 | `==`, `~=` | Left |
| 6 | `and` | Left |
| 7 (lowest) | `or` | Left |

### 2.6.4 Content Rendering Order

Within a passage, content is rendered in document order:

1. Text lines
2. Conditionals (evaluated, content included or excluded)
3. Alternatives (one option selected)
4. Variable interpolation (values substituted)

**Example execution:**

```whisker
:: Example
$count = 5
The count is $count.           // "The count is 5."
$count += 1
Now it's $count.               // "Now it's 6."
```

## 2.7 Lifecycle Events

### 2.7.1 Story Events

| Event | Timing | Use Case |
|-------|--------|----------|
| Story Start | Before first passage | Initialize global state |
| Story End | After final passage | Cleanup, statistics |

### 2.7.2 Passage Events

| Event | Timing | Use Case |
|-------|--------|----------|
| `onEnter` | Entering passage | Setup, state changes |
| `onExit` | Leaving passage | Cleanup, state saves |

### 2.7.3 Choice Events

| Event | Timing | Use Case |
|-------|--------|----------|
| Choice Action | After selection, before navigation | State modifications |

### 2.7.4 Event Execution Order

When navigating from Passage A to Passage B via a choice:

```
1. Player selects choice in Passage A
2. Choice action executes (if any)
3. Passage A onExit executes (if any)
4. Navigation occurs
5. Passage B onEnter executes (if any)
6. Passage B content renders
```

## 2.8 Navigation

### 2.8.1 Navigation Types

| Type | Syntax | Description |
|------|--------|-------------|
| Choice | `-> PassageName` | Player-initiated |
| Direct | `whisker.passage.go(id)` | Script-initiated |
| Back | `whisker.history.back()` | Return to previous |

### 2.8.2 History Tracking

The engine MUST maintain a navigation history:

- Each passage visit is recorded
- History enables back navigation
- History is cleared on story restart

### 2.8.3 Special Navigation Targets

| Target | Behavior |
|--------|----------|
| `-> END` | Ends the story |
| `-> BACK` | Returns to previous passage |
| `-> RESTART` | Restarts the story |

## 2.9 Error Handling

### 2.9.1 Parse Errors

Parse errors MUST:

- Include line and column number
- Describe the error clearly
- Suggest corrections when possible

### 2.9.2 Runtime Errors

Runtime errors SHOULD:

- Not crash the engine
- Display a meaningful message
- Allow recovery when possible

### 2.9.3 Common Errors

| Error | Cause | Resolution |
|-------|-------|------------|
| Undefined passage | Navigation to non-existent passage | Create the passage |
| Undefined variable | Accessing unset variable | Initialize the variable |
| Type error | Invalid operation on type | Check operand types |
| Division by zero | Dividing by zero | Add zero check |

---

**Previous Chapter:** [Introduction](01-INTRODUCTION.md)
**Next Chapter:** [Syntax](03-SYNTAX.md)
