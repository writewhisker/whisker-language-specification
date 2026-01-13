// WLS ARRAY Example
// Demonstrates ARRAY declarations and operations
// ARRAYs are 0-indexed collections with numeric indices

@title: ARRAY Collections Example
@author: Whisker Team
@version: 1.0.0
@ifid: 14141414-1414-4141-8141-141414141414

// ARRAY declarations
ARRAY inventory = ["sword", "shield", "potion"]
ARRAY scores = [100, 85, 92, 78]
ARRAY dungeonLevels = ["entrance", "catacombs", "treasury", "throne"]

@vars
  currentLevel: 0
  playerName: "Hero"

:: Start
@tags: start

Welcome, $playerName!

You are at dungeon level $currentLevel: {array_get(dungeonLevels, $currentLevel)}.

Your inventory has {array_length(inventory)} items.

+ [View inventory] -> ViewInventory
+ [Check scores] -> ViewScores
+ {$currentLevel < 3} [Descend deeper] -> Descend
+ {$currentLevel > 0} [Go back up] -> Ascend

:: ViewInventory
Your inventory:
{array_foreach(inventory)}
- Item {index}: {value}
{/array_foreach}

+ [Add an item] -> AddItem
+ [Back] -> Start

:: AddItem
@onEnter: array_push(inventory, "gold coin")

You found a gold coin and added it to your inventory!
Inventory now has {array_length(inventory)} items.

+ [Continue] -> ViewInventory

:: ViewScores
High scores:
{array_foreach(scores)}
- Score {index + 1}: {value} points
{/array_foreach}

Average score: {array_sum(scores) / array_length(scores)}

+ [Add new score] -> AddScore
+ [Back] -> Start

:: AddScore
@onEnter: array_push(scores, 95)

Added new score: 95 points!

+ [Continue] -> ViewScores

:: Descend
@onEnter: currentLevel = currentLevel + 1

You descend to level $currentLevel: {array_get(dungeonLevels, $currentLevel)}.

+ [Continue] -> Start

:: Ascend
@onEnter: currentLevel = currentLevel - 1

You ascend to level $currentLevel: {array_get(dungeonLevels, $currentLevel)}.

+ [Continue] -> Start
