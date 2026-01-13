@title: Theming Demo
@author: WLS
@version: 1.0.0

-- WLS Gap 5: Theming Demo
-- This story demonstrates the theming system

THEME "dark"

STYLE {
  --bg-color: #1a1a2e;
  --text-color: #eee;
  --accent-color: #e94560;
  --link-color: #4ecdc4;
  --choice-bg: #16213e;
  --choice-hover: #0f3460;
  --font-family: "Crimson Text", Georgia, serif;
  --font-size: 18px;
  --line-height: 1.7;
  --passage-padding: 2rem;
}

@vars
  $visited_crypt = false
  $has_torch = false
@/vars

:: Start

# The Dark Tower

*You stand before the obsidian gates of the ancient tower.*

The stone is cold beneath your fingers, ancient runes pulsing with a faint crimson glow. The wind howls through the mountain pass, carrying whispers of those who came before.

.warning {
Many have entered. None have returned.
}

+ [Push open the gates] -> Entrance
+ [Examine the runes] -> Runes
+ [Turn back] -> END

:: Entrance

The gates groan open, revealing a spiral staircase descending into darkness.

{$has_torch}
Your torch casts dancing shadows on the walls, revealing:
- Ancient murals depicting a forgotten civilization
- Scratch marks from... something with claws
- A faded inscription you cannot read
{/}
{not $has_torch}
.error {
The darkness is absolute. You cannot see your hand in front of your face.
}
{/}

+ [Descend the stairs] -> Descent
+ [Search for a light source] {not $has_torch} -> FindTorch
+ [Return to entrance] -> Start

:: Runes

The runes speak of an ancient power sealed within.

> "By blood and shadow bound,
> The sleeper waits below.
> Three keys unlock the way,
> But wisdom bids: don't go."

+ [Continue] -> Start

:: FindTorch

You find an old torch in a wall sconce.

{do $has_torch = true}

.success {
The torch sputters to life, casting a warm glow.
}

+ [Continue] -> Entrance

:: Descent

*The stairs spiral endlessly downward...*

Your footsteps echo in the emptiness. The air grows colder with each step.

Finally, you reach the bottom: a vast chamber with three passages.

+ [Take the left passage] -> LeftPath
+ [Take the center passage] -> CenterPath
+ [Take the right passage] -> RightPath

:: LeftPath
:: CenterPath
:: RightPath

.info {
This demo ends here. In a full story, each path would lead to different adventures.
}

+ [Return to the beginning] -> Start
+ [End the story] -> END
