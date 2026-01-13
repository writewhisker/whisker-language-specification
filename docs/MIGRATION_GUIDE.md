# WLS Migration Guide

**Version:** 1.0
**Date:** 2025-12-30
**Target Audience:** Story authors migrating from legacy Whisker syntax

## Overview

### What's Changing

WLS introduces a cleaner, more consistent syntax inspired by Lua. Key changes:

1. **Variable syntax** - `$name` instead of `{{name}}`
2. **Expression interpolation** - `${expr}` instead of `{{expr}}`
3. **Choice syntax** - `+ [text] -> Target` instead of `[[text|Target]]`
4. **Logical operators** - `and`, `or`, `not` instead of `&&`, `||`, `!`
5. **Comparison operators** - `~=` instead of `!=`

### Why Migrate

- Cleaner, more readable stories
- Better error messages
- Improved performance
- Cross-platform compatibility
- Active support and updates

### Migration Timeline

| Phase | Action | Recommended |
|-------|--------|-------------|
| 1 | Backup your stories | Now |
| 2 | Run migration tool | This week |
| 3 | Review and test | 1-2 weeks |
| 4 | Deploy updated stories | After testing |

---

## Syntax Changes

### Variables

| Legacy | WLS | Notes |
|--------|---------|-------|
| `{{name}}` | `$name` | Variable reference |
| `{{name = 10}}` | `$name = 10` | Variable assignment |
| `{{name + 1}}` | `${$name + 1}` | Expression with variable |
| `{{_temp}}` | `_temp` | Temporary variable |

**Examples:**

```
# Legacy:
You have {{gold}} gold.
{{gold = gold + 10}}

# WLS:
You have $gold gold.
$gold = $gold + 10
```

### Choices

| Legacy | WLS | Type |
|--------|---------|------|
| `[[Go left\|LeftRoom]]` | `+ [Go left] -> LeftRoom` | Once-only |
| `[[Go left->LeftRoom]]` | `+ [Go left] -> LeftRoom` | Once-only |
| (no equivalent) | `* [Go left] -> LeftRoom` | Sticky |

**Examples:**

```
# Legacy:
[[Enter the cave|Cave]]
[[Talk to the guard->Guard]]

# WLS:
+ [Enter the cave] -> Cave
+ [Talk to the guard] -> Guard

# Sticky choice (always available):
* [Look around] -> LookAround
```

### Conditionals

| Legacy | WLS | Notes |
|--------|---------|-------|
| `{{if gold > 50}}` | `{$gold > 50}` | Block conditional |
| `{{endif}}` | `{/}` | End conditional |
| `{{else}}` | `{else}` | Else clause |
| `{{elseif x}}` | `{elif $x}` | Else-if |
| `{{gold > 50 ? "rich" : "poor"}}` | `{$gold > 50 ? rich \| poor}` | Inline |

**Examples:**

```
# Legacy:
{{if gold >= 100}}
You are wealthy!
{{elseif gold >= 50}}
You have some savings.
{{else}}
You are poor.
{{endif}}

# WLS:
{$gold >= 100}
You are wealthy!
{elif $gold >= 50}
You have some savings.
{else}
You are poor.
{/}
```

### Operators

| Legacy | WLS | Operation |
|--------|---------|-----------|
| `&&` | `and` | Logical AND |
| `\|\|` | `or` | Logical OR |
| `!` | `not` | Logical NOT |
| `!=` | `~=` | Not equal |
| `==` | `==` | Equal (unchanged) |
| `+`, `-`, `*`, `/` | Same | Arithmetic (unchanged) |

**Examples:**

```
# Legacy:
{{if gold > 50 && hasKey}}
{{if !visited}}
{{if x != 0}}

# WLS:
{$gold > 50 and $hasKey}
{not $visited}
{$x ~= 0}
```

### Text Alternatives

| Legacy | WLS | Behavior |
|--------|---------|----------|
| `{sequence: a \| b \| c}` | `{\| a \| b \| c }` | Sequence |
| `{cycle: a \| b \| c}` | `{&\| a \| b \| c }` | Cycle |
| `{shuffle: a \| b \| c}` | `{~\| a \| b \| c }` | Shuffle |
| (no equivalent) | `{!\| a \| b \| c }` | Once-only |

**Examples:**

```
# Legacy:
The weather is {cycle: sunny|cloudy|rainy}.

# WLS:
The weather is {&| sunny | cloudy | rainy }.

# Once-only alternative (new in WLS):
{!| First visit text | Second visit | Third visit }
```

### Metadata

| Legacy | WLS | Notes |
|--------|---------|-------|
| `::title: My Story` | `@title: My Story` | Story title |
| `::author: Name` | `@author: Name` | Author |
| `[tags: a, b]` | `@tags: a, b` | Passage tags |

---

## Step-by-Step Migration

### Step 1: Backup Your Stories

```bash
# Create a backup directory
mkdir backup-$(date +%Y%m%d)
cp -r stories/* backup-$(date +%Y%m%d)/
```

### Step 2: Run the Migration Tool

**Using whisker-editor-web:**

1. Open your story in the editor
2. Go to File > Export > WLS Format
3. Save the migrated story

**Using command line (when available):**

```bash
# When whisker-core migration tool is ready:
whisker migrate --input story.whisker --output story-wls1.whisker
```

### Step 3: Review Changes

Check the following in your migrated story:

1. **Variables** - All `{{var}}` converted to `$var`
2. **Choices** - Links converted to `+ [text] -> Target`
3. **Conditionals** - Block syntax converted
4. **Operators** - Logical operators converted

### Step 4: Test Your Story

1. Load the story in the player
2. Test all paths through the story
3. Verify variable values are correct
4. Check all choices work

### Step 5: Deploy

Once testing is complete:

1. Replace old story files with new versions
2. Update any story references
3. Test in production environment

---

## Troubleshooting

### Common Issues

#### "Expected variable name after $"

**Cause:** Variable reference without a name

**Legacy:**
```
{{}}
```

**Fix:**
```
$variableName
```

#### "Use ~= instead of !="

**Cause:** Using C-style not-equal operator

**Legacy:**
```
{{if x != 0}}
```

**Fix:**
```
{$x ~= 0}
```

#### "Use 'not' instead of !"

**Cause:** Using C-style NOT operator

**Legacy:**
```
{{if !visited}}
```

**Fix:**
```
{not $visited}
```

#### "Use 'and' instead of &&"

**Cause:** Using C-style AND operator

**Legacy:**
```
{{if x && y}}
```

**Fix:**
```
{$x and $y}
```

#### "Expected passage marker (::)"

**Cause:** Content before first passage

**Fix:** Ensure story starts with passage marker:
```
:: Start
Your content here.
```

### Getting Help

1. **Documentation:** See USER_GUIDE.md
2. **Examples:** See examples/
3. **Issues:** https://github.com/writewhisker/whisker-editor-web/issues

---

## Quick Reference Card

### Syntax Comparison

| Feature | Legacy | WLS |
|---------|--------|---------|
| Variable | `{{name}}` | `$name` |
| Expression | `{{expr}}` | `${expr}` |
| Assignment | `{{x = 1}}` | `$x = 1` |
| Choice (once) | `[[text\|Target]]` | `+ [text] -> Target` |
| Choice (sticky) | - | `* [text] -> Target` |
| If | `{{if cond}}` | `{cond}` |
| Else | `{{else}}` | `{else}` |
| End if | `{{endif}}` | `{/}` |
| And | `&&` | `and` |
| Or | `\|\|` | `or` |
| Not | `!` | `not` |
| Not equal | `!=` | `~=` |
| Sequence | `{sequence: a\|b}` | `{\| a \| b }` |
| Cycle | `{cycle: a\|b}` | `{&\| a \| b }` |
| Shuffle | `{shuffle: a\|b}` | `{~\| a \| b }` |
| Once-only | - | `{!\| a \| b }` |
| Metadata | `::title: X` | `@title: X` |

---

## Appendix: Complete Example

### Legacy Format

```
::title: The Cave
::author: Adventure Writer

:: Start
{{gold = 100}}
{{visited = false}}

You stand at the entrance of a dark cave.
You have {{gold}} gold coins.

{{if !visited}}
This is your first time here.
{{endif}}

[[Enter the cave|Cave]]
[[Go back home->Home]]
```

### WLS Format

```
@title: The Cave
@author: Adventure Writer

:: Start
$gold = 100
$visited = false

You stand at the entrance of a dark cave.
You have $gold gold coins.

{not $visited}
This is your first time here.
{/}

+ [Enter the cave] -> Cave
+ [Go back home] -> Home
```
