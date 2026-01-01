# Gap 4: Modularity

## Context

Add code organization features: file includes, reusable functions, and namespace scoping for passages.

## Repositories

- **whisker-core**: `/Users/jims/code/github.com/writewhisker/whisker-core`
- **whisker-editor-web**: `/Users/jims/code/github.com/writewhisker/whisker-editor-web`
- **specification**: `/Users/jims/code/github.com/whisker-language-specification-1.0`

## Syntax to Implement

### Include Directive
```whisker
INCLUDE "common/dialogs.ws"
INCLUDE "characters/merchant.ws"
```

### Functions
```whisker
FUNCTION greet(name)
  RETURN "Hello, " + name + "!"
END

:: Start
${greet("Hero")}
```

### Namespaces
```whisker
NAMESPACE Merchant

:: StartTrade  // Full name: Merchant::StartTrade
Welcome to my shop!
+ [Exit] -> ::Start  // :: prefix = root namespace

END NAMESPACE
```

## Key Files to Modify

### Lua (whisker-core)
- `lib/whisker/parser/ws_lexer.lua` - INCLUDE, FUNCTION, NAMESPACE, RETURN, END tokens
- `lib/whisker/parser/ws_parser.lua` - Parse new constructs
- `lib/whisker/core/loader.lua` - (NEW) File loading and merging
- `lib/whisker/core/engine.lua` - Function call stack
- `lib/whisker/validators/modules.lua` - (NEW) Module validators

### TypeScript (whisker-editor-web)
- `packages/parser/src/lexer.ts` - Tokens
- `packages/parser/src/parser.ts` - Parsing
- `packages/import/src/formats/WLSImporter.ts` - Multi-file loading
- `packages/story-player/src/StoryPlayer.ts` - Function execution
- `packages/story-validation/src/validators/ModuleValidator.ts` - (NEW)
- `packages/story-validation/src/validators/FunctionValidator.ts` - (NEW)

## Commands

```bash
# Run Lua tests
cd /Users/jims/code/github.com/writewhisker/whisker-core
busted tests/wls/test_modules.lua

# Run TypeScript tests
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/parser test -- --run
pnpm --filter @writewhisker/import test -- --run
```

## New Error Codes

- `WLS-MOD-001`: include_not_found
- `WLS-MOD-002`: circular_include
- `WLS-MOD-003`: undefined_function
- `WLS-MOD-004`: namespace_conflict

## Implementation Notes

- Detect and prevent circular includes
- Function call stack needs depth limit (prevent infinite recursion)
- Namespace resolution: local first, then parent, then root
- Update link validators for namespace-qualified names

## Success Criteria

- Multi-file stories load correctly
- Functions call and return properly
- Namespaces scope passage names
- Circular dependencies detected
- Cross-namespace navigation works
