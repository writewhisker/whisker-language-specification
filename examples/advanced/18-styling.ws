@title: CSS Styling Demo
@author: WLS
@version: 1.0.0

-- WLS Gap 5: CSS Classes Demo
-- This story demonstrates CSS class styling

:: Start

# Styling with CSS Classes

.info {
This passage demonstrates the CSS class system in WLS.
Classes allow you to style content without inline CSS.
}

.warning {
Be careful! This bridge looks unstable.
}

.success {
Congratulations! You've learned about styling.
}

+ [See more examples] -> MoreExamples
+ [End] -> END

:: MoreExamples

## Block and Inline Classes

Here's a block with multiple classes:

.dialog.merchant {
"Welcome to my humble shop! I have many wares for adventurers like yourself."
}

You can also use inline classes: [.highlight important text here] appears highlighted.

The damage dealt is [.damage 25 points] and remaining health is [.health 75/100].

### Choice Styling

+ [.safe Take the safe path] -> SafeChoice
+ [.dangerous Cross the dangerous bridge] -> DangerChoice
+ [.locked Enter the locked door] {false} -> Locked

:: SafeChoice

.success {
You made the wise choice. The safe path was uneventful but reliable.
}

+ [Return] -> Start

:: DangerChoice

.error {
The bridge collapses! You barely manage to grab onto a ledge.
}

+ [Return] -> Start
