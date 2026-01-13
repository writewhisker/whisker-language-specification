// WLS Metadata Example
// Converted from v2-with-metadata.whisker (JSON Format 2.0)
// Demonstrates passage and choice metadata usage

@title: Metadata Example
@author: Whisker Team
@version: 1.0.0
@ifid: 23456789-2345-4345-8345-234567890abc

@vars
  score: 0

:: Start
@tags: start, hub
@notes: Main hub passage with difficulty selection

Welcome to the Metadata Example. This demonstrates how metadata can be used to store additional information.

+ [Easy path] -> EasyPath
+ [Hard path] -> HardPath
+ {$score >= 100} [Secret path] -> SecretPath

:: EasyPath
@tags: path
@notes: Easy difficulty route, peaceful theme

You chose the easy path. The road is clear and well-marked.

+ [Continue forward] {do score = score + 10} -> EasyReward

:: HardPath
@tags: path
@notes: Hard difficulty route, danger theme

You chose the hard path. Dangers lurk around every corner.

+ [Fight the monster] {do score = score + 50} -> HardReward
+ [Retreat] -> Start

:: SecretPath
@tags: path, secret
@notes: Hidden path, only accessible with high score

You discovered the secret path! Only masters find this.

+ [Claim the treasure] {do score = score + 1000} -> SecretReward

:: EasyReward
@tags: ending
@notes: C-rank ending

You completed the easy path. Well done! (+10 points)

Your score: $score

+ [Try again] -> Start

:: HardReward
@tags: ending
@notes: B-rank ending

You conquered the hard path! Impressive! (+50 points)

Your score: $score

+ [Try again] -> Start

:: SecretReward
@tags: ending
@notes: S-rank ending, legendary achievement

You found the legendary treasure! You are a true master! (+1000 points)

Your score: $score

+ [Restart] -> Start
