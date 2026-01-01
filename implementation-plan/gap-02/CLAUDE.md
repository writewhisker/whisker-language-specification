# Gap 2: Advanced Flow Control

## Context

Implement gather points and tunnels - two Ink-inspired flow control features that reduce passage explosion and enable reusable content.

## Repositories

- **whisker-core**: `/Users/jims/code/github.com/writewhisker/whisker-core`
- **whisker-editor-web**: `/Users/jims/code/github.com/writewhisker/whisker-editor-web`
- **specification**: `/Users/jims/code/github.com/whisker-language-specification-1.0`

## Syntax to Implement

### Gather Points
```whisker
:: Conversation
"What do you think?"
+ [Agree] She smiled.
+ [Disagree] She frowned.
- "Either way, we should continue."  // Gather point - all branches reconverge here
```

### Tunnels
```whisker
:: Morning
You wake up.
-> BrushTeeth ->    // Tunnel call - go to BrushTeeth, then return here
Ready for the day!

:: BrushTeeth
You brush your teeth.
<-  // Return to caller
```

## Key Files to Modify

### Lua (whisker-core)
- `lib/whisker/parser/ws_lexer.lua` - Add GATHER, TUNNEL_CALL, TUNNEL_RETURN tokens
- `lib/whisker/parser/ws_parser.lua` - Parse gather/tunnel syntax
- `lib/whisker/core/engine.lua` - Execute tunnels with call stack
- `lib/whisker/core/control_flow.lua` - Gather point execution
- `lib/whisker/validators/flow.lua` - New validation rules

### TypeScript (whisker-editor-web)
- `packages/parser/src/lexer.ts` - Add tokens
- `packages/parser/src/parser.ts` - Parse syntax
- `packages/parser/src/ast.ts` - New AST node types
- `packages/story-player/src/StoryPlayer.ts` - Runtime execution
- `packages/story-validation/src/validators/` - New validators

## Commands

```bash
# Run Lua tests
cd /Users/jims/code/github.com/writewhisker/whisker-core
busted tests/wls/test_flow.lua

# Run TypeScript tests
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/parser test -- --run
pnpm --filter @writewhisker/story-player test -- --run
```

## New Error Codes

- `WLS-FLW-007`: invalid_gather_placement
- `WLS-FLW-008`: unreachable_gather
- `WLS-FLW-009`: tunnel_target_not_found
- `WLS-FLW-010`: missing_tunnel_return
- `WLS-FLW-011`: orphan_tunnel_return

## Implementation Order

1. Update specification first (spec/05-CONTROL_FLOW.md)
2. Add lexer tokens in both platforms
3. Implement parser changes
4. Implement runtime execution
5. Add validators
6. Create test corpus cases

## Success Criteria

- Gather points reconverge flow correctly
- Tunnels maintain proper call stack
- Save/load preserves tunnel state
- All new validators catch errors
- Parity between Lua and TypeScript
