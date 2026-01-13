// WLS The Enchanted Library
// Converted from v2-story-features.whisker (JSON Format 2.0)
// Demonstrates story-level tags, settings, and variable usage tracking

@title: The Enchanted Library
@author: Whisker Examples
@version: 1.0.0
@ifid: EXAMPLE-STORY-FEATURES-001
@start: Entrance

@vars
  playerName: "Adventurer"
  booksFound: 0
  totalBooks: 5
  hasLibraryCard: false
  hasMagnifyingGlass: false
  hasLantern: false
  currentRoom: "entrance"
  hintsUsed: 0
  score: 0

:: Entrance
@tags: start, introduction
@onEnter: currentRoom = "entrance"

Welcome, $playerName, to the Enchanted Library!

You stand before a grand oak door with mysterious glowing runes. A small plaque reads: "Those who seek knowledge shall find it, but only the curious shall understand it."

Books Found: $booksFound / $totalBooks
Score: $score points

+ [Enter the library] -> MainHall
+ [Examine the runes] {do score = score + 5} -> ExamineRunes

:: ExamineRunes
@tags: optional, lore
@onEnter: score = score + 5

You study the glowing runes carefully. They seem to shimmer and shift as you look at them, forming patterns that tell an ancient story.

[Achievement: Curious Mind] +5 points

+ [Enter the library] -> MainHall

:: MainHall
@tags: hub, exploration
@onEnter: currentRoom = "main_hall"

The main hall is vast and filled with towering bookshelves that reach up into shadows. Dust motes dance in rays of magical light filtering from enchanted crystals above.

You notice several areas to explore:
- The Reading Room (north)
- The Archive Section (east)
- The Rare Books Collection (west)
- The Librarian's Desk (center)

+ [Visit the Reading Room] -> ReadingRoom
+ {$hasLantern} [Explore the Archive Section] -> Archive
+ {$hasLibraryCard} [Check the Rare Books Collection] -> RareBooks
+ [Approach the Librarian's Desk] -> LibrarianDesk

:: LibrarianDesk
@tags: npc, important

An ancient librarian sits behind a massive desk covered in open books, scrolls, and a curious glowing orb.

"Ah, a visitor," the librarian says without looking up. "Here for a library card, I presume?"

+ {not $hasLibraryCard} [Request a library card] {do hasLibraryCard = true; score = score + 10} -> GetCard
+ [Ask about the library] {do hintsUsed = hintsUsed + 1} -> LibraryInfo
+ [Return to main hall] -> MainHall

:: GetCard
@tags: item-obtained, achievement
@onEnter: hasLibraryCard = true; score = score + 10

The librarian hands you an ornate card that glows faintly with magical energy.

"This will grant you access to our Rare Books Collection," the librarian explains. "Use it wisely."

[Item Obtained: Library Card]
[Achievement: Registered Reader] +10 points

+ [Thank the librarian and continue] -> MainHall

:: LibraryInfo
@tags: hint, tutorial
@onEnter: hintsUsed = hintsUsed + 1

The librarian smiles knowingly.

"This library contains five legendary books scattered throughout its halls. Each book holds ancient knowledge and power. Find all five, and you shall be granted the title of Master Scholar."

The librarian adds: "Look for:
- The Book of Mysteries (hidden)
- The Tome of Elements (in the archive)
- The Chronicle of Heroes (rare collection)
- The Codex of Wisdom (reading room)
- The Atlas of Worlds (must search carefully)"

Hints Used: $hintsUsed

+ [Continue exploring] -> MainHall

:: ReadingRoom
@tags: book-location, safe
@onEnter: currentRoom = "reading_room"

Cozy armchairs and warm lighting make this room inviting. Several books lie open on tables, as if readers just stepped away.

You notice "The Codex of Wisdom" sitting prominently on a reading stand.

+ {$booksFound < $totalBooks} [Take the Codex of Wisdom] {do booksFound = booksFound + 1; score = score + 20} -> FoundCodex
+ [Return to main hall] -> MainHall

:: FoundCodex
@tags: book-collected, achievement
@onEnter: booksFound = booksFound + 1; score = score + 20

You carefully pick up the Codex of Wisdom. Its pages glow softly as you touch them, and you feel a surge of understanding wash over you.

[Book Found: The Codex of Wisdom] +20 points

Books Collected: $booksFound / $totalBooks
Score: $score points

+ {$booksFound < $totalBooks} [Continue searching for books] -> MainHall
+ [Check your progress] -> CheckProgress

:: Archive
@tags: book-location, requires-item
@onEnter: currentRoom = "archive"

The archive is dimly lit and filled with ancient scrolls and dusty tomes. Your lantern illuminates forgotten corners filled with knowledge.

Among the shelves, you spot "The Tome of Elements" glowing with elemental energy.

+ {$booksFound < $totalBooks and $hasLantern} [Take the Tome of Elements] {do booksFound = booksFound + 1; score = score + 20} -> FoundTome
+ [Return to main hall] -> MainHall

:: FoundTome
@tags: book-collected, achievement

The Tome of Elements pulses with primal energy as you lift it from the shelf. Fire, Water, Earth, and Air swirl within its pages.

[Book Found: The Tome of Elements] +20 points

Books Collected: $booksFound / $totalBooks
Score: $score points

+ {$booksFound < $totalBooks} [Continue your quest] -> MainHall
+ [Check completion status] -> CheckProgress

:: RareBooks
@tags: book-location, requires-card
@onEnter: currentRoom = "rare_books"

The Rare Books Collection is protected by magical barriers that shimmer around ancient texts. Your library card allows you safe passage.

"The Chronicle of Heroes" sits in a place of honor, its cover emblazoned with legendary tales.

+ {$booksFound < $totalBooks and $hasLibraryCard} [Take the Chronicle of Heroes] {do booksFound = booksFound + 1; score = score + 20} -> FoundChronicle
+ [Return to main hall] -> MainHall

:: FoundChronicle
@tags: book-collected, achievement

As you take the Chronicle of Heroes, images of legendary warriors and mages flash through your mind. Their stories become part of you.

[Book Found: The Chronicle of Heroes] +20 points

Books Collected: $booksFound / $totalBooks
Score: $score points

+ {$booksFound < $totalBooks} [Press onward] -> MainHall
+ [Review your progress] -> CheckProgress

:: CheckProgress
@tags: status, meta

You take a moment to reflect on your journey through the Enchanted Library.

=== Progress Report ===
Player: $playerName
Current Location: $currentRoom
Books Found: $booksFound / $totalBooks
Score: $score points
Hints Used: $hintsUsed

Inventory:
- Library Card: {$hasLibraryCard}Yes{else}No{/}
- Magnifying Glass: {$hasMagnifyingGlass}Yes{else}No{/}
- Lantern: {$hasLantern}Yes{else}No{/}
===================

+ {$booksFound < $totalBooks} [Continue exploring] -> MainHall
+ {$booksFound >= $totalBooks} [Complete your quest] -> Ending

:: Ending
@tags: ending, success, achievement
@onEnter: score = score + 50

Congratulations, $playerName!

You have found all 5 legendary books and proven yourself worthy of the title "Master Scholar".

Final Statistics:
- Books Collected: $booksFound / $totalBooks
- Final Score: $score points
- Hints Used: $hintsUsed
- Completion Rate: 100%

The Elder Librarian appears before you, smiling warmly.

"You have done well, Master Scholar. The knowledge you've gathered will serve you well. May your wisdom grow with each passing day."

[QUEST COMPLETE]
[Achievement: Master Scholar] +50 points

+ [Play again] -> RESTART
