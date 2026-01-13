# Chapter 5: Control Flow

**Whisker Language Specification 1.0**

---

## 5.1 Overview

Control flow determines which content is displayed based on conditions and story state. WLS provides conditional blocks, inline conditionals, and text alternatives for dynamic content generation.

Control flow mechanisms:

| Mechanism | Purpose | Syntax |
|-----------|---------|--------|
| Block conditionals | Show/hide content blocks | `{ cond }...{/}` |
| Inline conditionals | Vary text inline | `{cond: a \| b}` |
| Text alternatives | Dynamic text variations | `{\| a \| b}` |

## 5.2 Block Conditionals

### 5.2.1 Basic Syntax

Block conditionals show or hide content based on a condition:

```whisker
{ condition }
  Content shown when condition is true.
{/}
```

**Components:**

| Component | Description |
|-----------|-------------|
| `{ condition }` | Opening with expression |
| Content | Lines to display if true |
| `{/}` | Closing marker |

**Example:**

```whisker
:: Inventory
{ $hasKey }
  You have a rusty key in your pocket.
{/}

{ $gold >= 100 }
  Your coin purse is quite heavy.
{/}
```

### 5.2.2 Else Clauses

Use `{else}` to provide alternative content when the condition is false:

```whisker
{ condition }
  Content when true.
{else}
  Content when false.
{/}
```

**Example:**

```whisker
:: DoorCheck
{ $hasKey }
  You unlock the door and step through.
{else}
  The door is locked. You need a key.
{/}
```

### 5.2.3 Elif Clauses

Use `{elif condition}` for multiple condition branches:

```whisker
{ condition1 }
  First option.
{elif condition2}
  Second option.
{elif condition3}
  Third option.
{else}
  Default option.
{/}
```

**Evaluation Rules:**

1. Conditions are evaluated top-to-bottom
2. First true condition's content is displayed
3. Remaining conditions are NOT evaluated
4. `{else}` executes only if all conditions are false
5. `{else}` is optional

**Example:**

```whisker
:: HealthCheck
{ $health > 75 }
  You feel strong and ready for anything.
{elif $health > 50}
  You're in decent shape, but could be better.
{elif $health > 25}
  Your wounds slow you down considerably.
{else}
  You can barely stand. Death feels near.
{/}
```

### 5.2.4 Nested Conditionals

Conditionals can nest to any depth:

```whisker
{ $inCave }
  The cave is dark and damp.

  { $hasTorch }
    Your torch illuminates strange markings on the wall.

    { $canReadAncient }
      The text warns of a guardian below.
    {else}
      The symbols mean nothing to you.
    {/}
  {else}
    You can barely see your hand in front of your face.
  {/}
{/}
```

**Nesting Rules:**

| Rule | Description |
|------|-------------|
| Depth | No limit on nesting depth |
| Matching | Each `{/}` closes nearest open block |
| Indentation | Aesthetic only, not semantic |
| Scope | Variables accessible at any depth |

### 5.2.5 Condition Expressions

Conditions use Whisker expressions (see Chapter 3):

```whisker
// Comparison operators
{ $gold >= 100 }
{ $name == "Hero" }
{ $level ~= 1 }

// Logical operators
{ $hasKey and $hasTorch }
{ $gold >= 50 or $hasDiscount }
{ not $isLocked }

// Complex expressions
{ ($gold >= 50 and $hasPermit) or $isVIP }
{ whisker.visited("Cave") > 0 }

// Truthiness (implicit boolean conversion)
{ $gold }           // True if non-zero
{ $playerName }     // True if non-empty string
{ $hasKey }         // True if true
```

### 5.2.6 Whitespace Handling

Whitespace within conditional blocks follows these rules:

| Context | Behavior |
|---------|----------|
| Leading whitespace | Preserved (for indentation) |
| Trailing whitespace | Trimmed from each line |
| Blank lines | Preserved within content |
| Around markers | Flexible |

**Example:**

```whisker
{ $verbose }
  This text preserves its leading spaces.

  Blank lines are kept.
{/}
```

**Output (when true):**
```
  This text preserves its leading spaces.

  Blank lines are kept.
```

### 5.2.7 Empty Blocks

Empty conditional blocks are valid but have no effect:

```whisker
{ $condition }
{/}

// Equivalent to no output when true
```

## 5.3 Inline Conditionals

### 5.3.1 Basic Syntax

Inline conditionals vary text within a line:

```whisker
The door is {$hasKey: unlocked | locked}.
```

**Syntax:**

```
{condition: trueText | falseText}
```

**Components:**

| Component | Required | Description |
|-----------|----------|-------------|
| `condition` | Yes | Expression to evaluate |
| `:` | Yes | Separator after condition |
| `trueText` | Yes | Text when condition is true |
| `\|` | Yes | Separator between options |
| `falseText` | Yes | Text when condition is false |

### 5.3.2 Examples

```whisker
// Simple boolean
You {$hasKey: have | need} a key.

// Comparison
You have {$gold >= 100: enough | insufficient} gold.

// Pluralization
You have $gold gold {$gold == 1: piece | pieces}.

// Complex condition
The guard {$gold >= 50 or $hasPass: waves you through | blocks your path}.

// Variable interpolation inside
You see {$isDay: the bright sun | $moonPhase}.
```

### 5.3.3 Restrictions

Inline conditionals have limitations compared to block conditionals:

| Feature | Block | Inline |
|---------|-------|--------|
| Nesting | Yes | No |
| Multi-line content | Yes | No |
| Multiple elif | Yes | No |
| Variable assignment | Yes | No |

**Invalid (nesting):**

```whisker
// INVALID: Cannot nest inline conditionals
{$a: {$b: x | y} | z}
```

**Use block form instead:**

```whisker
// VALID: Use block for complex logic
{ $a }
  { $b }
    x
  {else}
    y
  {/}
{else}
  z
{/}
```

### 5.3.4 Escaping in Inline Conditionals

Use backslash to include literal characters:

```whisker
// Literal pipe
{$choice: Option A \| more | Option B}

// Literal colon
{$time: 12\:00 PM | midnight}

// Literal braces
{$show: \{braces\} | none}
```

## 5.4 Text Alternatives

### 5.4.1 Overview

Text alternatives provide dynamic text that changes based on visit count or randomization. They are essential for creating variety in repeated content.

| Type | Prefix | Behavior |
|------|--------|----------|
| Sequence | (none) | Shows items in order, stops at last |
| Cycle | `&` | Shows items in order, loops forever |
| Shuffle | `~` | Random selection each time |
| Once-only | `!` | Each item shown once, then empty |

### 5.4.2 Sequence Alternatives

Sequences show options in order and stop at the last:

```whisker
{| First | Second | Third | Final }
```

**Behavior by visit:**

| Visit | Output |
|-------|--------|
| 1 | "First" |
| 2 | "Second" |
| 3 | "Third" |
| 4+ | "Final" |

**Example:**

```whisker
:: OldMan
{| "Ah, a visitor!" | "Back again?" | "You're persistent." | "What now?" }
the old man says.

+ [Ask about the cave] -> CaveInfo
+ [Leave] -> Village
```

### 5.4.3 Cycle Alternatives

Cycles loop through options forever:

```whisker
{&| Red | Green | Blue }
```

**Behavior by visit:**

| Visit | Output |
|-------|--------|
| 1 | "Red" |
| 2 | "Green" |
| 3 | "Blue" |
| 4 | "Red" |
| 5 | "Green" |
| ... | (continues) |

**Example:**

```whisker
:: WeatherReport
The sky is {&| clear | cloudy | overcast | partly cloudy }.
The wind blows from the {&| north | east | south | west }.
```

### 5.4.4 Shuffle Alternatives

Shuffles select randomly each time:

```whisker
{~| Option A | Option B | Option C }
```

**Behavior:**
- Each evaluation selects one option randomly
- All options have equal probability
- Same option may repeat consecutively
- Selection is independent of previous choices

**Example:**

```whisker
:: Forest
You notice {~| a squirrel | a rabbit | a deer | nothing } in the underbrush.
The trees sway {~| gently | wildly | barely } in the breeze.
```

### 5.4.5 Once-Only Alternatives

Once-only alternatives show each option exactly once, then produce nothing:

```whisker
{!| First time. | Second time. | Last time. }
```

**Behavior by visit:**

| Visit | Output |
|-------|--------|
| 1 | "First time." |
| 2 | "Second time." |
| 3 | "Last time." |
| 4+ | "" (empty) |

**Example:**

```whisker
:: Hints
{!| Hint: Check behind the painting. | Hint: The key is brass. | Hint: Listen for the click. }

The puzzle awaits your solution.
```

### 5.4.6 Alternative Syntax Details

**Complete syntax:**

```
{[prefix]| option1 | option2 | ... | optionN }
```

**Parsing rules:**

| Rule | Description |
|------|-------------|
| Opening | `{`, optional prefix, `\|` |
| Options | Separated by ` \| ` (space-pipe-space) |
| Closing | `}` |
| Whitespace | Trimmed from each option |
| Empty options | Valid, produce empty string |

**Examples:**

```whisker
// Minimum (two options)
{| a | b }

// With empty option
{| something |  }    // Second option is empty

// Multiple options
{~| one | two | three | four | five }

// Multiword options
{| the quick fox | a lazy dog | some random text }
```

### 5.4.7 Tracking State

Alternative state is tracked per passage and per alternative:

```whisker
:: Room
{| First | Second | Third }     // Alternative A
{| Red | Blue | Green }          // Alternative B
```

- Alternative A tracks its own visit count
- Alternative B tracks its own visit count separately
- Both reset if the story restarts

**Implementation Note:** Implementations track alternatives by their position within each passage. Moving alternatives may reset their state.

### 5.4.8 Alternatives in Choice Text

Alternatives can appear in choice text:

```whisker
:: Shop
* [{~| Browse | Look around | Check out } the wares] -> Browse
* [Talk to the {&| friendly | grumpy | distracted } merchant] -> Talk
+ [{| Buy the rare item | (Already purchased) }] -> BuyRare
```

### 5.4.9 Combining Alternatives

Multiple alternatives can appear in the same line:

```whisker
The {~| tall | short | mysterious } stranger wore a {~| red | blue | black } coat.
```

Each alternative is evaluated independently.

## 5.5 Evaluation Order

### 5.5.1 Content Processing Order

Content within a passage is processed in document order:

1. **Variable assignments** execute first
2. **Block conditionals** evaluate and include/exclude content
3. **Inline conditionals** resolve within lines
4. **Alternatives** select their current value
5. **Variable interpolation** substitutes values
6. **Final output** is produced

**Example:**

```whisker
:: Example
$count = 5                           // 1. Assignment
{ $count > 0 }                       // 2. Block evaluates (true)
  Count is {$count > 3: high | low}  // 3. Inline evaluates ("high")
  Status: {| First | Second }        // 4. Alternative ("First" on first visit)
  Value: $count                      // 5. Interpolation ("5")
{/}
```

### 5.5.2 Short-Circuit Evaluation

Logical operators use short-circuit evaluation:

```whisker
// $b only evaluated if $a is true
{ $a and $b }
  Both are true.
{/}

// $b only evaluated if $a is false
{ $a or $b }
  At least one is true.
{/}
```

**Benefits:**
- Prevents errors from undefined variables
- Enables guard patterns
- Improves performance

**Example (guard pattern):**

```whisker
// Safe: $gold only accessed if $hasWallet is true
{ $hasWallet and $gold >= 100 }
  You can afford it.
{/}
```

### 5.5.3 Conditional Content and Variables

Variables assigned within conditionals follow scoping rules:

```whisker
:: Conditional Assignment
{ $isRich }
  $status = "wealthy"
{else}
  $status = "modest"
{/}

Your status: $status    // Always defined (one branch executed)
```

**Warning:** Assigning variables only in one branch may leave them undefined:

```whisker
// CAUTION: $bonus undefined if condition is false
{ $level > 10 }
  $bonus = 50
{/}
$total = $base + $bonus    // Error if $level <= 10
```

**Better approach:**

```whisker
$bonus = 0                  // Default value
{ $level > 10 }
  $bonus = 50
{/}
$total = $base + $bonus    // Always works
```

## 5.6 Complex Patterns

### 5.6.1 Conditional Choices

Combine conditionals with choices:

```whisker
:: Shop
Welcome to the shop!

{ $gold >= 100 }
  The premium items are available to you.
{/}

+ { $gold >= 50 } [Buy sword ($50)] { $gold -= 50 } -> BuySword
+ { $gold >= 100 } [Buy armor ($100)] { $gold -= 100 } -> BuyArmor
* [Just looking] -> Browse
+ [Leave] -> Exit
```

### 5.6.2 Dynamic Descriptions

Combine alternatives with conditionals:

```whisker
:: Tavern
The tavern is {~| busy | quiet | moderately full } tonight.

{ whisker.visited("Tavern") == 1 }
  {| You've never been here before. | You remember this place. }
{/}

The bartender {$metBartender: nods in recognition | eyes you suspiciously}.
```

### 5.6.3 Progressive Revelation

Use once-only alternatives for gradual information:

```whisker
:: AncientLibrary
The library holds countless secrets.

{!| You notice the books are arranged by color, not subject. }
{!| A hidden compartment reveals itself in one shelf. }
{!| Ancient runes glow faintly on the ceiling. }

What would you like to examine?

* [Search the shelves] -> SearchShelves
+ [Leave] -> Exit
```

### 5.6.4 State-Based Narratives

Build complex state-dependent narratives:

```whisker
:: ThroneRoom
{ $allegiance == "king" }
  The king smiles warmly as you approach.
  { $completedQuest }
    "You have served me well," he says.
  {else}
    "Have you completed your task?"
  {/}
{elif $allegiance == "rebels"}
  Guards immediately surround you.
  { $hasDisguise }
    But your disguise holds. They let you pass.
  {else}
    "Seize the traitor!" someone shouts.
  {/}
{else}
  The king regards you with curiosity.
  "A new face. State your business."
{/}
```

## 5.7 Error Conditions

### 5.7.1 Control Flow Errors

| Error | Cause | Example |
|-------|-------|---------|
| Unclosed block | Missing `{/}` | `{ $x }...` (no close) |
| Orphan close | `{/}` without open | `{/}` alone |
| Orphan else | `{else}` without block | `{else} text {/}` |
| Invalid condition | Syntax error in expression | `{ $x == }` |
| Mismatched nesting | Wrong close order | Interleaved blocks |

### 5.7.2 Error Examples

**Unclosed block:**

```whisker
// INVALID: Missing {/}
{ $hasKey }
  You have the key.

:: NextPassage
```

> **Error:** Unclosed conditional block at line 2. Expected `{/}` before passage declaration.

**Invalid inline:**

```whisker
// INVALID: Missing false option
The door is {$hasKey: open}.
```

> **Error:** Inline conditional missing false option. Expected `| falseText}`.

### 5.7.3 Error Recovery

Implementations SHOULD:

1. Report the specific error type
2. Include line and column numbers
3. Continue parsing when possible
4. Suggest corrections

## 5.8 Implementation Notes

### 5.8.1 Parsing Considerations

Block conditionals can be parsed as:

```
conditional_block = "{" , expression , "}" ,
                    content ,
                    { elif_clause } ,
                    [ else_clause ] ,
                    "{/}" ;

elif_clause = "{elif" , expression , "}" , content ;
else_clause = "{else}" , content ;
```

### 5.8.2 Alternative State Storage

Implementations MUST track:

| Data | Per | Purpose |
|------|-----|---------|
| Visit count | Alternative instance | Sequence/cycle position |
| Used indices | Once-only alternative | Track shown options |
| Random seed | Optional | Reproducible shuffles |

### 5.8.3 Performance Considerations

- Cache condition evaluation results when expressions are pure
- Avoid re-evaluating alternatives on back navigation
- Consider lazy evaluation for complex conditionals
- Pre-compile expressions for repeated evaluation

### 5.8.4 Testing Requirements

Implementations MUST correctly handle:

- Deeply nested conditionals (at least 10 levels)
- Adjacent alternatives on same line
- Empty conditional branches
- All alternative types at boundary conditions
- Short-circuit evaluation

## 5.9 Gather Points

### 5.9.1 Overview

Gather points provide a way to reconverge flow after branching choices within a single passage. They reduce passage explosion by allowing multiple choice branches to continue to common content without requiring separate passages.

**Syntax:**

```whisker
- Content after gather point
```

The gather marker (`-`) at the start of a line marks a gather point. All choices above the gather point reconverge at this line.

### 5.9.2 Basic Usage

```whisker
:: Conversation
"What do you think of the proposal?"

+ [Agree]
  "I'm glad you see it my way," she says with a smile.
+ [Disagree]
  "That's... disappointing," she says with a frown.
+ [Stay silent]
  She waits expectantly, then sighs.

- "Either way, we should discuss the details."

+ [Continue] -> Details
+ [Leave] -> Exit
```

**Behavior:**
1. Player selects one of the three choices
2. The corresponding response is displayed
3. Flow continues to the gather point
4. "Either way, we should discuss the details." is displayed
5. New choices are presented

### 5.9.3 Multiple Gather Points

A passage can contain multiple gather points:

```whisker
:: Interview
"First question: What's your greatest strength?"

+ [Leadership]
  "Excellent quality for this role."
+ [Technical skills]
  "We value expertise."

- "Second question: Why do you want this job?"

+ [Growth opportunity]
  "That's a mature perspective."
+ [Compensation]
  She raises an eyebrow but nods.

- "Thank you for your time."
-> Exit
```

### 5.9.4 Nested Choices and Gathers

Gather points work with nested choice structures:

```whisker
:: Negotiation
"Let's discuss the price."

+ [Make an offer]
  "I'll give you $50."

  + + [Accept]
    "Deal!" he says.
  + + [Counter]
    "How about $40?"

  - - The merchant considers.

+ [Walk away]
  "Wait, wait!" he calls after you.

- The deal concludes one way or another.
```

**Nesting rules:**
- Gather depth matches choice depth (same number of markers)
- `- -` gathers nested choices (`+ +`)
- Single `-` gathers top-level choices

### 5.9.5 Gather Point Restrictions

| Restriction | Description |
|-------------|-------------|
| Line start | Must appear at beginning of line (after optional indent) |
| After choices | Must follow at least one choice |
| Same passage | Cannot gather across passages |
| Depth matching | Gather depth must match choice depth |

**Invalid examples:**

```whisker
// INVALID: Gather without preceding choices
:: Example
Some text.
- This is invalid.

// INVALID: Mismatched depth
+ [Choice]
  Content.
- - Wrong depth (should be single -)
```

## 5.10 Tunnels

### 5.10.1 Overview

Tunnels enable reusable passages that return to the caller. They function like subroutines, allowing common content sequences to be defined once and called from multiple locations.

**Tunnel call syntax:**
```whisker
-> PassageName ->
```

**Tunnel return syntax:**
```whisker
<-
```

### 5.10.2 Basic Usage

```whisker
:: Morning
You wake up and stretch.
-> BrushTeeth ->
-> GetDressed ->
Ready for the day!
+ [Go to work] -> Work
+ [Stay home] -> Home

:: BrushTeeth
You brush your teeth thoroughly.
<-

:: GetDressed
You put on your favorite outfit.
<-
```

**Execution flow:**
1. "You wake up and stretch." displays
2. Engine pushes return location to call stack
3. BrushTeeth passage executes
4. `<-` pops stack and returns to Morning
5. GetDressed passage executes
6. `<-` returns to Morning
7. "Ready for the day!" displays
8. Choices are presented

### 5.10.3 Tunnels with Choices

Tunnels can contain choices that don't exit the tunnel:

```whisker
:: Shop
Welcome to the shop!
-> BrowseItems ->
Come back anytime!
-> Exit

:: BrowseItems
"What interests you?"
+ [Weapons]
  You examine the sword display.
+ [Armor]
  The armor gleams invitingly.
+ [Potions]
  Colorful bottles line the shelves.
- "Let me know if you need help."
<-
```

### 5.10.4 Nested Tunnels

Tunnels can call other tunnels:

```whisker
:: MainQuest
You embark on your journey.
-> TravelSequence ->
You arrive at your destination.

:: TravelSequence
-> PackSupplies ->
-> MountHorse ->
You ride through the countryside.
<-

:: PackSupplies
You gather your supplies.
<-

:: MountHorse
You mount your trusty steed.
<-
```

**Call stack depth:**
- Implementations MUST support at least 100 levels of nesting
- Stack overflow SHOULD produce a clear error message

### 5.10.5 Conditional Returns

Tunnels can have multiple return points:

```whisker
:: GuardCheck
The guard examines you.
{ $hasPass }
  "Everything seems in order."
  <-
{/}
{ $bribeAmount >= 50 }
  "Well, I suppose I can look the other way."
  $gold -= $bribeAmount
  <-
{/}
"You cannot pass!"
-> Prison
```

**Note:** If a tunnel navigates to another passage without returning (`-> Prison` above), the call stack is NOT unwound. The tunnel becomes a normal navigation.

### 5.10.6 Tunnel with Parameters

While WLS doesn't have formal parameters, you can use temporary variables:

```whisker
:: Combat
$_enemy = "Goblin"
$_enemyHealth = 30
-> BattleSequence ->
"Victory! The $_enemy is defeated."

:: BattleSequence
"You face the $_enemy!"
{ $_enemyHealth > 0 }
  + [Attack]
    $_enemyHealth -= 10
    { $_enemyHealth > 0 }
      "The $_enemy staggers but fights on."
    {else}
      "The $_enemy falls!"
    {/}
  + [Flee]
    "You attempt to escape..."
    <- // Return early
{/}
- <-
```

### 5.10.7 Error Conditions

| Error Code | Name | Description |
|------------|------|-------------|
| WLS-FLW-009 | tunnel_target_not_found | Tunnel call to undefined passage |
| WLS-FLW-010 | missing_tunnel_return | Tunnel passage has no `<-` |
| WLS-FLW-011 | orphan_tunnel_return | `<-` outside of tunnel context |

**Example errors:**

```whisker
// WLS-FLW-009: Tunnel target not found
-> NonExistent ->

// WLS-FLW-010: Missing tunnel return (warning)
:: MyTunnel
Some content but no <- to return.

// WLS-FLW-011: Orphan tunnel return
:: Start
<-  // Error: not called as tunnel
```

### 5.10.8 Tunnel State and Save/Load

When saving game state, implementations MUST preserve:

| State | Description |
|-------|-------------|
| Call stack | Current tunnel call chain |
| Return positions | Where to continue after `<-` |
| Local variables | Temporary variables in scope |

**Example state structure:**
```json
{
  "tunnel_stack": [
    { "passage": "Morning", "position": 3 },
    { "passage": "TravelSequence", "position": 2 }
  ]
}
```

## 5.11 Advanced Flow Patterns

### 5.11.1 Hub with Tunnels

Combine tunnels with a hub passage for exploration:

```whisker
:: TownSquare
You stand in the town square.

+ [Visit blacksmith] -> Blacksmith ->
+ [Visit tavern] -> Tavern ->
+ [Visit market] -> Market ->
+ [Leave town] -> Road

// After returning from any tunnel, choices are available again
```

### 5.11.2 Gather with Conditional Branches

```whisker
:: Encounter
A stranger approaches.

+ [Greet warmly]
  $friendliness += 1
  "Hello, friend!"
+ [Nod curtly]
  "Hmph," the stranger mutters.
+ [Ignore]
  $friendliness -= 1
  They seem offended.

- { $friendliness > 0 }
  "Perhaps we could travel together?"
  + [Accept] -> TravelTogether
{else}
  They pass by without another word.
{/}
-> Continue
```

## 5.12 Error Codes Summary

| Code | Name | Severity | Description |
|------|------|----------|-------------|
| WLS-FLW-001 | dead_end | warning | Passage has no exits |
| WLS-FLW-002 | unreachable_code | warning | Code after unconditional navigation |
| WLS-FLW-003 | cycle_detected | info | Flow cycle in story |
| WLS-FLW-004 | infinite_loop | error | Guaranteed infinite loop |
| WLS-FLW-005 | unclosed_conditional | error | Missing `{/}` |
| WLS-FLW-006 | orphan_else | error | `{else}` without conditional |
| WLS-FLW-007 | invalid_gather_placement | error | Gather without preceding choices |
| WLS-FLW-008 | unreachable_gather | warning | Gather can never be reached |
| WLS-FLW-009 | tunnel_target_not_found | error | Tunnel to undefined passage |
| WLS-FLW-010 | missing_tunnel_return | warning | Tunnel has no `<-` |
| WLS-FLW-011 | orphan_tunnel_return | error | `<-` outside tunnel context |

---

**Previous Chapter:** [Variables](04-VARIABLES.md)
**Next Chapter:** [Choices](06-CHOICES.md)
