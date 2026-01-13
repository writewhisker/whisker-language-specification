// WLS LIST Example
// Demonstrates LIST declarations and operations
// LISTs are enumerated sets where values can be active or inactive

@title: LIST Collections Example
@author: Whisker Team
@version: 1.0.0
@ifid: 13131313-1313-4131-8131-131313131313

// LIST declarations - parentheses mark initially inactive values
LIST moods = happy, (sad), (angry), calm
LIST items = torch, (rope), (key), map
LIST skills = strength, (magic), (stealth)

@vars
  playerName: "Adventurer"

:: Start
@tags: start

Welcome, $playerName! Your current mood is: {list_active(moods)}.

You have the following items: {list_active(items)}.

+ [Check your skills] -> Skills
+ [Find the rope] -> FindRope
+ [Get angry] -> GetAngry

:: Skills
Your skills:
- Strength: {list_contains(skills, strength)}active{else}inactive{/}
- Magic: {list_contains(skills, magic)}active{else}inactive{/}
- Stealth: {list_contains(skills, stealth)}active{else}inactive{/}

+ {not list_contains(skills, magic)} [Learn magic] -> LearnMagic
+ [Back] -> Start

:: LearnMagic
@onEnter: list_add(skills, magic)

You have learned the art of magic!

+ [Continue] -> Skills

:: FindRope
@onEnter: list_add(items, rope)

You found a rope and added it to your inventory!

+ [Continue] -> Start

:: GetAngry
@onEnter: list_remove(moods, calm); list_add(moods, angry)

You feel anger rising within you!

+ [Calm down] -> CalmDown
+ [Stay angry] -> Start

:: CalmDown
@onEnter: list_remove(moods, angry); list_add(moods, calm)

You take a deep breath and calm yourself.

+ [Continue] -> Start
