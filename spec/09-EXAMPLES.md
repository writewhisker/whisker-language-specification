# Chapter 9: Examples

**Whisker Language Specification 1.0**

---

## 9.1 Overview

This chapter provides comprehensive examples demonstrating WLS features. Each example builds on previous concepts, progressing from simple to complex.

## 9.2 Hello World

The simplest possible Whisker story:

```whisker
:: Start
Hello, World!

+ [The End] -> END
```

**Output:** Displays "Hello, World!" with one choice that ends the story.

---

## 9.3 Basic Navigation

A story with multiple passages and navigation:

```whisker
@title: The Garden Path
@author: Example Author

:: Start
You stand at the entrance to a beautiful garden.
The morning sun warms your face.

+ [Enter the garden] -> Garden
+ [Walk away] -> Leave

:: Garden
Flowers bloom all around you.
A fountain bubbles peacefully in the center.

+ [Smell the roses] -> Roses
+ [Sit by the fountain] -> Fountain
+ [Leave the garden] -> Leave

:: Roses
The roses smell wonderful!
Their fragrance reminds you of summer days.

+ [Return to the garden] -> Garden

:: Fountain
You sit on the cool stone edge of the fountain.
The sound of water is soothing.

+ [Return to the garden] -> Garden

:: Leave
You leave the garden behind.
Perhaps you'll return another day.

+ [The End] -> END
```

---

## 9.4 Variables and State

Demonstrating variable declaration, assignment, and interpolation:

```whisker
@title: The Coin Collector
@author: Example Author

@vars
  gold: 0
  gems: 0
  playerName: "Traveler"

:: Start
Welcome, $playerName!

Your purse is empty. Time to find some treasure.

+ [Search the room] -> Search
+ [Check your inventory] -> Inventory

:: Search
You search the dusty room carefully.

$gold += {{ whisker.random(5, 15) }}
You found some gold coins!

{ whisker.random(1, 4) == 1 }
  $gems += 1
  A gem glitters among the coins!
{/}

+ [Search again] -> Search
+ [Check your inventory] -> Inventory
+ [Leave] -> END

:: Inventory
Current wealth:
- Gold: $gold coins
- Gems: $gems

Total value: ${$gold + ($gems * 50)} gold equivalent

+ [Keep searching] -> Search
+ [Done] -> END
```

---

## 9.5 Conditionals

Demonstrating block and inline conditionals:

```whisker
@title: The Locked Door
@author: Example Author

@vars
  hasKey: false
  doorOpen: false
  searchCount: 0

:: Hallway
You stand in a long hallway.
A heavy wooden door blocks your path.

{ $doorOpen }
  The door stands open, revealing a bright room beyond.
{elif $hasKey}
  You have a key that might fit the lock.
{else}
  The door is firmly locked.
{/}

+ { $doorOpen } [Enter the room] -> Room
+ { $hasKey and not $doorOpen } [Unlock the door] { $doorOpen = true } -> Hallway
+ { not $hasKey } [Search the hallway] -> SearchHallway
* [Examine the door] -> ExamineDoor

:: SearchHallway
$searchCount += 1

You search the hallway thoroughly.

{ $searchCount == 1 }
  You find nothing but dust.
{elif $searchCount == 2}
  Wait... there's something under the rug!
  $hasKey = true
  You found a brass key!
{else}
  You've already searched everywhere.
{/}

+ [Return to the door] -> Hallway

:: ExamineDoor
The door is {$doorOpen: open | {$hasKey: locked, but you have a key | locked}}.

It's made of solid oak with iron bands.
The lock looks {$hasKey: familiar | ancient and complex}.

+ [Back] -> Hallway

:: Room
Congratulations! You made it through!

The room is filled with treasure.

+ [Celebrate] -> END
```

---

## 9.6 Text Alternatives

Demonstrating sequence, cycle, shuffle, and once-only alternatives:

```whisker
@title: The Old Storyteller
@author: Example Author

:: Tavern
The tavern is warm and inviting.
An old storyteller sits by the fire.

{| "Ah, a new face!" | "Back again, I see." | "My favorite listener returns." | "You know the way by now." }

The fire crackles {~| softly | warmly | peacefully | gently }.

+ [Listen to a story] -> Story
+ [Buy a drink] -> Drink
+ [Leave] -> END

:: Story
The storyteller begins to speak...

{!| "Let me tell you of the Dragon of the North..." | "Have you heard of the Lost Princess?" | "There's a tale of a magic sword..." }

{ whisker.visited("Story") > 3 }
  The old man chuckles. "I've told you all my tales, friend."
{/}

The {&| fire | candles | lamplight } flickers as he speaks.

+ [Listen more] -> Story
+ [Return to the tavern] -> Tavern

:: Drink
You order a drink.

The bartender pours you {~| ale | mead | wine | cider }.

"That'll be 2 gold," {~| he says | she says | they say }.

+ [Back to your seat] -> Tavern
```

---

## 9.7 Choice Patterns

Demonstrating once-only, sticky, and conditional choices:

```whisker
@title: The Merchant's Shop
@author: Example Author

@vars
  gold: 100
  hasSword: false
  hasShield: false
  hasPotion: false

:: Shop
Welcome to the merchant's shop!
You have $gold gold.

{ $hasSword and $hasShield and $hasPotion }
  "You're fully equipped! Good luck on your journey!"
{else}
  "See anything you like?"
{/}

// Once-only choices (disappear after purchase)
+ { $gold >= 50 and not $hasSword } [Buy Iron Sword ($50)] { $gold -= 50; $hasSword = true } -> Purchased
+ { $gold >= 40 and not $hasShield } [Buy Wooden Shield ($40)] { $gold -= 40; $hasShield = true } -> Purchased
+ { $gold >= 10 and not $hasPotion } [Buy Health Potion ($10)] { $gold -= 10; $hasPotion = true } -> Purchased

// Sticky choices (always available)
* [Ask about prices] -> Prices
* [Check your gold] -> CheckGold

// Conditional exit
+ { $hasSword or $hasShield or $hasPotion } [Leave with your purchases] -> Exit
+ { not $hasSword and not $hasShield and not $hasPotion } [Leave empty-handed] -> Exit

:: Purchased
"Excellent choice!"

The merchant wraps your purchase carefully.

+ [Continue shopping] -> Shop

:: Prices
The merchant lists the prices:
- Iron Sword: 50 gold
- Wooden Shield: 40 gold
- Health Potion: 10 gold

+ [Back to shopping] -> Shop

:: CheckGold
You count your coins: $gold gold.

{ $gold < 10 }
  Not enough for anything here...
{elif $gold < 40}
  Enough for a potion, at least.
{elif $gold < 50}
  Enough for a shield or potions.
{else}
  Plenty of gold to spend!
{/}

+ [Back to shopping] -> Shop

:: Exit
You leave the shop.

Your inventory:
{ $hasSword } - Iron Sword{/}
{ $hasShield } - Wooden Shield{/}
{ $hasPotion } - Health Potion{/}
{ not $hasSword and not $hasShield and not $hasPotion } (empty){/}

Remaining gold: $gold

+ [The End] -> END
```

---

## 9.8 Lua API Usage

Demonstrating embedded Lua and API calls:

```whisker
@title: The Dice Game
@author: Example Author

@vars
  gold: 50
  wins: 0
  losses: 0

:: Casino
Welcome to the Casino!
Your gold: $gold

Wins: $wins | Losses: $losses

+ { $gold >= 10 } [Play dice ($10 bet)] -> PlayDice
+ { $gold < 10 } [You're broke!] -> Broke
* [Check the rules] -> Rules
+ [Leave] -> END

:: Rules
DICE GAME RULES:
- Cost: 10 gold per game
- Roll two dice
- 7 or 11: Win 20 gold
- 2, 3, or 12: Lose your bet
- Other: Push (get your bet back)

+ [Back to casino] -> Casino

:: PlayDice
$gold -= 10

{{
  -- Roll two dice using Lua
  local die1 = whisker.random(1, 6)
  local die2 = whisker.random(1, 6)
  whisker.state.set("die1", die1)
  whisker.state.set("die2", die2)
  whisker.state.set("total", die1 + die2)
}}

You roll the dice...

Die 1: $die1
Die 2: $die2
Total: $total

{ $total == 7 or $total == 11 }
  WINNER! You rolled a lucky $total!
  $gold += 30
  $wins += 1
{elif $total == 2 or $total == 3 or $total == 12 }
  Sorry, you lose with $total.
  $losses += 1
{else}
  Push - $total is neutral. Your bet is returned.
  $gold += 10
{/}

Your gold: $gold

+ [Play again] -> Casino

:: Broke
You've run out of gold!

Final stats:
- Wins: $wins
- Losses: $losses

{ $wins > $losses }
  Not bad - you won more than you lost!
{elif $wins < $losses }
  Better luck next time...
{else}
  You broke even!
{/}

+ [Leave] -> END
```

---

## 9.9 Visit Tracking

Demonstrating visit counting and history:

```whisker
@title: The Maze
@author: Example Author

:: Entrance
You enter the maze.

{ whisker.visited("Entrance") == 1 }
  This is your first time here.
{elif whisker.visited("Entrance") <= 3 }
  You've been here ${whisker.visited("Entrance")} times.
{else}
  You've lost count of how many times you've passed this way.
{/}

+ [Go left] -> LeftPath
+ [Go right] -> RightPath
+ { whisker.visited("LeftPath") > 0 and whisker.visited("RightPath") > 0 } [Go straight] -> Center

:: LeftPath
The left path winds through thorny hedges.

{ whisker.visited("LeftPath") == 1 }
  You notice scratch marks on the walls.
{/}

+ [Continue left] -> DeadEnd
+ [Go back] -> Entrance

:: RightPath
The right path is dark and narrow.

{ whisker.visited("RightPath") == 1 }
  You hear strange sounds ahead.
{/}

+ [Continue right] -> DeadEnd
+ [Go back] -> Entrance

:: DeadEnd
A dead end!

You've explored ${whisker.history.count()} passages so far.

+ [Return to the entrance] -> Entrance

:: Center
@onEnter: whisker.print("Player found the center!")

You found the secret center of the maze!

{ whisker.visited("Center") == 1 }
  A golden trophy awaits you!
{else}
  The empty pedestal reminds you of your victory.
{/}

+ [Celebrate and leave] -> END
```

---

## 9.10 Complete Game: The Treasure Hunt

A complete mini-game demonstrating multiple WLS features:

```whisker
@title: The Treasure Hunt
@author: Example Author
@version: 1.0.0
@ifid: 550e8400-e29b-41d4-a716-446655440000

@vars
  gold: 0
  health: 100
  hasMap: false
  hasSword: false
  hasKey: false
  treasureFound: false
  gameOver: false

// ============================================
// PART 1: THE VILLAGE
// ============================================

:: Start
@tags: beginning, village
@color: #3498db

THE TREASURE HUNT
A WLS Example Game

You are an adventurer seeking the legendary treasure
hidden in the ruins north of the village.

Gold: $gold | Health: $health

+ [Begin your adventure] -> Village

:: Village
@tags: village, hub

You stand in the village square.
{| The morning sun shines brightly. | It's a pleasant day. | The village bustles with activity. }

Villagers go about their daily business.

{ $treasureFound }
  The villagers cheer! "The hero returns!"
  + [Celebrate your victory!] -> Victory
{/}

+ { not $hasMap } [Visit the old cartographer] -> Cartographer
+ { not $hasSword } [Visit the blacksmith] -> Blacksmith
+ { $hasMap } [Head to the ruins] -> RuinsEntrance
* [Check your equipment] -> Equipment
+ [Rest at the inn] -> Inn

:: Cartographer
@tags: village, shop

An old man surrounded by maps and scrolls.

"Seeking the treasure, are you? I have just what you need."

{ not $hasMap }
  "A map to the ruins - 20 gold."
{else}
  "You already have my map. Good luck!"
{/}

+ { $gold >= 20 and not $hasMap } [Buy the map ($20)] { $gold -= 20; $hasMap = true } -> BoughtMap
+ { $gold < 20 and not $hasMap } [You need more gold...] -> Village
+ [Back to village] -> Village

:: BoughtMap
The cartographer hands you a weathered parchment.

"The ruins are dangerous. The key to the treasure vault
is guarded by an ancient beast. Be prepared!"

+ [Thank him and leave] -> Village

:: Blacksmith
@tags: village, shop

The smithy rings with the sound of hammering.

"Looking for a weapon? I've got a fine sword - 30 gold."

{ $hasSword }
  "That sword I sold you should serve you well!"
{/}

+ { $gold >= 30 and not $hasSword } [Buy the sword ($30)] { $gold -= 30; $hasSword = true } -> BoughtSword
+ { $gold < 30 and not $hasSword } [Too expensive for now...] -> Village
+ [Back to village] -> Village

:: BoughtSword
You grip the sword. It feels {~| light | balanced | powerful } in your hand.

"May it serve you well, adventurer!"

+ [Return to village] -> Village

:: Inn
@tags: village

The inn is warm and welcoming.

{ $health < 100 }
  "You look tired. Rest here for 5 gold and restore your health."
{else}
  "Looking healthy! Just passing through?"
{/}

+ { $health < 100 and $gold >= 5 } [Rest and heal ($5)] { $gold -= 5; $health = 100 } -> Rested
+ [Work for gold] -> Work
+ [Back to village] -> Village

:: Rested
You sleep soundly and wake refreshed.
Health fully restored!

+ [Return to village] -> Village

:: Work
You help around the inn for a few hours.
$gold += {{ whisker.random(8, 15) }}

"Here's your pay. Thanks for the help!"

Gold earned: $gold total now.

+ [Keep working] -> Work
+ [Return to village] -> Village

:: Equipment
CURRENT EQUIPMENT:
- Gold: $gold
- Health: $health/100
- Map: {$hasMap: Yes | No}
- Sword: {$hasSword: Yes | No}
- Vault Key: {$hasKey: Yes | No}

{ not $hasMap }
  You need a map to find the ruins.
{elif not $hasSword}
  A weapon would be wise before entering the ruins.
{else}
  You're ready for adventure!
{/}

+ [Back] -> Village

// ============================================
// PART 2: THE RUINS
// ============================================

:: RuinsEntrance
@tags: ruins
@color: #95a5a6

The ancient ruins loom before you.
Crumbling stone walls hint at former grandeur.

{ whisker.visited("RuinsEntrance") == 1 }
  According to your map, the treasure vault lies deep within.
{/}

+ [Enter the ruins] -> RuinsHall
+ [Return to village] -> Village

:: RuinsHall
@tags: ruins

A grand hall, now filled with rubble and shadows.
{~| Dust motes float in beams of light. | The air smells ancient. | Your footsteps echo eerily. }

Passages lead in three directions.

+ [Go left (sounds of water)] -> WaterRoom
+ [Go right (growling sounds)] -> BeastLair
+ { $hasKey } [Go forward (locked door)] -> TreasureVault
+ { not $hasKey } [Go forward (the door is locked)] -> LockedDoor
+ [Return to entrance] -> RuinsEntrance

:: WaterRoom
@tags: ruins

An underground pool fills most of this chamber.
Something glitters beneath the surface.

+ [Reach into the water] -> ReachWater
+ [Go back] -> RuinsHall

:: ReachWater
You plunge your hand into the cold water.

{{
  local roll = whisker.random(1, 3)
  whisker.state.set("waterRoll", roll)
}}

{ $waterRoll == 1 }
  You find some gold coins!
  $gold += 15
{elif $waterRoll == 2 }
  Something bites you!
  $health -= 10
  Ouch! You pull back quickly.
{else}
  Just rocks and mud. Nothing valuable.
{/}

+ { $health > 0 } [Try again] -> ReachWater
+ { $health > 0 } [Leave the pool] -> RuinsHall
+ { $health <= 0 } [You collapse...] -> GameOver

:: LockedDoor
The massive door is sealed with an ancient lock.
You need a key.

A worn inscription reads: "The guardian holds the key."

+ [Go back] -> RuinsHall

:: BeastLair
@tags: ruins, combat
@color: #e74c3c

{ not $hasKey }
  A massive beast blocks your path!
  Its eyes gleam with malevolence.
  Around its neck hangs a golden key.

  { $hasSword }
    + [Fight the beast!] -> Combat
    + [Retreat] -> RuinsHall
  {else}
    The beast is too powerful to fight without a weapon!
    + [Flee!] -> RuinsHall
  {/}
{else}
  The beast's lair is empty now.
  Only bones remain.
  + [Leave] -> RuinsHall
{/}

:: Combat
@onEnter: whisker.state.set("beastHealth", 50)

You engage the beast in combat!

Your health: $health
Beast health: $beastHealth

{{
  -- Combat round
  local playerDamage = whisker.random(10, 20)
  local beastDamage = whisker.random(5, 15)

  local beastHP = whisker.state.get("beastHealth")
  beastHP = beastHP - playerDamage
  whisker.state.set("beastHealth", beastHP)
  whisker.state.set("playerDamage", playerDamage)

  if beastHP > 0 then
    local hp = whisker.state.get("health")
    hp = hp - beastDamage
    whisker.state.set("health", hp)
    whisker.state.set("beastDamage", beastDamage)
  end
}}

You strike for $playerDamage damage!

{ $beastHealth <= 0 }
  The beast falls defeated!
  You claim the golden key from its neck.
  $hasKey = true
  + [Victory!] -> RuinsHall
{else}
  The beast claws you for $beastDamage damage!

  { $health <= 0 }
    + [You fall...] -> GameOver
  {else}
    + [Continue fighting!] -> CombatRound
    + [Try to flee!] -> FleeAttempt
  {/}
{/}

:: CombatRound
Your health: $health
Beast health: $beastHealth

{{
  local playerDamage = whisker.random(10, 20)
  local beastDamage = whisker.random(5, 15)

  local beastHP = whisker.state.get("beastHealth")
  beastHP = beastHP - playerDamage
  whisker.state.set("beastHealth", beastHP)
  whisker.state.set("playerDamage", playerDamage)

  if beastHP > 0 then
    local hp = whisker.state.get("health")
    hp = hp - beastDamage
    whisker.state.set("health", hp)
    whisker.state.set("beastDamage", beastDamage)
  end
}}

You strike for $playerDamage damage!

{ $beastHealth <= 0 }
  The beast collapses!
  $hasKey = true
  You take the golden key.
  + [Victory!] -> RuinsHall
{else}
  The beast strikes back for $beastDamage damage!

  { $health <= 0 }
    + [You fall...] -> GameOver
  {else}
    + [Attack again!] -> CombatRound
    + [Try to flee!] -> FleeAttempt
  {/}
{/}

:: FleeAttempt
You try to escape!

{ whisker.random(1, 2) == 1 }
  You manage to escape!
  + [Return to the hall] -> RuinsHall
{else}
  The beast blocks your escape!
  $health -= 10
  + { $health > 0 } [Fight!] -> CombatRound
  + { $health <= 0 } [You fall...] -> GameOver
{/}

// ============================================
// PART 3: THE TREASURE
// ============================================

:: TreasureVault
@tags: ruins, treasure
@color: #f1c40f
@onEnter: whisker.state.set("treasureFound", true)

The key turns in the ancient lock.
The door swings open to reveal...

THE TREASURE VAULT!

Gold coins overflow from chests.
Jewels sparkle in the torchlight.
Ancient artifacts line the walls.

$gold += 500

You've found the legendary treasure!
Total gold: $gold

+ [Return to the village as a hero!] -> Village

// ============================================
// ENDINGS
// ============================================

:: Victory
@tags: ending
@color: #27ae60

CONGRATULATIONS!

You found the legendary treasure and returned safely!

FINAL STATS:
- Gold collected: $gold
- Final health: $health
- Passages explored: ${whisker.history.count()}

THE END

+ [Play again?] -> RESTART

:: GameOver
@tags: ending
@color: #c0392b

GAME OVER

Your adventure ends here...

{ $hasKey }
  So close to the treasure...
{else}
  The treasure remains hidden.
{/}

+ [Try again?] -> RESTART
```

---

## 9.11 Example Summary

| Example | Features Demonstrated |
|---------|----------------------|
| 9.2 Hello World | Minimal story structure |
| 9.3 Basic Navigation | Passages, choices, links |
| 9.4 Variables | Declaration, assignment, interpolation |
| 9.5 Conditionals | Block/inline conditionals, elif |
| 9.6 Text Alternatives | Sequence, cycle, shuffle, once-only |
| 9.7 Choice Patterns | Once-only, sticky, conditional choices |
| 9.8 Lua API | Embedded Lua, random, state API |
| 9.9 Visit Tracking | `whisker.visited()`, history |
| 9.10 Complete Game | All features combined |

---

**Previous Chapter:** [File Formats](08-FILE_FORMATS.md)
**Next Chapter:** [Best Practices](10-BEST_PRACTICES.md)
