// WLS Example: Conditionals
// Demonstrates conditional blocks, elif chains, and nested conditions

@title: Conditionals Demo
@author: Whisker Author

@vars
  score: 75
  hasPermission: true
  playerClass: "warrior"
  level: 5
  gold: 150

:: Start
Your current score is $score.

+ [Check grade] -> Grade
+ [Check access] -> Access
+ [Check class abilities] -> ClassAbilities
+ [Check shop discounts] -> ShopDiscounts
+ [Nested conditions demo] -> NestedDemo

// Simple if/else
:: Grade
Your score: $score

{$score >= 90}
  Grade: A - Excellent!
{elif $score >= 80}
  Grade: B - Good job!
{elif $score >= 70}
  Grade: C - Satisfactory.
{elif $score >= 60}
  Grade: D - Needs improvement.
{else}
  Grade: F - Please try again.
{/}

+ [Change score to 95] {do score = 95} -> Grade
+ [Change score to 55] {do score = 55} -> Grade
+ [Back] -> Start

// Boolean conditions
:: Access
Checking access permissions...

{$hasPermission}
  Access GRANTED. Welcome!
{else}
  Access DENIED. You do not have permission.
{/}

+ [Toggle permission] {do hasPermission = not hasPermission} -> Access
+ [Back] -> Start

// String comparison
:: ClassAbilities
Your class: $playerClass

{$playerClass == "warrior"}
  As a warrior, you can use:
  - Heavy Strike (deals 2x damage)
  - Shield Block (reduces damage by 50%)
  - Battle Cry (boosts party morale)
{elif $playerClass == "mage"}
  As a mage, you can use:
  - Fireball (area damage)
  - Frost Nova (freezes enemies)
  - Teleport (instant travel)
{elif $playerClass == "rogue"}
  As a rogue, you can use:
  - Backstab (critical damage from behind)
  - Stealth (become invisible)
  - Pickpocket (steal items)
{else}
  Unknown class. No special abilities.
{/}

+ [Change to mage] {do playerClass = "mage"} -> ClassAbilities
+ [Change to rogue] {do playerClass = "rogue"} -> ClassAbilities
+ [Change to warrior] {do playerClass = "warrior"} -> ClassAbilities
+ [Back] -> Start

// Combined conditions with AND/OR
:: ShopDiscounts
Welcome to the shop!

Your level: $level
Your gold: $gold

{$level >= 10 and $gold >= 500}
  VIP Customer! You get 30% off all items.
{elif $level >= 5 or $gold >= 200}
  Valued Customer! You get 15% off all items.
{else}
  Standard pricing applies.
{/}

// Multiple independent conditions
{$gold < 50}
  Warning: You're running low on gold!
{/}

{$level == 5}
  Tip: Reach level 10 for VIP status!
{/}

+ [Add 100 gold] {do gold = gold + 100} -> ShopDiscounts
+ [Level up] {do level = level + 1} -> ShopDiscounts
+ [Back] -> Start

// Deeply nested conditions
:: NestedDemo
Demonstrating nested conditionals...

{$level >= 1}
  Level 1 or higher:
  {$level >= 3}
    Level 3 or higher:
    {$level >= 5}
      Level 5 or higher:
      {$level >= 10}
        You are a master! (Level 10+)
      {else}
        You are experienced. (Level 5-9)
      {/}
    {else}
      You are learning. (Level 3-4)
    {/}
  {else}
    You are a beginner. (Level 1-2)
  {/}
{else}
  You haven't started yet.
{/}

+ [Set level to 1] {do level = 1} -> NestedDemo
+ [Set level to 4] {do level = 4} -> NestedDemo
+ [Set level to 7] {do level = 7} -> NestedDemo
+ [Set level to 12] {do level = 12} -> NestedDemo
+ [Back] -> Start

// NOT operator
:: NotDemo
{not $hasPermission}
  You lack permission. Please request access.
{else}
  You have full access!
{/}

{not ($score < 50)}
  Your score is acceptable (50 or above).
{/}

+ [Back] -> Start
