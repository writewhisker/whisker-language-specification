// WLS Example: First Story
// A minimal example to get started with Whisker

@title: My First Story
@author: Whisker Author

:: Start
Welcome to your first interactive story!

This is a simple passage with some choices below.

+ [Go to the forest] -> Forest
+ [Visit the village] -> Village

:: Forest
You enter a dense, mysterious forest.

The trees tower above you, their leaves rustling
in the gentle breeze.

+ [Explore deeper] -> DeepForest
+ [Return to start] -> Start

:: DeepForest
You venture deeper into the forest and discover
a hidden clearing with a sparkling stream.

A beautiful deer watches you from across the water.

+ [Approach the deer] -> END
+ [Go back] -> Forest

:: Village
You arrive at a quaint village with cobblestone streets.

Friendly villagers wave as you pass by.

+ [Visit the shop] -> Shop
+ [Go to the tavern] -> Tavern
+ [Return to start] -> Start

:: Shop
The shopkeeper greets you warmly.

"Welcome! Feel free to browse my wares."

+ [Thank them and leave] -> Village

:: Tavern
The tavern is warm and inviting.

A bard plays a cheerful tune in the corner.

+ [Listen to the music] -> END
+ [Return to the village] -> Village
