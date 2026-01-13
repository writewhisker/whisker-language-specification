// WLS Example: Lua API
// Demonstrates the whisker.* Lua API functions

@title: Lua API Demo
@author: Whisker Author

@vars
  score: 0
  playerName: "Hero"
  health: 100
  visitedPlaces: 0

:: Start
This example demonstrates the Whisker Lua API.

The API provides access to story state, passages, and utility functions.

+ [State API] -> StateAPI
+ [Passage API] -> PassageAPI
+ [Random API] -> RandomAPI
+ [Visit tracking] -> VisitAPI
+ [Math functions] -> MathAPI
+ [String functions] -> StringAPI

// whisker.state API
:: StateAPI
=== whisker.state API ===

Current score: {{ whisker.state.get("score") }}
Player name: {{ whisker.state.get("playerName") }}

Using whisker.state.get() to read values:
- score = {{ whisker.state.get("score") }}
- health = {{ whisker.state.get("health") }}

Check if variable exists:
- "score" exists: {{ whisker.state.has("score") and "yes" or "no" }}
- "unknown" exists: {{ whisker.state.has("unknown") and "yes" or "no" }}

+ [Increment score] {{ whisker.state.set("score", whisker.state.get("score") + 10) }} -> StateAPI
+ [Set custom value] {{ whisker.state.set("customVar", 42) }} -> ShowCustom
+ [Reset score] {{ whisker.state.set("score", 0) }} -> StateAPI
+ [Back] -> Start

:: ShowCustom
Custom variable set!

Value of customVar: {{ whisker.state.get("customVar") }}

+ [Delete customVar] {{ whisker.state.delete("customVar") }} -> StateAPI
+ [Back] -> StateAPI

// whisker.passage API
:: PassageAPI
=== whisker.passage API ===

Current passage info:

ID: {{ whisker.passage.current().id }}
Title: {{ whisker.passage.current().title }}

Checking if passages exist:
- "Start" exists: {{ whisker.passage.exists("Start") and "yes" or "no" }}
- "Nonexistent" exists: {{ whisker.passage.exists("Nonexistent") and "yes" or "no" }}

+ [Go to specific passage via API] {{ whisker.passage.go("PassageAPITarget") }} -> PassageAPITarget
+ [Back] -> Start

:: PassageAPITarget
You arrived here via whisker.passage.go()!

This bypasses normal navigation and jumps directly.

+ [Return to Passage API demo] -> PassageAPI

// whisker.random API
:: RandomAPI
=== whisker.random API ===

Random number (0-1): {{ string.format("%.2f", whisker.random()) }}

Random integer (1-6 dice roll): {{ math.floor(whisker.random() * 6) + 1 }}

Random integer (1-100): {{ math.floor(whisker.random() * 100) + 1 }}

Random choice simulation:
{{
  local r = whisker.random()
  if r < 0.33 then
    return "Option A"
  elseif r < 0.66 then
    return "Option B"
  else
    return "Option C"
  end
}}

+ [Roll again] -> RandomAPI
+ [Back] -> Start

// Visit tracking
:: VisitAPI
{do visitedPlaces = visitedPlaces + 1}

=== Visit Tracking ===

You have visited this passage $visitedPlaces times.

Visit count using whisker.visited():
- Times visited "VisitAPI": {{ whisker.visited("VisitAPI") }}
- Times visited "Start": {{ whisker.visited("Start") }}
- Times visited "Nonexistent": {{ whisker.visited("Nonexistent") }}

Has visited:
- "Start": {{ whisker.visited("Start") > 0 and "yes" or "no" }}
- "SecretRoom": {{ whisker.visited("SecretRoom") > 0 and "yes" or "no" }}

+ [Visit again] -> VisitAPI
+ [Visit SecretRoom] -> SecretRoom
+ [Back] -> Start

:: SecretRoom
You've found the secret room!

Times visited: {{ whisker.visited("SecretRoom") }}

+ [Return] -> VisitAPI

// Math functions
:: MathAPI
=== Lua Math Functions ===

You can use standard Lua math functions:

math.abs(-5) = {{ math.abs(-5) }}
math.floor(3.7) = {{ math.floor(3.7) }}
math.ceil(3.2) = {{ math.ceil(3.2) }}
math.max(10, 20) = {{ math.max(10, 20) }}
math.min(10, 20) = {{ math.min(10, 20) }}
math.sqrt(16) = {{ math.sqrt(16) }}
math.pow(2, 8) = {{ math.pow(2, 8) }}

Calculations with story variables:
- health / 2 = {{ whisker.state.get("health") / 2 }}
- score * 10 = {{ whisker.state.get("score") * 10 }}

+ [Back] -> Start

// String functions
:: StringAPI
=== Lua String Functions ===

Current player name: {{ whisker.state.get("playerName") }}

string.upper(): {{ string.upper(whisker.state.get("playerName")) }}
string.lower(): {{ string.lower(whisker.state.get("playerName")) }}
string.len(): {{ string.len(whisker.state.get("playerName")) }}
string.sub(1,2): {{ string.sub(whisker.state.get("playerName"), 1, 2) }}
string.reverse(): {{ string.reverse(whisker.state.get("playerName")) }}

Format numbers:
- score with 3 digits: {{ string.format("%03d", whisker.state.get("score")) }}
- health as percentage: {{ string.format("%.1f%%", whisker.state.get("health")) }}

+ [Back] -> Start
