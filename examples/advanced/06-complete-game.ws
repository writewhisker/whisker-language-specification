// WLS Example: Complete Game
// A full interactive fiction game demonstrating all WLS features

@title: The Crystal Caverns
@author: Whisker Author
@version: 1.0
@ifid: 12345678-1234-1234-1234-123456789ABC

@vars
  // Player stats
  playerName: "Adventurer"
  health: 100
  maxHealth: 100
  gold: 50

  // Inventory flags
  hasTorch: false
  hasKey: false
  hasSword: false
  hasPotion: false
  hasGem: false

  // Game state
  dragonDefeated: false
  treasureFound: false

  // Combat stats
  attackPower: 10
  defense: 5

:: Start
{*
  ===================================
     THE CRYSTAL CAVERNS
  ===================================

  An Interactive Adventure
}

{$treasureFound}
  Welcome back, $playerName!
  You've already found the legendary treasure.

  + [Play again] -> RESTART
  + [View your stats] -> Stats
{else}
  Welcome, brave adventurer!

  You stand at the entrance to the legendary Crystal Caverns.
  Ancient tales speak of untold riches within... and terrible dangers.

  + [Enter the caverns] -> CavernEntrance
  + [Visit the village first] -> Village
  + [Check your equipment] -> Stats
{/}

:: Stats
=== $playerName's Stats ===

Health: $health / $maxHealth
Gold: $gold coins
Attack: $attackPower
Defense: $defense

=== Inventory ===
Torch: {$hasTorch}Yes{else}No{/}
Key: {$hasKey}Yes{else}No{/}
Sword: {$hasSword}Yes{else}No{/}
Potion: {$hasPotion}Yes{else}No{/}
Crystal Gem: {$hasGem}Yes{else}No{/}

+ [Continue] -> BACK

:: Village
You arrive at a small village near the caverns.

{| "First time here?" a villager asks. "Be careful in those caves!"
 | The villagers go about their daily routines.
 | A child runs past, playing with a wooden sword.
 | An old woman eyes you suspiciously from her doorway. }

+ [Visit the shop] -> Shop
+ [Talk to the elder] -> Elder
+ [Rest at the inn ($20)] {$gold >= 20} {do gold = gold - 20; health = maxHealth} -> VillageRest
+ [Head to the caverns] -> CavernEntrance
+ [Check stats] -> Stats

:: VillageRest
You rest at the cozy inn.

Your health has been fully restored!
Health: $health / $maxHealth

+ [Continue] -> Village

:: Shop
The shopkeeper greets you.

"Welcome! {~| Looking for supplies? | Need something for the caves? | I have quality goods! }"

Your gold: $gold

+ {$gold >= 30 and not $hasTorch} [Buy torch (30g)] {do gold = gold - 30; hasTorch = true} -> ShopBuy
+ {$gold >= 50 and not $hasPotion} [Buy health potion (50g)] {do gold = gold - 50; hasPotion = true} -> ShopBuy
+ {$gold >= 100 and not $hasSword} [Buy sword (100g)] {do gold = gold - 100; hasSword = true; attackPower = 25} -> ShopBuy
+ [Leave shop] -> Village

:: ShopBuy
"Excellent choice!" the shopkeeper says.

You now have $gold gold remaining.

+ [Continue shopping] -> Shop
+ [Leave shop] -> Village

:: Elder
The village elder sits by the fire.

"{* Ah, a new face. } You seek the crystal treasure, don't you?"

He strokes his beard thoughtfully.

"Many have tried. Few return. The dragon guards the deepest chamber."

{$hasSword}
  He eyes your sword. "Good. You'll need that."
{else}
  "You'll need a proper weapon. Visit the shop."
{/}

{not $dragonDefeated}
  "The dragon can only be defeated with courage... and preparation."
{else}
  "I heard you defeated the dragon! Remarkable!"
{/}

+ [Ask about the key] -> ElderKey
+ [Thank him and leave] -> Village

:: ElderKey
"The locked chamber? Yes, there is a key hidden in the caves."

"Look for a {~| glimmering | faint | mysterious } light in the eastern passage."

+ [Thank him] -> Village

:: CavernEntrance
You stand at the cavern entrance.

{$hasTorch}
  Your torch casts dancing shadows on the walls.
{else}
  It's very dark. You can barely see.
{/}

Cold air rushes from the depths below.

+ [Enter the main chamber] -> MainChamber
+ [Take the eastern passage] -> EasternPassage
+ {not $dragonDefeated} [Take the western passage (Dragon's Lair)] -> DragonApproach
+ {$dragonDefeated and $hasKey} [Enter the treasure chamber] -> TreasureChamber
+ [Return to village] -> Village

:: MainChamber
The main chamber is vast.

{| Crystal formations sparkle in the dim light.
 | You hear water dripping somewhere in the distance.
 | Strange echoes bounce off the walls.
 | The air is thick with ancient dust. }

{$hasTorch}
  Your torch reveals {~| ancient carvings | scattered bones | abandoned mining tools | footprints in the dust }.
{else}
  You stumble in the darkness. (-5 health)
  {do health = health - 5}
{/}

{* You discover a small pouch with 20 gold! }
{* do gold = gold + 20 }

Your health: $health

+ [Search for treasure] -> SearchMain
+ [Go deeper] -> DeepCavern
+ [Return to entrance] -> CavernEntrance

:: SearchMain
You search the chamber carefully.

{~| You find nothing of value. | You find a few copper coins (+5 gold). {do gold = gold + 5} | A bat startles you! | You discover old miner's notes. }

+ [Continue searching] -> SearchMain
+ [Go back] -> MainChamber

:: DeepCavern
You venture into the deeper caves.

The passage narrows. {&| You hear a distant roar. | Crystals pulse with inner light. | The ground trembles slightly. }

{not $hasTorch}
  Without a torch, you trip and fall! (-10 health)
  {do health = health - 10}
{/}

{$health <= 0}
  Your vision fades...
  + [You have perished] -> GameOver
{else}
  + [Press on] -> MainChamber
  + [Go back] -> CavernEntrance
{/}

:: EasternPassage
The eastern passage is narrow but manageable.

{$hasTorch}
  Your torch illuminates a hidden alcove!

  {not $hasKey}
    Inside, you find an ornate golden key!
    {do hasKey = true}

    "This must unlock the treasure chamber," you think.
  {else}
    The alcove where you found the key is empty.
  {/}
{else}
  It's too dark to see anything here.
{/}

+ [Return to entrance] -> CavernEntrance

:: DragonApproach
The passage leads to the dragon's lair.

{$hasSword}
  You grip your sword tightly.
{else}
  You have no weapon! This is extremely dangerous!
{/}

A deep, rumbling growl echoes from ahead.

+ [Face the dragon] -> DragonFight
+ [Retreat] -> CavernEntrance

:: DragonFight
The dragon emerges from the shadows!

Its scales gleam like {~| rubies | blood | fire | molten metal }.

{$hasSword}
  Your attack: $attackPower

  You charge forward, sword raised!

  {do _damage = attackPower - 5}

  The battle is fierce! You deal significant damage.
  The dragon retaliates! (-20 health)
  {do health = health - 20}

  {$hasPotion}
    + [Use health potion (+50 health)] {do health = health + 50; hasPotion = false} -> DragonFight2
  {/}
  + [Continue fighting] -> DragonFight2
  + [Try to flee] -> DragonFlee
{else}
  Without a weapon, you stand no chance!
  The dragon's fire engulfs you! (-50 health)
  {do health = health - 50}

  + [Flee!] -> DragonFlee
{/}

:: DragonFight2
{$health <= 0}
  The dragon's flames consume you...
  + [You have perished] -> GameOver
{else}
  Health: $health

  You strike the dragon's weak point!

  With a terrible roar, the beast collapses!

  {do dragonDefeated = true; gold = gold + 100}

  You've defeated the dragon! (+100 gold)

  A crystal gem falls from its hoard.
  {do hasGem = true}

  + [Claim your prize and continue] -> CavernEntrance
{/}

:: DragonFlee
You run as fast as you can!

The dragon's fire singes your back! (-15 health)
{do health = health - 15}

{$health <= 0}
  You didn't make it...
  + [You have perished] -> GameOver
{else}
  You barely escape with your life!
  Health: $health

  + [Return to entrance] -> CavernEntrance
{/}

:: TreasureChamber
You use the golden key to unlock the ancient door.

It swings open with a groan.

Before you lies the legendary Crystal Cavern Treasure!

Mountains of gold, precious gems, and ancient artifacts
fill the chamber, glittering in ethereal light.

{do treasureFound = true; gold = gold + 1000}

You've found the treasure! (+1000 gold)

Your total gold: $gold

=== CONGRATULATIONS! ===
You have completed The Crystal Caverns!

+ [Return to the surface victorious] -> Victory

:: Victory
You emerge from the caverns, laden with treasure.

The villagers cheer as you approach!

"$playerName has conquered the Crystal Caverns!"

You are celebrated as a hero.

=== THE END ===

Final Stats:
- Gold: $gold
- Items collected: {$hasGem}Crystal Gem, {/}{$hasSword}Sword, {/}{$hasTorch}Torch{/}
- Dragon defeated: {$dragonDefeated}Yes!{else}No{/}

+ [Play again] -> RESTART
+ [View stats] -> Stats

:: GameOver
=== GAME OVER ===

Your adventure has come to an untimely end.

The Crystal Caverns claim another soul...

+ [Try again] -> RESTART
