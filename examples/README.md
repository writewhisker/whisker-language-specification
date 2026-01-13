# WLS Examples

This directory contains canonical example files demonstrating the Whisker Language Specification 1.0 text format. These examples serve as the authoritative reference for both whisker-core (Lua) and whisker-editor-web (TypeScript) implementations.

## Directory Structure

```
examples/
├── beginner/        # Start here - simple stories for newcomers
├── intermediate/    # Core features - conditionals, choices, alternatives
└── advanced/        # Complex games and API demonstrations
```

## Beginner Examples

| File | Description |
|------|-------------|
| `beginner/01-first-story.ws` | A minimal story with basic navigation |
| `beginner/02-variables-demo.ws` | Variable declaration, types, and interpolation |

## Intermediate Examples

| File | Description |
|------|-------------|
| `intermediate/03-conditionals-demo.ws` | Conditional blocks, elif chains, nested conditions |
| `intermediate/04-choices-demo.ws` | All choice syntax: conditional, once-only, with actions |
| `intermediate/05-alternatives-demo.ws` | Text alternatives: sequence, cycle, shuffle, once-only |

## Advanced Examples

| File | Description |
|------|-------------|
| `advanced/06-complete-game.ws` | Full interactive game combining all features |
| `advanced/07-lua-api-demo.ws` | The whisker.* Lua API: state, passages, random, visits |
| `advanced/08-typed-variables.ws` | Typed variable declarations and usage patterns |
| `advanced/09-metadata-usage.ws` | Passage and choice metadata with tags and notes |
| `advanced/10-enchanted-library.ws` | Story-level features, achievements, and scoring |
| `advanced/11-assets-gallery.ws` | Asset management with images, audio, and video |
| `advanced/12-cave-adventure.ws` | Shop pattern, inventory, and combat mechanics |
| `advanced/13-lists.ws` | List data structure usage |
| `advanced/14-arrays.ws` | Array operations and patterns |
| `advanced/15-maps.ws` | Map/dictionary data structures |
| `advanced/16-modules.ws` | Module system usage |
| `advanced/17-rich-text.ws` | Rich text formatting |
| `advanced/18-styling.ws` | CSS styling integration |
| `advanced/19-media.ws` | Media embedding |
| `advanced/20-theming.ws` | Theme customization |

## Quick Reference

### Passage Declaration
```
:: PassageName
Content goes here.
```

### Variables
```
@vars
  gold: 100
  name: "Hero"
  isReady: false

:: Start
$name has $gold gold.
${gold * 2} is double.
```

### Choices
```
+ [Basic choice] -> Target
+ {$gold >= 50} [Conditional] -> Target
+ [With action] {do gold = gold - 10} -> Target
+ {$gold >= 50} [Both] {do gold = gold - 50} -> Target
* [Once-only choice] -> Target
```

### Conditionals
```
{$score >= 90}
  Grade: A
{elif $score >= 80}
  Grade: B
{else}
  Grade: C
{/}
```

### Alternatives
```
{| First | Second | Third }           // Sequence
{&| One | Two | Three }               // Cycle
{~| Random | Options | Here }         // Shuffle
{* Shown only once }                  // Once-only
```

### Special Targets
```
+ [End story] -> END
+ [Go back] -> BACK
+ [Start over] -> RESTART
```

### Lua API
```
{{ whisker.state.get("gold") }}
{{ whisker.state.set("gold", 100) }}
{{ whisker.passage.current().title }}
{{ whisker.random() }}
{{ whisker.visited("PassageName") }}
```

## Running Examples

These examples can be run with any WLS compatible player:

1. **whisker-core** (Lua): Parse and play stories in Lua environments
2. **whisker-editor-web**: Edit and preview stories in the browser

## File Format

WLS text files use the `.ws` extension and are UTF-8 encoded plain text.

## Conformance Testing

Implementation repositories should reference these examples via git submodule to ensure conformance with the specification.
