# Chapter 6: Choices

**Whisker Language Specification 1.0**

---

## 6.1 Overview

Choices are the primary mechanism for player interaction in Whisker stories. A choice presents the player with options, each leading to a different passage or outcome.

WLS provides:

| Feature | Description |
|---------|-------------|
| Once-only choices | Disappear after selection |
| Sticky choices | Remain available |
| Conditional choices | Show based on conditions |
| Choice actions | Execute code on selection |
| Fallback behavior | Handle exhausted choices |

## 6.2 Basic Choice Syntax

### 6.2.1 Simple Choices

A basic choice uses the `+` marker:

```whisker
:: Start
You stand at a crossroads.

+ [Go north] -> NorthPath
+ [Go south] -> SouthPath
+ [Go east] -> EastPath
```

**Components:**

| Component | Symbol | Required | Description |
|-----------|--------|----------|-------------|
| Marker | `+` or `*` | Yes | Choice type |
| Text | `[...]` | Yes | Displayed text |
| Arrow | `->` | Yes | Navigation indicator |
| Target | passage name | Yes | Destination passage |

### 6.2.2 Choice Text

Choice text appears within square brackets:

```whisker
+ [This text is shown to the player] -> Target
```

**Text rules:**

| Rule | Description |
|------|-------------|
| Content | Any text except unescaped `]` |
| Interpolation | Variables allowed: `[$name's choice]` |
| Escaping | Use `\]` for literal bracket |
| Length | No limit (implementation may truncate display) |

**Examples:**

```whisker
+ [Simple text] -> Target
+ [You have $gold gold. Spend some?] -> Shop
+ [Say "Hello, $npcName\!"] -> Greeting
+ [Option with \[brackets\]] -> Special
```

### 6.2.3 Navigation Targets

The arrow `->` points to the destination passage:

```whisker
+ [Go to the castle] -> Castle
+ [Enter the forest] -> DarkForest
+ [Return home] -> PlayerHome
```

**Target rules:**

| Rule | Description |
|------|-------------|
| Name | Must be valid passage identifier |
| Existence | Target passage MUST exist |
| Case | Case-sensitive matching |
| Self-reference | May target current passage |

**Special targets:**

| Target | Behavior |
|--------|----------|
| `-> END` | Ends the story |
| `-> BACK` | Returns to previous passage |
| `-> RESTART` | Restarts the story |

```whisker
:: GameOver
You have died.

+ [Try again] -> RESTART
+ [Quit] -> END
```

## 6.3 Choice Types

### 6.3.1 Once-Only Choices (`+`)

Once-only choices disappear after selection:

```whisker
:: TreasureRoom
You see a chest and a door.

+ [Open the chest] -> OpenChest      // Gone after selection
+ [Go through the door] -> NextRoom  // Gone after selection
```

**Behavior:**
- Visible until selected
- Hidden permanently after selection (within session)
- State persists across passage visits
- Restored on story restart

**Use cases:**
- One-time events
- Consumable resources
- Irreversible decisions
- Story progression

### 6.3.2 Sticky Choices (`*`)

Sticky choices remain available after selection:

```whisker
:: Library
The library is full of books.

* [Search the shelves] -> SearchShelves  // Always available
* [Read a random book] -> RandomBook     // Always available
+ [Leave the library] -> Exit            // Once-only
```

**Behavior:**
- Always visible (unless conditionally hidden)
- Can be selected multiple times
- Useful for repeatable actions

**Use cases:**
- Examining objects
- Asking questions
- Repeatable actions
- Navigation options

### 6.3.3 Comparison

| Feature | Once-Only (`+`) | Sticky (`*`) |
|---------|-----------------|--------------|
| After selection | Hidden | Visible |
| Repeat selection | No | Yes |
| Typical use | Events, decisions | Examination, navigation |
| State tracking | Yes | No |

## 6.4 Conditional Choices

### 6.4.1 Basic Conditions

Add a condition before the choice text:

```whisker
+ { condition } [Choice text] -> Target
```

The choice is only visible when the condition is true:

```whisker
:: Shop
Welcome to the armory!

+ { $gold >= 50 } [Buy sword ($50)] -> BuySword
+ { $gold >= 100 } [Buy armor ($100)] -> BuyArmor
+ { $hasVoucher } [Redeem voucher] -> RedeemVoucher
* [Just looking] -> Browse
+ [Leave] -> Exit
```

### 6.4.2 Condition Expressions

Conditions use standard Whisker expressions:

```whisker
// Comparison
+ { $level >= 10 } [Enter expert dungeon] -> ExpertDungeon

// Logical operators
+ { $hasKey and $hasTorch } [Enter dark cave] -> DarkCave

// Negation
+ { not $hasVisited } [Explore the ruins] -> Ruins

// Complex expressions
+ { ($gold >= 100 or $hasDiscount) and not $isBanned } [VIP entrance] -> VIPRoom

// Function calls
+ { whisker.visited("Cave") == 0 } [Discover the cave] -> Cave
```

### 6.4.3 Condition vs. Once-Only

Conditions and once-only behavior are independent:

| Scenario | Marker | Condition | Result |
|----------|--------|-----------|--------|
| Always visible, once | `+` | none | Shows until selected |
| Always visible, repeatable | `*` | none | Always shows |
| Conditional, once | `+` | `{ cond }` | Shows if true AND not selected |
| Conditional, repeatable | `*` | `{ cond }` | Shows if true |

**Example:**

```whisker
:: Shop
// Only shows if can afford AND hasn't bought
+ { $gold >= 50 } [Buy the unique sword] -> BuySword

// Shows whenever you can afford
* { $gold >= 10 } [Buy healing potion] -> BuyPotion
```

### 6.4.4 Dynamic Visibility

Choice visibility updates when the passage is displayed:

```whisker
:: Shop
$gold = 100

+ [Spend 60 gold] { $gold -= 60 } -> Spent60
// After selecting above, $gold = 40
// The choice below becomes hidden on revisit

+ { $gold >= 50 } [Buy expensive item] -> BuyExpensive
```

## 6.5 Choice Actions

### 6.5.1 Action Syntax

Execute code when a choice is selected:

```whisker
+ [Choice text] { action } -> Target
```

The action block executes AFTER selection but BEFORE navigation:

```whisker
+ [Buy sword ($50)] { $gold -= 50 } -> Inventory
+ [Take the gem] { $hasGem = true } -> Exit
+ [Attack] { $enemyHealth -= 10 } -> Combat
```

### 6.5.2 Action Contents

Actions can contain:

| Content | Example |
|---------|---------|
| Variable assignment | `{ $gold = 100 }` |
| Compound assignment | `{ $health -= 10 }` |
| Multiple statements | `{ $gold -= 50; $hasSword = true }` |
| Lua code | `{ whisker.state.set("items", 5) }` |

**Examples:**

```whisker
// Single assignment
+ [Pick up gold] { $gold += 25 } -> Continue

// Multiple assignments
+ [Buy equipment] { $gold -= 100; $hasArmor = true; $defense += 5 } -> Shop

// Complex logic via Lua
+ [Roll dice] { $roll = whisker.random(1, 6) } -> RollResult
```

### 6.5.3 Action Execution Order

When a choice is selected:

```
1. Player clicks/selects choice
2. Choice action executes (if any)
3. Current passage's @onExit executes (if any)
4. Navigation occurs
5. Target passage's @onEnter executes (if any)
6. Target passage renders
```

**Example:**

```whisker
:: Room1
@onExit: $exitCount += 1

+ [Go to Room2] { $transitionType = "choice" } -> Room2

:: Room2
@onEnter: $enterCount += 1

You arrived via $transitionType.
// exitCount and enterCount both incremented
```

### 6.5.4 Actions and Conditions Combined

The full choice syntax:

```whisker
marker { condition } [text] { action } -> target
```

**Order matters:**
1. Condition comes BEFORE text
2. Action comes AFTER text

```whisker
// Correct order
+ { $gold >= 50 } [Buy sword ($50)] { $gold -= 50 } -> Inventory

// Components:
// +                    - once-only marker
// { $gold >= 50 }      - condition (visibility)
// [Buy sword ($50)]    - display text
// { $gold -= 50 }      - action (on selection)
// -> Inventory         - navigation target
```

## 6.6 Choice Presentation

### 6.6.1 Choice Order

Choices are presented in document order:

```whisker
:: Room
+ [First choice] -> A    // Displayed first
+ [Second choice] -> B   // Displayed second
+ [Third choice] -> C    // Displayed third
```

Hidden choices do not affect order of visible choices.

### 6.6.2 Choice Grouping

Choices MUST appear consecutively at the end of passage content:

```whisker
:: ValidPassage
This is narrative content.
More narrative here.

+ [Choice 1] -> A
+ [Choice 2] -> B
* [Choice 3] -> C
```

**Invalid:**

```whisker
:: InvalidPassage
Some text.
+ [Choice 1] -> A
More text here.          // ERROR: Content after choices
+ [Choice 2] -> B
```

### 6.6.3 No Choices

A passage MAY have no choices:

```whisker
:: Ending
The story concludes here.
Thank you for playing.

// No choices - story ends or requires programmatic navigation
```

Implementations SHOULD handle this gracefully (see Section 6.8).

## 6.7 Advanced Patterns

### 6.7.1 Exhaustible Choice Sets

Combine once-only choices with a sticky fallback:

```whisker
:: Investigation
You examine the crime scene.

+ [Check the window] -> CheckWindow
+ [Look under the bed] -> CheckBed
+ [Examine the desk] -> CheckDesk
* [Done investigating] -> LeaveScene
```

As once-only choices are selected, they disappear. The sticky choice remains.

### 6.7.2 Resource-Gated Choices

Use conditions to gate choices by resources:

```whisker
:: Shop
Your gold: $gold

+ { $gold >= 100 } [Buy legendary sword ($100)] { $gold -= 100 } -> BuyLegendary
+ { $gold >= 50 } [Buy steel sword ($50)] { $gold -= 50 } -> BuySteel
+ { $gold >= 10 } [Buy wooden sword ($10)] { $gold -= 10 } -> BuyWood
* { $gold < 10 } [You can't afford anything] -> BrowseOnly
+ [Leave shop] -> Exit
```

### 6.7.3 State-Dependent Choices

Show different choices based on story state:

```whisker
:: ThroneRoom
You stand before the king.

{ $allegiance == "loyal" }
  + [Kneel and pledge fealty] -> PledgeFealty
  + [Report on your mission] -> MissionReport
{/}

{ $allegiance == "rebel" }
  + [Draw your hidden blade] -> Assassinate
  + [Maintain your cover] -> PlayAlong
{/}

* [Observe silently] -> Observe
```

### 6.7.4 Branching Conversations

Create dialogue trees:

```whisker
:: TalkToMerchant
"Welcome, traveler! What can I help you with?"

+ { not $askedAboutPrices } [Ask about prices] { $askedAboutPrices = true } -> MerchantPrices
+ { not $askedAboutRumors } [Ask about rumors] { $askedAboutRumors = true } -> MerchantRumors
+ { $askedAboutPrices and $askedAboutRumors } [Ask about the secret] -> MerchantSecret
* [Browse wares] -> MerchantShop
+ [Goodbye] -> MarketSquare
```

### 6.7.5 Timed Revelation

Reveal choices based on visit count:

```whisker
:: MysteriousDoor
An ancient door covered in runes.

* [Examine the runes] -> ExamineRunes
+ { whisker.visited("ExamineRunes") >= 3 } [You notice a hidden switch] -> HiddenSwitch
+ [Leave] -> Hallway
```

### 6.7.6 Mutually Exclusive Paths

Create choices that lock out alternatives:

```whisker
:: Crossroads
$pathChosen = false

+ { not $pathChosen } [Take the mountain path] { $pathChosen = true; $route = "mountain" } -> MountainPath
+ { not $pathChosen } [Take the forest path] { $pathChosen = true; $route = "forest" } -> ForestPath
+ { not $pathChosen } [Take the river path] { $pathChosen = true; $route = "river" } -> RiverPath
+ { $pathChosen } [Continue on your chosen path] -> ContinueJourney
```

## 6.8 Fallback Behavior

### 6.8.1 When All Choices Are Unavailable

If all choices become hidden (conditions false or once-only exhausted), the engine MUST handle this gracefully.

**Default behavior options:**

| Option | Description |
|--------|-------------|
| Display message | "No choices available" |
| Auto-navigate | Go to designated fallback passage |
| End story | Treat as story end |

### 6.8.2 Fallback Passage

Authors can specify a fallback:

```whisker
:: Scene
@fallback: NoChoicesLeft

+ { $option1Available } [Option 1] -> Path1
+ { $option2Available } [Option 2] -> Path2

:: NoChoicesLeft
You've exhausted all options here.
+ [Return to start] -> Start
```

### 6.8.3 Ensuring Available Choices

Best practice is to always ensure at least one choice:

```whisker
:: Room
+ { $hasKey } [Unlock door] -> UnlockedDoor
+ { not $hasKey } [Search for key] -> SearchForKey
* [Wait] -> RoomWait    // Sticky fallback always available
```

## 6.9 Choice State Persistence

### 6.9.1 Session Persistence

Once-only choice state persists for the session:

| Event | Once-Only State |
|-------|-----------------|
| Select choice | Marked as used |
| Revisit passage | Remains hidden |
| Navigate back | Remains hidden |
| Story restart | Reset to available |

### 6.9.2 Save/Load Behavior

When saving and loading:

| Data | Saved |
|------|-------|
| Selected once-only choices | Yes |
| Choice conditions (via variables) | Yes |
| Visit counts | Yes |

### 6.9.3 Implementation Requirements

Implementations MUST:

1. Track which once-only choices have been selected
2. Persist this state across passage transitions
3. Include state in save data
4. Reset state on story restart

## 6.10 Error Conditions

### 6.10.1 Choice Errors

| Error | Cause | Example |
|-------|-------|---------|
| Missing target | No `->` or target | `+ [Text]` |
| Invalid target | Target passage doesn't exist | `+ [Go] -> NonExistent` |
| Invalid condition | Syntax error in condition | `+ { $x == } [Text] -> T` |
| Invalid action | Syntax error in action | `+ [Text] { $x = } -> T` |
| Missing text | No `[...]` section | `+ -> Target` |

### 6.10.2 Error Examples

**Missing target:**

```whisker
// INVALID
+ [Go somewhere]
```

> **Error:** Choice missing navigation target. Expected `-> PassageName`.

**Invalid target:**

```whisker
// INVALID (if "Dungeon" doesn't exist)
+ [Enter] -> Dungeon
```

> **Error:** Target passage "Dungeon" does not exist.

### 6.10.3 Validation

Implementations SHOULD validate at parse time:

1. All choices have targets
2. All targets reference existing passages
3. Conditions are syntactically valid
4. Actions are syntactically valid

## 6.11 Implementation Notes

### 6.11.1 Choice Data Structure

A choice can be represented as:

```
Choice {
  type: "once" | "sticky"
  condition: Expression | null
  text: string (with interpolation markers)
  action: Statement[] | null
  target: string
  selected: boolean (runtime state)
}
```

### 6.11.2 Evaluation Algorithm

When displaying choices:

```
for each choice in passage.choices:
  if choice.type == "once" and choice.selected:
    continue  // Skip selected once-only

  if choice.condition and not evaluate(choice.condition):
    continue  // Skip failed condition

  display(interpolate(choice.text))
```

### 6.11.3 Selection Algorithm

When a choice is selected:

```
function selectChoice(choice):
  if choice.action:
    execute(choice.action)

  if choice.type == "once":
    choice.selected = true

  navigate(choice.target)
```

### 6.11.4 Performance Considerations

- Cache condition evaluation when expressions are pure
- Pre-compile choice conditions
- Index once-only state by passage + choice index
- Lazy evaluation of choice text interpolation

### 6.11.5 Accessibility

Implementations SHOULD:

- Support keyboard navigation
- Provide clear focus indicators
- Allow screen reader compatibility
- Support alternative input methods

---

**Previous Chapter:** [Control Flow](05-CONTROL_FLOW.md)
**Next Chapter:** [Lua API](07-LUA_API.md)
