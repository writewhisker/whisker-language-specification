// WLS Typed Variables Example
// Converted from v2-typed-variables.whisker (JSON Format 2.0)
// Demonstrates typed variable declarations and usage

@title: Typed Variables Example
@author: Whisker Team
@version: 1.0.0
@ifid: 12345678-1234-4234-8234-123456789abc

@vars
  playerName: "Hero"
  health: 100
  maxHealth: 100
  gold: 50
  hasKey: false
  hasMap: false
  visitedTown: false

:: Start
@tags: start

Welcome, $playerName! You have $health health and $gold gold.

+ [Check inventory] -> Inventory
+ {$health > 20} [Explore the forest] -> Forest
+ {not $visitedTown} [Visit the town] -> Town

:: Inventory
You have:
- Health: $health / $maxHealth
- Gold: $gold
- Key: {$hasKey}Yes{else}No{/}
- Map: {$hasMap}Yes{else}No{/}

+ [Back] -> Start

:: Forest
You venture into the dark forest. The trees tower above you.

+ [Search for treasures] {do gold = gold + 25; health = health - 10} -> Treasure
+ [Return home] -> Start

:: Treasure
You found 25 gold, but took some damage in the process! (Health: $health)

+ [Continue] -> Start

:: Town
@onEnter: visitedTown = true

You arrive at the bustling town. Merchants hawk their wares.

+ {$gold >= 30} [Buy health potion (30 gold)] -> BuyPotion
+ [Return] -> Start

:: BuyPotion
@onEnter: gold = gold - 30; health = math.min(health + 50, maxHealth)

You purchased a health potion and restored some health!

+ [Continue] -> Town
