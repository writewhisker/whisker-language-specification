# Gap 1: Parser Completeness

## Context

This gap focuses on bringing the whisker-core Lua parser to 100% parity with the TypeScript parser. The TypeScript parser is the reference implementation.

## Repositories

- **whisker-core**: `/Users/jims/code/github.com/writewhisker/whisker-core`
- **whisker-editor-web**: `/Users/jims/code/github.com/writewhisker/whisker-editor-web`
- **specification**: `/Users/jims/code/github.com/whisker-language-specification-1.0`

## Key Files

### Lua (whisker-core)
- `lib/whisker/parser/ws_lexer.lua` - Lexer implementation
- `lib/whisker/parser/ws_parser.lua` - Parser implementation
- `lib/whisker/parser/ast.lua` - AST node definitions
- `tests/wls/` - Parser tests

### TypeScript (reference)
- `packages/parser/src/lexer.ts` - Reference lexer
- `packages/parser/src/parser.ts` - Reference parser
- `packages/parser/src/ast.ts` - Reference AST types

## Commands

```bash
# Run Lua parser tests
cd /Users/jims/code/github.com/writewhisker/whisker-core
busted tests/wls/

# Run TypeScript parser tests
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/parser test -- --run

# Run corpus tests
cd /Users/jims/code/github.com/whisker-language-specification-1.0
# See tools/ for corpus runners
```

## Implementation Notes

1. Start by auditing current Lua parser against TypeScript
2. Document all differences in AST structure
3. Implement missing features one at a time
4. Add error recovery after core features complete
5. Source maps are last priority

## Success Criteria

- All corpus tests pass in both implementations
- AST structures are equivalent
- Error messages match between platforms
- Source locations are accurate
