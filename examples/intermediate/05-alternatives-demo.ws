// WLS Example: Text Alternatives
// Demonstrates sequence, cycle, shuffle, and once-only alternatives

@title: Text Alternatives Demo
@author: Whisker Author

@vars
  visitCount: 0

:: Start
Text alternatives show different content on each visit.

+ [Sequence alternatives] -> SequenceDemo
+ [Cycle alternatives] -> CycleDemo
+ [Shuffle alternatives] -> ShuffleDemo
+ [Once-only alternatives] -> OnceOnlyDemo
+ [Combined example] -> CombinedDemo
+ [Practical example] -> PracticalDemo

// Sequence: Shows each option in order, then sticks on the last
:: SequenceDemo
{do visitCount = visitCount + 1}
Visit #$visitCount

Sequence alternatives {| ... | ... | ... } show options in order:

The weather is {| sunny | cloudy | rainy | stormy | still stormy }.

This is useful for:
{| the first visit. | the second visit. | the third visit. | subsequent visits. }

+ [Visit again] -> SequenceDemo
+ [Reset counter] {do visitCount = 0} -> SequenceDemo
+ [Back to menu] -> Start

// Cycle: Loops through options repeatedly
:: CycleDemo
{do visitCount = visitCount + 1}
Visit #$visitCount

Cycle alternatives {&| ... | ... } repeat endlessly:

The guard says: {&| "Halt!" | "Who goes there?" | "State your business!" | "Move along." }

The clock strikes {&| one | two | three | four | five | six | seven | eight | nine | ten | eleven | twelve }.

+ [Visit again] -> CycleDemo
+ [Reset counter] {do visitCount = 0} -> CycleDemo
+ [Back to menu] -> Start

// Shuffle: Random selection each time
:: ShuffleDemo
{do visitCount = visitCount + 1}
Visit #$visitCount

Shuffle alternatives {~| ... | ... } pick randomly:

The dice shows: {~| one | two | three | four | five | six }.

A random greeting: {~| Hello! | Hi there! | Greetings! | Welcome! | Hey! }

The merchant offers: {~| a sword | a shield | a potion | a scroll | a gem }.

+ [Visit again] -> ShuffleDemo
+ [Reset counter] {do visitCount = 0} -> ShuffleDemo
+ [Back to menu] -> Start

// Once-only: Shows once, then shows nothing
:: OnceOnlyDemo
{do visitCount = visitCount + 1}
Visit #$visitCount

Once-only alternatives {* ... } appear only on first visit:

{* Welcome, new visitor! This message appears only once. }

You enter the room.

{* You notice a key on the table and pick it up. }

{* There's a note on the wall that reads: "Beware the dragon!" }

The room is {| unfamiliar | somewhat familiar | very familiar }.

+ [Visit again] -> OnceOnlyDemo
+ [Back to menu] -> Start

// Combining multiple alternative types
:: CombinedDemo
{do visitCount = visitCount + 1}
Visit #$visitCount

Multiple alternatives in one passage:

{* (First visit only: You've discovered the secret room!) }

The {~| ancient | mysterious | enchanted } door leads to a {&| dark | dim | shadowy } chamber.

Inside you find {| nothing yet | a small chest | an ornate box | the legendary treasure }.

A voice whispers: {~| "Choose wisely..." | "Time is short..." | "Danger awaits..." }

+ [Enter again] -> CombinedDemo
+ [Reset] {do visitCount = 0} -> CombinedDemo
+ [Back to menu] -> Start

// Practical storytelling example
:: PracticalDemo
{do visitCount = visitCount + 1}

{* You push open the creaky tavern door for the first time. The smell of ale and smoke fills your nostrils. }

The Rusty Tankard Tavern

{| The tavern is nearly empty at this early hour.
 | A few patrons have gathered, nursing their drinks.
 | The tavern is getting busy as evening approaches.
 | The tavern is packed with rowdy adventurers. }

The bartender {&| polishes a glass | wipes down the counter | serves a customer | restocks the shelves }.

{~| A bard strums a melancholy tune. | Dice clatter on a nearby table. | Someone laughs loudly in the corner. | The fire crackles warmly. }

{* "First time here?" the bartender asks. "Name's Grum. Let me know if you need anything." }

+ [Order a drink] -> OrderDrink
+ [Talk to a patron] -> TalkPatron
+ [Leave the tavern] -> Start
+ [Visit again (to see alternatives change)] -> PracticalDemo

:: OrderDrink
The bartender pours you a drink.

"{~| Here you go! | Enjoy! | On the house... just kidding. | Drink up! }"

+ [Return to the tavern] -> PracticalDemo

:: TalkPatron
You approach a {~| grizzled warrior | hooded stranger | cheerful merchant | tired traveler }.

They {~| nod at you | ignore you | offer a toast | tell you a story }.

+ [Return to the tavern] -> PracticalDemo
