@title: Modules Demo
@author: WLS
@version: 1.0.0

@vars
  $playerName = "Hero"
  $gold = 100
  $health = 100
@/vars

-- WLS Gap 4: Module Features Demo
-- This story demonstrates FUNCTION, NAMESPACE, and INCLUDE features

-- =============================================================================
-- FUNCTION Definitions
-- =============================================================================

-- A reusable function to display player status
FUNCTION showStatus()
  You have ${$health} health and ${$gold} gold.
END

-- A function with parameters
FUNCTION greet(name)
  Hello, ${name}! Welcome to the adventure.
END

-- A function with RETURN
FUNCTION formatItem(item, quantity)
  RETURN ${quantity}x ${item}
END

-- =============================================================================
-- NAMESPACE: Combat System
-- =============================================================================

NAMESPACE Combat

:: Attack
@fallback: ->Combat::Retreat

{do $health = $health - 10}
You strike at the enemy! But they counter-attack.
You take 10 damage. ${showStatus()}

+ [Continue fighting] ->Combat::Attack
+ [Retreat] ->Combat::Retreat

:: Retreat
You fall back to safety.

+ [Return to camp] ->::Start

END NAMESPACE

-- =============================================================================
-- NAMESPACE: Shop System
-- =============================================================================

NAMESPACE Shop

:: Enter
Welcome to the village shop!

{$gold >= 50}
You have enough gold to make some purchases.
{/}
{$gold < 50}
You're a bit low on gold...
{/}

+ [Buy health potion (50 gold)] {$gold >= 50} ->Shop::BuyPotion
+ [Leave shop] ->::Village

:: BuyPotion
{do $gold = $gold - 50}
{do $health = $health + 50}
You purchase a health potion and drink it immediately.
Your health is restored! ${showStatus()}

+ [Buy another] {$gold >= 50} ->Shop::BuyPotion
+ [Leave] ->::Village

END NAMESPACE

-- =============================================================================
-- Main Story Passages (Global Namespace)
-- =============================================================================

:: Start

${greet($playerName)}

You stand at the crossroads of adventure.
${showStatus()}

+ [Visit the village] ->Village
+ [Enter the dungeon] ->Combat::Attack
+ [Check inventory] ->Inventory

:: Village

The village is peaceful. You see a shop in the distance.

+ [Visit the shop] ->Shop::Enter
+ [Return to crossroads] ->Start
+ [Rest at inn (free)] ->Rest

:: Rest
{do $health = 100}
You rest at the inn and fully recover.
${showStatus()}

+ [Continue] ->Village

:: Inventory

Your inventory:
- ${formatItem("Gold coins", $gold)}
- Health: ${$health}

+ [Back] ->Start
