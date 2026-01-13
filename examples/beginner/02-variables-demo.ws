// WLS Example: Variables
// Demonstrates variable declaration, types, and interpolation

@title: Variables Demo
@author: Whisker Author

// Declare story variables with initial values
@vars
  playerName: "Hero"
  gold: 100
  health: 100
  hasKey: false
  level: 1
  damageMultiplier: 1.5

:: Start
Welcome, $playerName!

Your stats:
- Gold: $gold
- Health: $health
- Level: $level

+ [Check inventory] -> Inventory
+ [Visit the shop] -> Shop
+ [Enter the dungeon] -> Dungeon

:: Inventory
Inventory for $playerName:

Gold coins: $gold
Key: {$hasKey}Yes{else}No{/}

Your damage multiplier is $damageMultiplier.

+ [Back] -> Start

:: Shop
The merchant greets you.

"Ah, $playerName! You have $gold gold."

+ [$gold >= 50] [Buy a potion (50g)] {do gold = gold - 50; health = health + 25} -> ShopBuy
+ [$gold >= 75] [Buy a key (75g)] {do gold = gold - 75; hasKey = true} -> ShopBuy
+ [Leave] -> Start

:: ShopBuy
"Thank you for your purchase!"

You now have $gold gold remaining.
Your health is $health.

+ [Continue shopping] -> Shop
+ [Leave] -> Start

:: Dungeon
You enter the dark dungeon.

{$hasKey}
  You use your key to unlock the treasure room!
  {do gold = gold + 200}
  You found 200 gold! You now have $gold gold.
  + [Exit victorious] -> END
{else}
  The treasure room is locked. You need a key!
  + [Leave the dungeon] -> Start
{/}

// Demonstrate temporary variables (passage-scoped)
:: Combat
{do _damage = 10 * damageMultiplier}
You deal $_damage damage!

// Temporary variables reset when leaving the passage
+ [Attack again] -> Combat
+ [Flee] -> Start

// Demonstrate string concatenation
:: Greeting
{do _fullName = playerName .. " the Brave"}
Hail, $_fullName!

+ [Continue] -> Start

// Demonstrate expression interpolation
:: Stats
Advanced Stats:
- Attack Power: ${10 * damageMultiplier}
- Defense: ${level * 5}
- Max Health: ${100 + (level * 10)}

+ [Back] -> Start
