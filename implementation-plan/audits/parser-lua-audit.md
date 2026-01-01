# Lua Parser Audit (whisker-core)

**Date:** 2026-01-01
**Parser File:** `lib/whisker/parser/ws_parser.lua` (772 lines)
**Lexer File:** `lib/whisker/parser/ws_lexer.lua` (433 lines)

## Executive Summary

The Lua parser is approximately **85% complete**, not 70% as originally estimated. It successfully parses all core WLS 1.0 syntax elements. The main gaps are:

1. No formal AST structure (produces story data directly)
2. Limited error recovery (stops on first critical error)
3. No source map generation
4. Basic error messages without suggestions

## Implemented Features

### Lexer (ws_lexer.lua)

| Token Type | Status | Description |
|------------|--------|-------------|
| PASSAGE_MARKER | ✅ | `::` passage headers |
| DIRECTIVE | ✅ | `@name: value` directives |
| VARS_START | ✅ | `@vars` block start |
| CHOICE_ONCE | ✅ | `+` once-only choice |
| CHOICE_STICKY | ✅ | `*` sticky choice |
| ARROW | ✅ | `->` navigation |
| VAR_INTERP | ✅ | `$varName` interpolation |
| TEMP_VAR_INTERP | ✅ | `$_tempVar` interpolation |
| EXPR_INTERP | ✅ | `${expr}` interpolation |
| BLOCK_START | ✅ | `{` block start |
| BLOCK_END | ✅ | `}` block end |
| BLOCK_CLOSE | ✅ | `{/}` block close |
| ELSE | ✅ | `{else}` |
| ELIF | ✅ | `{elif condition}` |
| PIPE | ✅ | `|` alternative separator |
| TEXT | ✅ | Plain text content |
| STRING | ✅ | Quoted strings |
| NEWLINE | ✅ | Line breaks |
| INDENT | ✅ | Indentation |
| COMMENT | ✅ | `//` and `/* */` comments |

### Parser (ws_parser.lua)

| Feature | Status | Notes |
|---------|--------|-------|
| Header directives | ✅ | @title, @author, @version, @ifid, @start, @description |
| @vars block | ✅ | Indented variable declarations |
| Single @var: | ✅ | Inline variable declaration |
| Passage parsing | ✅ | With unique ID generation |
| Passage tags | ✅ | Via @tags directive |
| Passage metadata | ✅ | @color, @position, @notes |
| Passage scripts | ✅ | @onEnter, @onExit |
| Choice parsing | ✅ | Once-only (+) and sticky (*) |
| Choice conditions | ✅ | `{if condition}` before/after |
| Choice actions | ✅ | `{do action}` before/after |
| Choice targets | ✅ | `-> PassageName` |
| Special targets | ✅ | END, BACK, RESTART |
| Variable interpolation | ✅ | $var, $_temp |
| Expression interpolation | ✅ | ${expr} |
| Conditional blocks | ✅ | {cond}...{/} |
| Elif branches | ✅ | {elif cond} |
| Else branches | ✅ | {else} |
| Text alternatives | ✅ | Pipes in blocks |
| Duplicate detection | ✅ | Warns on duplicate passages |
| Reference validation | ✅ | Warns on missing targets |

## Missing Features

### Critical (Must Have)

1. **Formal AST Structure**
   - Current: Produces flat story data directly
   - Needed: Structured AST nodes matching TypeScript
   - Impact: Limits tooling integration

2. **Error Recovery**
   - Current: Collects errors but limited recovery
   - Needed: Continue parsing after errors
   - Impact: Only first error reported in many cases

3. **Source Maps**
   - Current: Basic line/column in errors
   - Needed: Full position tracking for all nodes
   - Impact: Poor debugging experience

### Important (Should Have)

4. **Error Suggestions**
   - Current: Basic error messages
   - Needed: Context-aware suggestions
   - Impact: User experience

5. **Inline Conditionals**
   - Current: Block conditionals only
   - Needed: `{cond: true | false}` syntax
   - Impact: Feature parity with TypeScript

6. **Alternative Modes**
   - Current: Only pipe-separated parsing
   - Needed: Explicit `{~|`, `{&|`, `{!|` modes
   - Impact: Full WLS 1.0 compliance

### Nice to Have

7. **AST Utilities**
   - Visitor pattern
   - Node creation helpers
   - Type checking functions

## Output Structure

Current parser produces:

```lua
{
  success = boolean,
  story = {
    metadata = { title, author, version, ... },
    variables = { [name] = { name, value, type } },
    passages = { [id] = { id, name, content, choices, tags, metadata } },
    start_passage = string,
    duplicate_passages = { [name] = count }
  },
  errors = { { message, line, column } },
  warnings = { { message, line, column } }
}
```

## Test Coverage

Located in `tests/wls/`:

- `test_ws_format.lua` - Comprehensive format tests
- `test_expressions.lua` - Interpolation tests
- `test_variables.lua` - Variable system tests
- `test_choices.lua` - Choice parsing tests
- `test_conditionals.lua` - Conditional tests

**Coverage:** ~80% of parser functionality

## Recommendations

1. **Phase 1.2**: Add inline conditional parsing, explicit alternative modes
2. **Phase 1.3**: Implement proper error recovery with synchronization
3. **Phase 1.4**: Add source position tracking to all output
4. **Phase 1.5**: Create formal AST layer (optional - story data works for runtime)

## Comparison with TypeScript

| Aspect | Lua | TypeScript |
|--------|-----|------------|
| AST Structure | Story data | Full AST nodes |
| Location tracking | Errors only | All nodes |
| Error recovery | Limited | Full synchronization |
| Error messages | Basic | With suggestions |
| Expression parsing | In lexer | Full precedence |
| Operator support | Runtime | Parse-time |
