# Gap 3: Data Structures

## Context

Add collection types (LIST, ARRAY, MAP) to WLS. Currently only scalar variables (numbers, strings, booleans) are supported.

## Repositories

- **whisker-core**: `/Users/jims/code/github.com/writewhisker/whisker-core`
- **whisker-editor-web**: `/Users/jims/code/github.com/writewhisker/whisker-editor-web`
- **specification**: `/Users/jims/code/github.com/whisker-language-specification-1.0`

## Syntax to Implement

### Lists (Ink-style enumerated sets)
```whisker
LIST moods = happy, sad, angry, neutral
LIST inventory = (sword), (shield), potion  // parentheses = initially active

{+sword}            // Add to list
{-sword}            // Remove from list
{inventory ? sword}  // Check if contains
```

### Arrays
```whisker
ARRAY items = ["sword", "shield", "potion"]

${items[0]}         // Access by index (0-based)
${#items}           // Length
{items += "bow"}    // Append
```

### Maps
```whisker
MAP player = { name: "Hero", health: 100 }

${player.name}       // Dot access
${player["health"]}  // Bracket access
{player.level = 1}   // Add property
```

## Key Files to Modify

### Lua (whisker-core)
- `lib/whisker/parser/ws_lexer.lua` - LIST, ARRAY, MAP tokens
- `lib/whisker/parser/ws_parser.lua` - Parse declarations and access
- `lib/whisker/core/variables.lua` - Collection runtime types
- `lib/whisker/validators/types.lua` - Type validators

### TypeScript (whisker-editor-web)
- `packages/parser/src/lexer.ts` - Tokens
- `packages/parser/src/parser.ts` - Parsing
- `packages/scripting/src/expressions.ts` - Expression evaluation
- `packages/story-player/src/StoryPlayer.ts` - Runtime
- `packages/story-models/src/Variable.ts` - Type definitions

## Commands

```bash
# Run Lua tests
cd /Users/jims/code/github.com/writewhisker/whisker-core
busted tests/wls/test_variables.lua

# Run TypeScript tests
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/parser test -- --run
pnpm --filter @writewhisker/scripting test -- --run
pnpm --filter @writewhisker/story-player test -- --run
```

## New Error Codes

- `WLS-TYP-006`: invalid_list_operation
- `WLS-TYP-007`: array_index_invalid
- `WLS-TYP-008`: map_key_invalid

## Implementation Notes

- Lua uses 1-based indexing internally, but WLS arrays are 0-based
- Maps must handle prototype pollution protection in TypeScript
- Collections must serialize correctly for save/load
- Consider deep clone vs reference semantics

## Success Criteria

- All collection types work in both runtimes
- Index/key access works correctly
- Operations (+, -, ?, etc.) work
- Serialization preserves collection state
- Type validators catch errors
