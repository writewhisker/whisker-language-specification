// WLS MAP Example
// Demonstrates MAP declarations and operations
// MAPs are key-value collections (objects)

@title: MAP Collections Example
@author: Whisker Team
@version: 1.0.0
@ifid: 15151515-1515-4151-8151-151515151515

// MAP declarations
MAP player = {
  name: "Hero",
  health: 100,
  maxHealth: 100,
  gold: 50,
  level: 1
}

MAP enemy = {
  name: "Goblin",
  health: 30,
  attack: 10,
  gold: 15
}

MAP shop = {
  potion: 25,
  sword: 100,
  armor: 150
}

:: Start
@tags: start

Welcome, {map_get(player, "name")}!

Your stats:
- Health: {map_get(player, "health")} / {map_get(player, "maxHealth")}
- Gold: {map_get(player, "gold")}
- Level: {map_get(player, "level")}

+ [Fight enemy] -> Fight
+ [Visit shop] -> Shop
+ [Rest] -> Rest

:: Fight
A {map_get(enemy, "name")} appears with {map_get(enemy, "health")} health!

+ [Attack] -> Attack
+ [Flee] -> Start

:: Attack
@onEnter: map_set(enemy, "health", map_get(enemy, "health") - 20); map_set(player, "health", map_get(player, "health") - map_get(enemy, "attack"))

You strike the {map_get(enemy, "name")}!

Enemy health: {map_get(enemy, "health")}
Your health: {map_get(player, "health")}

+ {map_get(enemy, "health") <= 0} [Victory!] -> Victory
+ {map_get(enemy, "health") > 0} [Attack again] -> Attack
+ [Flee] -> Start

:: Victory
@onEnter: map_set(player, "gold", map_get(player, "gold") + map_get(enemy, "gold")); map_set(player, "level", map_get(player, "level") + 1); map_set(enemy, "health", 30)

You defeated the {map_get(enemy, "name")}!
You gained {map_get(enemy, "gold")} gold and leveled up!

Current gold: {map_get(player, "gold")}
Current level: {map_get(player, "level")}

+ [Continue] -> Start

:: Shop
Welcome to the shop!

Available items:
- Potion: {map_get(shop, "potion")} gold
- Sword: {map_get(shop, "sword")} gold
- Armor: {map_get(shop, "armor")} gold

Your gold: {map_get(player, "gold")}

+ {map_get(player, "gold") >= map_get(shop, "potion")} [Buy potion] -> BuyPotion
+ [Leave] -> Start

:: BuyPotion
@onEnter: map_set(player, "gold", map_get(player, "gold") - map_get(shop, "potion")); map_set(player, "health", map_get(player, "maxHealth"))

You bought a potion and restored your health!
Remaining gold: {map_get(player, "gold")}

+ [Continue] -> Shop

:: Rest
@onEnter: map_set(player, "health", map_get(player, "maxHealth"))

You rest and recover to full health.
Health: {map_get(player, "health")}

+ [Continue] -> Start
