# Chapter 10: Best Practices

**Whisker Language Specification 1.0**

---

## 10.1 Overview

This chapter provides guidelines for writing maintainable, performant, and enjoyable Whisker stories. These are recommendations, not requirements.

## 10.2 Story Organization

### 10.2.1 File Structure

Organize large stories with clear sections:

```whisker
// ============================================
// STORY HEADER
// ============================================
@title: My Epic Adventure
@author: Jane Writer
@version: 1.0.0
@ifid: 550e8400-e29b-41d4-a716-446655440000

@vars
  // Player stats
  health: 100
  gold: 50

  // Inventory flags
  hasSword: false
  hasKey: false

  // Story progress
  chapter: 1
  questComplete: false

// ============================================
// CHAPTER 1: THE BEGINNING
// ============================================

:: Chapter1_Start
@tags: chapter1, start
...

// ============================================
// CHAPTER 2: THE JOURNEY
// ============================================

:: Chapter2_Start
@tags: chapter2, start
...
```

### 10.2.2 Passage Naming

Use consistent, descriptive passage names:

| Pattern | Example | Use Case |
|---------|---------|----------|
| Location | `Village`, `Forest`, `Cave` | Physical places |
| Action | `SearchRoom`, `TalkToGuard` | Player actions |
| Chapter prefix | `Ch1_Village`, `Ch2_Forest` | Large stories |
| State suffix | `Door_Locked`, `Door_Open` | State-dependent |

**Good names:**
```whisker
:: TavernMain
:: TavernBackRoom
:: TalkToInnkeeper
:: BuyDrink
```

**Avoid:**
```whisker
:: p1          // Not descriptive
:: passage_23  // Meaningless number
:: asdf        // Random characters
```

### 10.2.3 Using Tags

Tags help organize and query passages:

```whisker
:: Village
@tags: location, hub, chapter1

:: Combat_Goblin
@tags: combat, enemy, chapter2

:: Ending_Good
@tags: ending, victory
```

**Tag conventions:**

| Tag Type | Examples | Purpose |
|----------|----------|---------|
| Location type | `indoor`, `outdoor`, `dungeon` | Categorize places |
| Chapter | `chapter1`, `chapter2` | Story sections |
| Feature | `combat`, `puzzle`, `dialog` | Gameplay type |
| Importance | `critical`, `optional`, `secret` | Story flow |

### 10.2.4 Comments

Use comments liberally:

```whisker
// This passage handles the main combat loop
:: Combat
@tags: combat

// Initialize combat if first round
{ whisker.visited("Combat") == 1 }
  $enemyHealth = 50
{/}

/*
 * Combat resolution:
 * - Player attacks first
 * - Enemy counterattacks if alive
 * - Check for victory/defeat
 */

// Player's attack
$damage = {{ whisker.random(5, 15) }}
...
```

## 10.3 Variable Management

### 10.3.1 Naming Conventions

| Convention | Example | Use Case |
|------------|---------|----------|
| camelCase | `$playerHealth` | General variables |
| Boolean prefix | `$hasKey`, `$isAlive` | True/false flags |
| Category prefix | `$inv_sword`, `$stat_strength` | Grouped variables |
| UPPER_CASE | `$MAX_HEALTH` | Constants (by convention) |

### 10.3.2 Initialize Variables

Always initialize variables before use:

```whisker
// GOOD: Initialize in @vars
@vars
  gold: 0
  health: 100
  hasWeapon: false

// GOOD: Initialize at start
:: Start
$gold = 0
$health = 100
$hasWeapon = false

// BAD: Using uninitialized variable
:: Shop
$gold -= 50  // Error if $gold never set!
```

### 10.3.3 Use Temporary Variables

Use `_` prefix for passage-local calculations:

```whisker
:: DamageCalculation
// Temporary variables for this calculation only
_baseDamage = 10
_modifier = {{ whisker.random(1, 6) }}
_critBonus = { $criticalHit: 10 | 0 }
_totalDamage = _baseDamage + _modifier + _critBonus

// Apply to permanent state
$enemyHealth -= _totalDamage

You deal $_totalDamage damage!
// _baseDamage, _modifier, etc. are cleared on exit
```

### 10.3.4 Group Related Variables

```whisker
@vars
  // === PLAYER STATS ===
  player_health: 100
  player_maxHealth: 100
  player_gold: 50
  player_level: 1

  // === INVENTORY ===
  inv_sword: false
  inv_shield: false
  inv_potions: 0

  // === QUEST FLAGS ===
  quest_talkedToKing: false
  quest_foundArtifact: false
  quest_defeatedBoss: false

  // === SETTINGS ===
  setting_difficulty: 1
  setting_showHints: true
```

### 10.3.5 Avoid Variable Explosion

Consolidate when possible:

```whisker
// BAD: Many similar variables
$hasApple: false
$hasBanana: false
$hasCherry: false
$hasDurian: false

// BETTER: Use a count or Lua table
$fruitCount: 0

// Or track with naming pattern
$inv_apple: false
$inv_banana: false
```

## 10.4 Control Flow Patterns

### 10.4.1 Guard Clauses

Check conditions early:

```whisker
:: Shop
// Guard: Check if player can shop
{ $gold <= 0 }
  "Sorry, you have no money."
  + [Leave] -> Exit
{/}

// Main content only if guard passes
{ $gold > 0 }
  "Welcome! What would you like?"
  + [Buy sword ($50)] -> BuySword
  + [Buy potion ($10)] -> BuyPotion
{/}
```

### 10.4.2 Default Values

Always provide defaults:

```whisker
// GOOD: Default case covered
{ $faction == "rebels" }
  The rebels welcome you.
{elif $faction == "empire" }
  The imperials salute you.
{else}
  No one recognizes you.
{/}

// BAD: Missing default
{ $faction == "rebels" }
  The rebels welcome you.
{elif $faction == "empire" }
  The imperials salute you.
{/}
// What if $faction is neither?
```

### 10.4.3 Avoid Deep Nesting

Refactor deeply nested conditionals:

```whisker
// BAD: Too deep
{ $hasKey }
  { $doorUnlocked }
    { $guardAsleep }
      { $hasDisguise }
        You sneak through!
      {/}
    {/}
  {/}
{/}

// BETTER: Combine conditions
{ $hasKey and $doorUnlocked and $guardAsleep and $hasDisguise }
  You sneak through!
{/}

// OR: Use early returns (multiple passages)
{ not $hasKey }
  + [Need a key] -> FindKey
{/}
{ not $doorUnlocked }
  + [Door is locked] -> UnlockDoor
{/}
// ... etc.
```

### 10.4.4 Meaningful Alternatives

Use alternatives purposefully:

```whisker
// GOOD: Adds variety without confusion
The tavern is {~| busy | quiet | moderately full } tonight.

// BAD: Confusing when alternatives matter
The guard says the password is {~| ALPHA | BETA | GAMMA }.
// Player can't know which is correct!

// BETTER: Use sequence for reveals
The guard whispers: {| "Listen carefully..." | "The password is ALPHA." | "Remember: ALPHA." }
```

## 10.5 Choice Design

### 10.5.1 Clear Choice Text

Make choices clear and distinct:

```whisker
// GOOD: Clear actions
+ [Attack the dragon] -> Attack
+ [Try to negotiate] -> Negotiate
+ [Flee the cave] -> Flee

// BAD: Vague or similar
+ [Do something] -> Action1
+ [Take action] -> Action2
+ [Act now] -> Action3
```

### 10.5.2 Show Costs

Display costs in choice text:

```whisker
// GOOD: Cost is visible
+ { $gold >= 50 } [Buy sword ($50)] { $gold -= 50 } -> BuySword
+ { $gold >= 100 } [Buy armor ($100)] { $gold -= 100 } -> BuyArmor

// BAD: Hidden cost surprises player
+ [Buy sword] { $gold -= 50 } -> BuySword
```

### 10.5.3 Ensure Available Choices

Always provide at least one available choice:

```whisker
:: Shop
// Conditional choices might all be hidden
+ { $gold >= 100 } [Buy expensive item] -> Buy
+ { $gold >= 50 } [Buy cheap item] -> Buy

// ALWAYS include a fallback
* [Look around] -> Browse
+ [Leave] -> Exit
```

### 10.5.4 Once-Only vs Sticky

Choose the right type:

```whisker
:: Investigation
// Once-only: Clues discovered once
+ [Search under the bed] -> SearchBed
+ [Check the drawer] -> SearchDrawer
+ [Examine the painting] -> SearchPainting

// Sticky: Can repeat
* [Review your notes] -> ReviewNotes
* [Think about the case] -> Think

// Exit (once you're done)
+ [Leave the room] -> Hallway
```

## 10.6 State Management

### 10.6.1 State Machines

Use explicit states for complex logic:

```whisker
@vars
  doorState: "locked"  // locked, unlocked, open

:: Door
{ $doorState == "locked" }
  The door is locked tight.
  + { $hasKey } [Unlock the door] { $doorState = "unlocked" } -> Door
{elif $doorState == "unlocked" }
  The door is unlocked but closed.
  + [Open the door] { $doorState = "open" } -> Door
{elif $doorState == "open" }
  The door stands open.
  + [Go through] -> NextRoom
{/}

* [Examine the door] -> ExamineDoor
```

### 10.6.2 Quest Tracking

Track quests with clear flags:

```whisker
@vars
  // Quest: Find the Lost Artifact
  quest_artifact_started: false
  quest_artifact_talkedToSage: false
  quest_artifact_foundMap: false
  quest_artifact_retrieved: false
  quest_artifact_complete: false

:: Sage
{ not $quest_artifact_started }
  "Adventurer! I need your help finding a lost artifact."
  + [Accept quest] { $quest_artifact_started = true; $quest_artifact_talkedToSage = true } -> QuestAccepted
{elif $quest_artifact_retrieved and not $quest_artifact_complete }
  "You found it! Here is your reward."
  { $quest_artifact_complete = true; $gold += 100 }
{else}
  "Good luck on your quest!"
{/}
```

### 10.6.3 Inventory Patterns

```whisker
// Simple: Boolean flags
$inv_sword = true
$inv_shield = false

// With quantities
$inv_potions = 3
$inv_arrows = 20

// Usage
+ { $inv_potions > 0 } [Use potion] { $inv_potions -= 1; $health += 25 } -> Healed

// Check for any weapon
{ $inv_sword or $inv_axe or $inv_bow }
  You have a weapon ready.
{/}
```

## 10.7 Performance Tips

### 10.7.1 Minimize Lua in Hot Paths

```whisker
// AVOID: Complex Lua on every visit
:: Corridor
{{
  -- This runs every time
  for i = 1, 100 do
    -- unnecessary work
  end
}}

// BETTER: Only compute when needed
:: Corridor
{ whisker.visited("Corridor") == 1 }
  {{ -- One-time initialization }}
{/}
```

### 10.7.2 Use Simple Conditions

```whisker
// GOOD: Simple boolean check
{ $hasKey }

// LESS EFFICIENT: Complex computation
{ whisker.state.get("inventory").items.keys > 0 }

// BETTER: Cache complex results
$hasKey = {{ checkInventory("key") }}
{ $hasKey }
```

### 10.7.3 Avoid Redundant Checks

```whisker
// BAD: Repeated condition
{ $gold >= 100 }
  You can afford the sword.
{/}
{ $gold >= 100 }
  You can afford the armor.
{/}

// BETTER: Single check
{ $gold >= 100 }
  You can afford the sword.
  You can afford the armor.
{/}
```

## 10.8 Testing Strategies

### 10.8.1 Test All Paths

Ensure every passage is reachable:

```
Checklist:
[ ] All passages visited at least once
[ ] All choices tested
[ ] All conditions evaluated true AND false
[ ] All endings reached
[ ] All variable states tested
```

### 10.8.2 Edge Cases

Test boundary conditions:

```whisker
// Test when gold is exactly at threshold
$gold = 50
// Can player buy 50-gold item?

// Test empty states
$inventory = 0
// Does "no items" display correctly?

// Test maximum values
$health = 999999
// Does display handle large numbers?
```

### 10.8.3 Debug Output

Use `whisker.print()` during development:

```whisker
:: Combat
@onEnter: whisker.print("Entering combat, health:", whisker.state.get("health"))

{{
  whisker.print("Enemy health:", whisker.state.get("enemyHealth"))
  whisker.print("Player damage roll:", damage)
}}
```

### 10.8.4 Validation Checklist

Before release:

| Check | Status |
|-------|--------|
| All passages have valid targets | [ ] |
| No undefined variables used | [ ] |
| All conditions have else cases | [ ] |
| IFID is unique | [ ] |
| Start passage exists | [ ] |
| At least one ending | [ ] |

## 10.9 Common Pitfalls

### 10.9.1 Undefined Variables

```whisker
// PITFALL: Variable used before definition
:: Start
You have $gold gold.  // Error: $gold undefined!

// FIX: Initialize first
$gold = 100
You have $gold gold.
```

### 10.9.2 Missing Choice Targets

```whisker
// PITFALL: Target doesn't exist
+ [Go to castle] -> Castle  // Error if no :: Castle passage!

// FIX: Ensure passage exists
:: Castle
The castle looms above...
```

### 10.9.3 Infinite Loops

```whisker
// PITFALL: No way out
:: Room
You're in a room.
* [Look around] -> Room  // Only choice loops back!

// FIX: Provide exit
:: Room
You're in a room.
* [Look around] -> Room
+ [Leave] -> Exit
```

### 10.9.4 Unreachable Passages

```whisker
// PITFALL: Passage exists but nothing links to it
:: SecretRoom
Hidden treasure here!
// But no choice has -> SecretRoom!

// FIX: Ensure at least one path leads here
:: MainHall
+ { $foundSecretSwitch } [Enter secret room] -> SecretRoom
```

### 10.9.5 State Desync

```whisker
// PITFALL: Multiple passages modify same state
:: Shop
$gold -= 50

:: OtherShop
$gold -= 50
// Player can exploit by visiting both!

// FIX: Use flags to prevent double-spending
+ { not $boughtSword } [Buy sword] { $gold -= 50; $boughtSword = true } -> GotSword
```

### 10.9.6 Shadowing Variables

```whisker
// PITFALL: Temp shadows story var
$gold = 100
_gold = 50  // Error: shadows $gold!

// FIX: Use distinct names
$gold = 100
_tempGold = 50
```

## 10.10 Style Guide Summary

| Category | Recommendation |
|----------|----------------|
| **Naming** | camelCase for variables, descriptive passage names |
| **Structure** | Section comments, consistent tagging |
| **Variables** | Initialize early, use temps for calculations |
| **Conditions** | Guard clauses, always provide defaults |
| **Choices** | Clear text, show costs, ensure fallbacks |
| **Performance** | Simple conditions, cache complex results |
| **Testing** | Test all paths, check edge cases |

## 10.11 Turn/Time Tracking

### 10.11.1 Basic Turn Counting

Track the passage of time through turns.

```whisker
--- story
$turn = 0
$hour = 8    // Start at 8 AM
$day = 1
---

=== Any Passage ===
{$turn += 1}
{$hour += 1}
{$hour >= 24}
  {$hour = 0}
  {$day += 1}
{/}

It is {$hour < 12: morning | $hour < 18: afternoon | evening} on day $day.

// Time-gated content
{$hour >= 22 or $hour < 6}
  The streets are dark and empty.
{/}
```

### 10.11.2 Scheduled Events

```whisker
--- story
$turn = 0
ARRAY scheduledEvents = []
---

FUNCTION scheduleEvent(turnNumber, eventName)
  {{
    local events = whisker.state.get("scheduledEvents")
    table.insert(events, {turn = turnNumber, event = eventName})
    whisker.state.set("scheduledEvents", events)
  }}
END

:: StartQuest
The merchant says "Come back in 3 turns for your order."
{{ scheduleEvent(whisker.state.get("turn") + 3, "OrderReady") }}
-> Town

:: OrderReady
@tags: scheduled
The merchant waves you over. "Your order is ready!"
```

### 10.11.3 Countdown Timer

```whisker
$bombTimer = 10

:: BombRoom
@on-enter: {$bombTimer -= 1}

{$bombTimer > 5}
  The bomb beeps steadily. Plenty of time.
{$bombTimer > 2}
  The beeping is faster now. Hurry!
{$bombTimer > 0}
  BEEP BEEP BEEP! Almost out of time!
{else}
  -> Explosion
{/}

* [Cut the red wire] -> DefuseBomb
* [Cut the blue wire] -> Explosion
* [Run!] -> Escape
```

### 10.11.4 Time Formatting

```whisker
FUNCTION formatTime(hour, minute)
  {{
    local h = hour or whisker.state.get("hour")
    local m = minute or 0
    local period = h >= 12 and "PM" or "AM"
    local displayHour = h % 12
    if displayHour == 0 then displayHour = 12 end
    return string.format("%d:%02d %s", displayHour, m, period)
  }}
END

:: Clock
The time is {{ formatTime() }}.
```

## 10.12 Stat Screen Pattern

A common requirement is displaying character statistics accessible from any point in the story.

### 10.12.1 Basic Stat Screen

```whisker
--- story
$playerName = "Hero"
$health = 100
$maxHealth = 100
$gold = 50
$level = 1
---

=== StatScreen ===
@tags: system, no-save

╔══════════════════════════╗
║     CHARACTER STATS      ║
╠══════════════════════════╣
║ Name:   $playerName      ║
║ Level:  $level           ║
║ Health: $health/$maxHealth  ║
║ Gold:   $gold            ║
╚══════════════════════════╝

+ [Return] ->-> // Tunnel back

:: AnyPassage
You see a door ahead.
+ [Check Stats] ->-> StatScreen
+ [Continue] -> NextRoom
```

### 10.12.2 Stat Screen with Inventory

```whisker
ARRAY inventory = []
LIST equipped = sword, shield  // Currently equipped

=== InventoryScreen ===
@tags: system

**Inventory** (${#$inventory} items)
{ #$inventory == 0 }
  Empty!
{else}
  {{
    for i, item in ipairs(whisker.state.get("inventory")) do
      whisker.output("- " .. item .. "\n")
    end
  }}
{/}

**Equipped**:
{ $equipped ? sword } Sword (equipped) {/}
{ $equipped ? shield } Shield (equipped) {/}

+ [Return] ->->
```

### 10.12.3 Tab-Based Stat Screen

```whisker
$currentTab = "stats"

=== StatScreen ===
@tags: system

// Tab header
[ {$currentTab == "stats"} **STATS** {else} Stats {/} ]
[ {$currentTab == "inventory"} **INVENTORY** {else} Inventory {/} ]
[ {$currentTab == "quests"} **QUESTS** {else} Quests {/} ]

// Tab content
{$currentTab == "stats"}
  Name: $playerName
  Health: $health / $maxHealth
  Level: $level
{$currentTab == "inventory"}
  Gold: $gold coins
  Items: ${#$inventory}
{$currentTab == "quests"}
  Active Quests: ${#$activeQuests}
  Completed: ${#$completedQuests}
{/}

// Tab navigation
* {$currentTab ~= "stats"} [View Stats] {$currentTab = "stats"} -> StatScreen
* {$currentTab ~= "inventory"} [View Inventory] {$currentTab = "inventory"} -> StatScreen
* {$currentTab ~= "quests"} [View Quests] {$currentTab = "quests"} -> StatScreen
+ [Close] ->->
```

## 10.13 Dialog System Pattern

### 10.13.1 Basic NPC Conversation

```whisker
$npcName = ""
$talkTopics = []

:: TalkTo
@tags: dialog-system

// Dialog header
{$npcName ~= ""}
  **Talking to $npcName**
{/}

// Dynamic topic menu
+ {$talkTopics ? "greet"} [Greet them] ->-> TopicGreet
+ {$talkTopics ? "rumors"} [Ask about rumors] ->-> TopicRumors
+ {$talkTopics ? "quest"} [Ask about the quest] ->-> TopicQuest
+ [End conversation] -> EndDialog
```

### 10.13.2 Dialog with Memory

```whisker
:: Merchant
$npcName = "Marcus the Merchant"
$marcus_metBefore = $marcus_metBefore or false

{not $marcus_metBefore}
  "Welcome, stranger! I haven't seen you before."
  {$marcus_metBefore = true}
{else}
  "Ah, welcome back!"
{/}

+ [What do you sell?] ->-> MarcusShop
+ {$marcus_heardRumor} [About that rumor...] ->-> MarcusRumorFollowup
+ [Goodbye] -> Marketplace
```

### 10.13.3 Mood-Affected Dialog

```whisker
:: TalkToGuard
$guard_mood = $guard_mood or 0  // -100 to 100

{$guard_mood < -50}
  The guard glares at you. "What do YOU want?"
{elif $guard_mood < 0}
  The guard eyes you suspiciously.
{elif $guard_mood < 50}
  The guard nods at you neutrally.
{else}
  The guard smiles warmly. "Good to see you, friend!"
{/}

+ [Bribe the guard] {$gold -= 10; $guard_mood += 20} -> TalkToGuard
+ {$guard_mood >= 0} [Ask for help] ->-> GuardHelp
+ [Insult the guard] {$guard_mood -= 30} -> TalkToGuard
+ [Leave] -> CastleGate
```

## 10.14 Relationship Tracking

### 10.14.1 Simple Relationship Values

```whisker
@vars
  rel_alice: 0     // -100 (enemy) to 100 (lover)
  rel_bob: 0
  rel_carol: 0

:: CheckRelationship
FUNCTION relationshipLabel(value)
  {{
    if value >= 75 then return "Best Friend"
    elseif value >= 50 then return "Friend"
    elseif value >= 25 then return "Acquaintance"
    elseif value >= 0 then return "Neutral"
    elseif value >= -25 then return "Unfriendly"
    elseif value >= -50 then return "Hostile"
    else return "Enemy"
    end
  }}
END

Alice: {{ relationshipLabel($rel_alice) }}
```

### 10.14.2 Relationship Events

```whisker
:: HelpAlice
You help Alice carry her packages.
{$rel_alice += 10}
{$rel_alice > 50}
  She beams at you. "You're such a great friend!"
{else}
  "Thanks for the help."
{/}
-> Town

:: StealFromAlice
You pocket some of her coins when she's not looking.
{$rel_alice -= 25}
{$gold += 20}
{$rel_alice < -50}
  She notices immediately. "Thief! Guards!"
  -> Arrest
{/}
-> Town
```

### 10.14.3 Faction System

```whisker
@vars
  faction_crown: 50
  faction_rebels: 50
  faction_merchants: 50

:: FactionChoice
The king asks you to raid the merchant guild.

+ [Obey the king] {$faction_crown += 20; $faction_merchants -= 30} -> RaidMerchants
+ [Refuse] {$faction_crown -= 10} -> RefuseKing
+ {$faction_rebels >= 30} [Report to rebels] {$faction_rebels += 25; $faction_crown -= 20} -> WarnRebels

:: FactionLocked
// Doors open based on faction standing
+ {$faction_crown >= 75} [Enter the palace (Crown ally)] -> Palace
+ {$faction_rebels >= 75} [Enter the hideout (Rebel ally)] -> RebelBase
+ {$faction_merchants >= 75} [Enter the vault (Merchant ally)] -> MerchantVault
```

## 10.15 Achievement System

### 10.15.1 Simple Achievements

```whisker
@vars
  ach_firstBlood: false
  ach_pacifist: true
  ach_millionaire: false

:: AchievementCheck
FUNCTION checkAchievements()
  {{
    if whisker.state.get("gold") >= 1000000 and not whisker.state.get("ach_millionaire") then
      whisker.state.set("ach_millionaire", true)
      whisker.output("ACHIEVEMENT UNLOCKED: Millionaire!")
    end
  }}
END

:: Combat
You defeat the enemy!
{not $ach_firstBlood}
  {$ach_firstBlood = true}
  **ACHIEVEMENT UNLOCKED: First Blood**
{/}
{$ach_pacifist = false}  // No longer eligible for pacifist
-> Victory
```

### 10.15.2 Achievement Display

```whisker
LIST achievements = FirstBlood, Pacifist, Millionaire, Explorer, Completionist

:: AchievementScreen
@tags: system

**Achievements**

{achievements ? FirstBlood and $ach_firstBlood}
  [X] First Blood - Win your first battle
{else}
  [ ] First Blood - Win your first battle
{/}

{achievements ? Pacifist and $ach_pacifist}
  [X] Pacifist - Complete the game without violence
{else}
  [ ] Pacifist - Complete the game without violence
{/}

{achievements ? Millionaire and $ach_millionaire}
  [X] Millionaire - Accumulate 1,000,000 gold
{else}
  [ ] Millionaire - Accumulate 1,000,000 gold
{/}

+ [Back] ->->
```

## 10.16 Checkpoint Pattern

### 10.16.1 Manual Save Points

```whisker
:: Campfire
@tags: save-point

You rest by the campfire.
{$health = $maxHealth}
The warmth restores your strength.

+ [Save game] {whisker.save("checkpoint")} -> CampfireSaved
+ [Continue journey] -> Forest

:: CampfireSaved
Game saved!
+ [Continue] -> Campfire
```

### 10.16.2 Auto-Checkpoint

```whisker
:: ChapterStart
@tags: chapter-start
@on-enter: {{whisker.save("auto_chapter_" .. whisker.state.get("chapter"))}}

**Chapter $chapter**

The adventure continues...
-> ChapterContent

:: LoadCheckpoint
Which checkpoint would you like to load?
+ {whisker.saveExists("auto_chapter_1")} [Chapter 1] {{whisker.load("auto_chapter_1")}} -> ChapterStart
+ {whisker.saveExists("auto_chapter_2")} [Chapter 2] {{whisker.load("auto_chapter_2")}} -> ChapterStart
+ {whisker.saveExists("auto_chapter_3")} [Chapter 3] {{whisker.load("auto_chapter_3")}} -> ChapterStart
+ [Cancel] -> MainMenu
```

### 10.16.3 Death and Respawn

```whisker
$lastCheckpoint = "Start"

:: SetCheckpoint
FUNCTION saveCheckpoint(passageName)
  {{
    whisker.state.set("lastCheckpoint", passageName)
    whisker.save("checkpoint")
  }}
END

:: SafeRoom
{{ saveCheckpoint("SafeRoom") }}
You feel safe here. [Checkpoint saved]
+ [Continue] -> Dungeon

:: Death
You have died.

{$lives > 0}
  Lives remaining: ${$lives - 1}
  + [Continue from checkpoint] {$lives -= 1} {{whisker.load("checkpoint")}} -> $lastCheckpoint
{else}
  GAME OVER
  + [Start new game] -> RESTART
{/}
```

---

**Previous Chapter:** [Examples](09-EXAMPLES.md)
**Next Chapter:** [Appendices](APPENDICES.md)
