# TypeScript Parser Audit (whisker-editor-web)

**Date:** 2026-01-01
**Parser File:** `packages/parser/src/parser.ts` (1,307 lines)
**Lexer File:** `packages/parser/src/lexer.ts` (662 lines)
**AST File:** `packages/parser/src/ast.ts` (357 lines)

## Executive Summary

The TypeScript parser is approximately **95% complete**. It has a complete AST structure, full expression parsing with operator precedence, and comprehensive error handling. Minor gaps exist in source map export and some edge cases.

## Implemented Features

### Lexer (lexer.ts)

| Token Type | Status | Description |
|------------|--------|-------------|
| PASSAGE_MARKER | ✅ | `::` passage headers |
| DIRECTIVE | ✅ | `@name:` directives |
| ONCE_CHOICE_MARKER | ✅ | `+` once-only choice |
| STICKY_CHOICE_MARKER | ✅ | `*` sticky choice |
| ARROW | ✅ | `->` navigation |
| DOLLAR | ✅ | `$` variable prefix |
| UNDERSCORE | ✅ | `_` temp variable prefix |
| EXPR_START | ✅ | `${` expression start |
| LBRACE/RBRACE | ✅ | Block delimiters |
| LBRACKET/RBRACKET | ✅ | Choice text delimiters |
| LPAREN/RPAREN | ✅ | Grouping |
| COND_END | ✅ | `{/}` block close |
| IF/ELSE/ELIF/DO | ✅ | Control keywords |
| PIPE/AMPERSAND/TILDE/EXCLAMATION | ✅ | Alternative modes |
| All operators | ✅ | Arithmetic, comparison, logical |
| STRING/NUMBER | ✅ | Literals |
| TRUE/FALSE/NIL | ✅ | Boolean/null literals |
| IDENTIFIER | ✅ | Names |
| COMMENT | ✅ | Line and block |
| NEWLINE/INDENT/DEDENT | ✅ | Structure |

### Parser (parser.ts)

| Feature | Status | Notes |
|---------|--------|-------|
| Story parsing | ✅ | Full structure |
| Metadata directives | ✅ | All @directives |
| Variable declarations | ✅ | @vars block |
| Passage parsing | ✅ | With tags and metadata |
| Passage tags | ✅ | `[tag1, tag2]` syntax |
| Passage metadata | ✅ | @fallback, @onEnter, @onExit |
| Choice parsing | ✅ | Once and sticky types |
| Choice conditions | ✅ | Full expression support |
| Choice actions | ✅ | Multiple expressions |
| Choice targets | ✅ | With special targets |
| Text content | ✅ | With whitespace handling |
| Variable interpolation | ✅ | $var, $_temp |
| Expression interpolation | ✅ | ${expr} |
| Block conditionals | ✅ | {cond}...{/} |
| Inline conditionals | ✅ | {cond: true \| false} |
| Elif branches | ✅ | Full support |
| Else branches | ✅ | Full support |
| Do blocks | ✅ | {do expr; expr2} |
| Text alternatives | ✅ | All 4 modes |
| Sequence | ✅ | `{\| a \| b}` |
| Cycle | ✅ | `{&\| a \| b}` |
| Shuffle | ✅ | `{~\| a \| b}` |
| Once | ✅ | `{!\| a \| b}` |

### Expression Parsing

| Feature | Status | Notes |
|---------|--------|-------|
| Operator precedence | ✅ | Full precedence table |
| Binary operators | ✅ | +, -, *, /, %, ^ |
| Comparison operators | ✅ | ==, ~=, <, >, <=, >= |
| Logical operators | ✅ | and, or, not |
| Unary operators | ✅ | -, #, not |
| String concatenation | ✅ | `..` operator |
| Assignment operators | ✅ | =, +=, -=, *=, /= |
| Function calls | ✅ | With arguments |
| Member access | ✅ | Dot notation |
| Grouped expressions | ✅ | Parentheses |
| Literals | ✅ | Numbers, strings, booleans, nil |
| Variables | ✅ | Story and temp scope |

### AST Structure

| Node Type | Status | Description |
|-----------|--------|-------------|
| StoryNode | ✅ | Root node |
| MetadataNode | ✅ | Directives |
| VariableDeclarationNode | ✅ | Variables |
| PassageNode | ✅ | Passages |
| PassageMetadataNode | ✅ | Passage directives |
| TextNode | ✅ | Plain text |
| InterpolationNode | ✅ | Variable/expression |
| ExpressionStatementNode | ✅ | Standalone expressions |
| DoBlockNode | ✅ | Action blocks |
| ConditionalNode | ✅ | Conditionals |
| ConditionalBranchNode | ✅ | Elif branches |
| ChoiceNode | ✅ | Choices |
| AlternativesNode | ✅ | Text alternatives |
| IdentifierNode | ✅ | Names |
| VariableNode | ✅ | Variables |
| LiteralNode | ✅ | Literals |
| BinaryExpressionNode | ✅ | Binary ops |
| UnaryExpressionNode | ✅ | Unary ops |
| CallExpressionNode | ✅ | Function calls |
| MemberExpressionNode | ✅ | Property access |
| AssignmentExpressionNode | ✅ | Assignments |

### Error Handling

| Feature | Status | Notes |
|---------|--------|-------|
| Error collection | ✅ | Multiple errors per parse |
| Location tracking | ✅ | Line, column, offset |
| Error suggestions | ✅ | Context-aware hints |
| Error recovery | ⚠️ | Partial - could be improved |
| Source context | ⚠️ | Not included in messages |

## Missing/Incomplete Features

### Important (Should Have)

1. **Enhanced Error Recovery**
   - Current: Recovers at some sync points
   - Needed: More robust synchronization
   - Impact: Multiple error reporting

2. **Source Map Export**
   - Current: Location in AST nodes
   - Needed: Standard v3 source map format
   - Impact: Debugging tools integration

3. **Error Context Display**
   - Current: Line/column only
   - Needed: Show code snippet with caret
   - Impact: User experience

### Nice to Have

4. **Incremental Parsing**
   - For large document edits
   - Would improve editor performance

5. **Comment Preservation**
   - Comments in AST for tooling
   - Would enable formatting tools

## Output Structure

Parser produces:

```typescript
interface ParseResult {
  ast: StoryNode | null;
  errors: ParseError[];
}

interface ParseError {
  message: string;
  location: SourceSpan;
  suggestion?: string;
}

interface SourceSpan {
  start: SourceLocation;
  end: SourceLocation;
}

interface SourceLocation {
  line: number;
  column: number;
  offset: number;
}
```

## Test Coverage

Located in `packages/parser/src/`:

- `lexer.test.ts` (573 lines) - Comprehensive lexer tests
- `parser.test.ts` (681 lines) - Parser unit tests
- `integration.test.ts` (349 lines) - Full workflow tests
- `corpus.test.ts` (335 lines) - WLS 1.0 corpus validation

**Coverage:** ~90% of parser functionality

## Recommendations

1. **Phase 1.3**: Improve error recovery with better sync points
2. **Phase 1.4**: Add source map v3 export capability
3. **Phase 1.3**: Add code snippet context to error messages
4. **Phase 1.5**: Ensure 100% corpus test pass rate

## Comparison with Lua

| Aspect | TypeScript | Lua |
|--------|------------|-----|
| AST Structure | Full nodes | Story data |
| Location tracking | All nodes | Errors only |
| Error recovery | Partial | Limited |
| Error messages | With suggestions | Basic |
| Expression parsing | Full precedence | Lexer-level |
| Test coverage | ~90% | ~80% |
| Lines of code | 2,326 | 1,205 |
