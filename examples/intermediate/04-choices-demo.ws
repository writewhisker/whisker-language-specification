// WLS Example: Choices
// Demonstrates all choice syntax variations

@title: Choices Demo
@author: Whisker Author

@vars
  gold: 100
  hasWeapon: false
  reputation: 50
  questComplete: false

:: Start
This example demonstrates different types of choices.

+ [Basic choices] -> BasicChoices
+ [Conditional choices] -> ConditionalChoices
+ [Choice actions] -> ChoiceActions
+ [Special targets] -> SpecialTargets
+ [Once-only choices] -> OnceOnly
+ [Full syntax demo] -> FullSyntax

// Basic choice syntax
:: BasicChoices
Basic Choice Syntax:

The simplest form is: + [Text] -> Target

+ [Go to the castle] -> Castle
+ [Visit the market] -> Market
+ [Return] -> Start

:: Castle
You arrive at the grand castle.

+ [Enter] -> CastleInside
+ [Go back] -> BasicChoices

:: CastleInside
The castle interior is magnificent!

+ [Explore more] -> Castle
+ [Leave] -> BasicChoices

:: Market
The market is bustling with activity.

+ [Browse stalls] -> Market
+ [Go back] -> BasicChoices

// Conditional choices - only show when condition is true
:: ConditionalChoices
Conditional Choices:

Your gold: $gold
Has weapon: $hasWeapon
Reputation: $reputation

Conditional choices only appear when their condition is true:

+ [$gold >= 50] [Buy supplies (50g)] {do gold = gold - 50} -> ConditionalChoices
+ [$gold >= 200] [Buy a weapon (200g)] {do gold = gold - 200; hasWeapon = true} -> ConditionalChoices
+ [$hasWeapon] [Show off your weapon] -> ShowWeapon
+ [$reputation >= 75] [Access VIP area] -> VIPArea
+ [$reputation < 25] [Sneak around] -> Sneak
+ [Add 100 gold] {do gold = gold + 100} -> ConditionalChoices
+ [Increase reputation] {do reputation = reputation + 30} -> ConditionalChoices
+ [Return] -> Start

:: ShowWeapon
You proudly display your weapon!

The crowd is impressed.

+ [Continue] -> ConditionalChoices

:: VIPArea
Welcome to the exclusive VIP area!

+ [Return] -> ConditionalChoices

:: Sneak
You slip through the shadows unnoticed...

+ [Return] -> ConditionalChoices

// Choice actions - execute code when selected
:: ChoiceActions
Choice Actions:

Actions run when a choice is selected.
Your gold: $gold

+ [Find 10 gold] {do gold = gold + 10} -> ChoiceActions
+ [Find 50 gold] {do gold = gold + 50} -> ChoiceActions
+ [Lose 25 gold] {do gold = gold - 25} -> ChoiceActions
+ [Reset gold to 100] {do gold = 100} -> ChoiceActions
+ [Complete quest] {do questComplete = true; gold = gold + 100} -> QuestReward
+ [Return] -> Start

:: QuestReward
Quest completed! You earned 100 gold.

Your gold is now $gold.

+ [Continue] -> ChoiceActions

// Special navigation targets
:: SpecialTargets
Special Targets:

- END: End the story
- BACK: Return to previous passage
- RESTART: Start over from the beginning

+ [End the story] -> END
+ [Go back one step] -> BACK
+ [Restart from beginning] -> RESTART
+ [Return to menu] -> Start

// Once-only choices (use * instead of +)
:: OnceOnly
Once-Only Choices:

Once-only choices (*) disappear after being selected.
Sticky choices remain available.

Each item below can only be picked once:

* [Pick up the red gem] {do gold = gold + 10} -> OnceOnly
* [Pick up the blue gem] {do gold = gold + 20} -> OnceOnly
* [Pick up the green gem] {do gold = gold + 30} -> OnceOnly

Your gold: $gold

+ [Return to menu] -> Start

// Full syntax combining everything
:: FullSyntax
Full Choice Syntax:

The complete syntax combines conditions and actions:
+ {condition} [Text] {actions} -> Target

Your gold: $gold
Reputation: $reputation

// Conditional + Action + Target
+ {$gold >= 100} [Donate 100 gold (+50 rep)] {do gold = gold - 100; reputation = reputation + 50} -> FullSyntax

// Just condition + Target
+ {$reputation >= 100} [Enter the Hall of Fame] -> HallOfFame

// Just action + Target
+ [Work for gold] {do gold = gold + 25} -> FullSyntax

// Variable interpolation in choice text
+ [You have $gold gold - view stats] -> Stats

+ [Return] -> Start

:: HallOfFame
Congratulations! You've achieved legendary reputation!

Your name will be remembered forever.

+ [Return] -> FullSyntax

:: Stats
Current Stats:
- Gold: $gold
- Reputation: $reputation
- Quest Complete: {$questComplete}Yes{else}No{/}

+ [Back] -> FullSyntax
