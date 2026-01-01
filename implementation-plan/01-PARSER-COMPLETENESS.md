# Gap 1: Parser Completeness

## Problem Statement

The whisker-core Lua parser (`ws_parser.lua`) is only ~70% complete, missing:
- Full AST construction for text alternatives
- Proper error recovery
- Source mapping for debugging
- Comprehensive error messages

The whisker-editor-web TypeScript parser is ~95% complete but lacks:
- Complete corpus test coverage
- Source map generation
- Error recovery improvements

## Goals

1. Complete whisker-core parser to 100%
2. Achieve parity between Lua and TypeScript parsers
3. Add source mapping to both parsers
4. Implement error recovery in both parsers

## Affected Files

### whisker-core
- `lib/whisker/parser/ws_lexer.lua`
- `lib/whisker/parser/ws_parser.lua`
- `tests/wls/test_ws_format.lua` (new)
- `tests/wls/test_parser_errors.lua` (new)

### whisker-editor-web
- `packages/parser/src/lexer.ts`
- `packages/parser/src/parser.ts`
- `packages/parser/src/source-map.ts` (new)
- `packages/parser/src/error-recovery.ts` (new)

---

## Phase 1.1: Audit and Design

### Task 1.1.1: Audit Current Parser State (whisker-core)

**Objective:** Document exactly what's missing in the Lua parser.

**Steps:**
1. Read `ws_parser.lua` and catalog all parse functions
2. Compare against WLS 1.0 grammar (`spec/GRAMMAR.ebnf`)
3. Create checklist of missing syntax elements
4. Document current error handling approach

**Deliverables:**
- `implementation-plan/audits/parser-lua-audit.md`
- Checklist of 15-20 missing features

**Estimated tokens:** ~3,000

---

### Task 1.1.2: Audit Current Parser State (whisker-editor-web)

**Objective:** Document gaps in the TypeScript parser.

**Steps:**
1. Read `parser.ts` and catalog all parse functions
2. Compare against WLS 1.0 grammar
3. Identify any missing edge cases
4. Document error handling patterns

**Deliverables:**
- `implementation-plan/audits/parser-ts-audit.md`
- List of improvements needed

**Estimated tokens:** ~3,000

---

### Task 1.1.3: Design AST Node Types

**Objective:** Define unified AST structure for both parsers.

**Steps:**
1. Review current AST types in `packages/parser/src/ast.ts`
2. Design missing node types for:
   - Text alternatives (sequence, cycle, shuffle, once)
   - Gather points (for Gap 2)
   - Tunnels (for Gap 2)
3. Create Lua equivalent type definitions

**Deliverables:**
- Updated `ast.ts` with all node types
- `lib/whisker/parser/ast_types.lua` (new)

**Estimated tokens:** ~4,000

---

### Task 1.1.4: Design Source Map Format

**Objective:** Define source map structure for error reporting.

**Steps:**
1. Research standard source map formats (v3)
2. Design lightweight format suitable for Whisker
3. Define API for source position lookup
4. Document format specification

**Deliverables:**
- Source map format specification
- API design document

**Estimated tokens:** ~2,000

---

### Review Checkpoint 1.1

**Verification:**
- [ ] Both parser audits complete
- [ ] AST types defined for all syntax elements
- [ ] Source map format specified
- [ ] No blocking issues identified

**Criteria for proceeding:**
- Clear list of missing parser features
- Agreed AST structure
- Source map design approved

---

## Phase 1.2: Complete Lua Parser

### Task 1.2.1: Implement Text Alternative Parsing

**Objective:** Parse sequence, cycle, shuffle, and once-only alternatives.

**Steps:**
1. Add lexer tokens for `{|`, `{&|`, `{~|`, `{!|`
2. Implement `parse_sequence_alternative()`
3. Implement `parse_cycle_alternative()`
4. Implement `parse_shuffle_alternative()`
5. Implement `parse_once_alternative()`
6. Add unit tests for each type

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Test file:** `tests/wls/test_alternatives.lua`

**Estimated tokens:** ~8,000

---

### Task 1.2.2: Implement Inline Conditional Parsing

**Objective:** Parse inline conditionals `{cond: true_text | false_text}`.

**Steps:**
1. Distinguish inline conditionals from block conditionals
2. Implement `parse_inline_conditional()`
3. Handle nested inline conditionals
4. Add unit tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~5,000

---

### Task 1.2.3: Implement Expression Interpolation

**Objective:** Parse `${expression}` syntax.

**Steps:**
1. Add lexer recognition for `${`
2. Implement `parse_expression_interpolation()`
3. Support nested expressions
4. Handle edge cases (escaped, unterminated)
5. Add unit tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~4,000

---

### Task 1.2.4: Implement Choice Action Parsing

**Objective:** Parse choice actions `{do statement}`.

**Steps:**
1. Add lexer token for `{do`
2. Implement `parse_choice_action()`
3. Support multiple statements separated by `;`
4. Add unit tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~4,000

---

### Task 1.2.5: Complete Metadata Parsing

**Objective:** Parse all `@directive` types.

**Steps:**
1. Implement `@tags: tag1, tag2`
2. Implement `@notes: text`
3. Implement `@onEnter: script`
4. Implement `@onExit: script`
5. Add unit tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~5,000

---

### Review Checkpoint 1.2

**Verification:**
- [ ] All text alternative types parse correctly
- [ ] Inline conditionals work
- [ ] Expression interpolation works
- [ ] Choice actions parse
- [ ] All metadata directives supported
- [ ] Unit tests pass

**Test command:**
```bash
cd whisker-core && busted tests/wls/
```

**Criteria for proceeding:**
- All syntax elements from WLS 1.0 spec parse correctly
- No regressions in existing tests

---

## Phase 1.3: Error Recovery and Messages

### Task 1.3.1: Implement Error Recovery (Lua)

**Objective:** Parser continues after errors, collecting multiple issues.

**Steps:**
1. Create `ParseError` class with position info
2. Implement synchronization points (passage boundaries)
3. Add `recover_to_next_passage()` function
4. Collect errors in array instead of throwing
5. Add tests for error recovery

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~6,000

---

### Task 1.3.2: Improve Error Messages (Lua)

**Objective:** Provide helpful, contextual error messages.

**Steps:**
1. Add line/column tracking to lexer
2. Create error message templates
3. Include context (surrounding text) in errors
4. Add suggestions for common mistakes
5. Format messages consistently

**Example output:**
```
Error at line 15, column 8:
  Unexpected token ']' in choice text

  15 | + [Go to the [cave] -> Cave
                    ^

  Hint: Escape brackets with \[ and \]
```

**Estimated tokens:** ~5,000

---

### Task 1.3.3: Implement Error Recovery (TypeScript)

**Objective:** Improve TypeScript parser error recovery.

**Steps:**
1. Review current error handling in `parser.ts`
2. Add recovery points at passage boundaries
3. Implement `synchronize()` method
4. Collect all errors before returning
5. Add tests for error recovery

**Code location:** `packages/parser/src/parser.ts`

**Estimated tokens:** ~5,000

---

### Task 1.3.4: Improve Error Messages (TypeScript)

**Objective:** Parity with Lua error messages.

**Steps:**
1. Create `ParserError` class with full context
2. Add error message templates matching Lua
3. Include code snippets in error output
4. Add suggestion system
5. Update existing tests

**Code location:** `packages/parser/src/parser.ts`

**Estimated tokens:** ~5,000

---

### Review Checkpoint 1.3

**Verification:**
- [ ] Both parsers recover from errors
- [ ] Multiple errors reported per parse
- [ ] Error messages include line/column
- [ ] Error messages include context
- [ ] Suggestions provided for common errors

**Test cases:**
```whisker
// Should report 3 errors, not stop at first
:: Start
+ [Unclosed choice
{ $missing_close
Content here
:: Second
Normal content
```

**Criteria for proceeding:**
- Error recovery working in both parsers
- Error message format identical between parsers

---

## Phase 1.4: Source Mapping

### Task 1.4.1: Implement Source Map Generation (Lua)

**Objective:** Track source positions for all AST nodes.

**Steps:**
1. Add `start_pos` and `end_pos` to all AST nodes
2. Create `SourceMap` class
3. Implement position lookup functions
4. Store source file name in AST root
5. Add tests for position accuracy

**Code location:** `lib/whisker/parser/source_map.lua` (new)

**Estimated tokens:** ~6,000

---

### Task 1.4.2: Implement Source Map Generation (TypeScript)

**Objective:** Generate source maps compatible with standard tooling.

**Steps:**
1. Add position info to all AST nodes
2. Create `SourceMap` class
3. Implement v3 source map format export
4. Add position lookup API
5. Integrate with existing parser

**Code location:** `packages/parser/src/source-map.ts` (new)

**Estimated tokens:** ~6,000

---

### Task 1.4.3: Integrate Source Maps with Runtime (Lua)

**Objective:** Use source maps for runtime error reporting.

**Steps:**
1. Pass source map to runtime engine
2. Catch runtime errors and map to source
3. Format runtime errors with source context
4. Add tests for runtime error mapping

**Code location:** `lib/whisker/core/engine.lua`

**Estimated tokens:** ~4,000

---

### Task 1.4.4: Integrate Source Maps with Runtime (TypeScript)

**Objective:** Use source maps in story player.

**Steps:**
1. Store source map in parsed story
2. Map player errors to source positions
3. Expose error position in player API
4. Add tests for error mapping

**Code location:** `packages/story-player/src/StoryPlayer.ts`

**Estimated tokens:** ~4,000

---

### Review Checkpoint 1.4

**Verification:**
- [ ] All AST nodes have position info
- [ ] Source maps generated correctly
- [ ] Runtime errors map to source
- [ ] Position lookup API works
- [ ] Tests verify position accuracy

**Test case:**
```lua
-- Parse story, cause runtime error, verify line number
local story = parser.parse([[
:: Start
$undefined_var
]])
-- Error should report "line 2" not internal line
```

**Criteria for proceeding:**
- Source mapping complete in both parsers
- Runtime errors show correct source positions

---

## Phase 1.5: Final Integration and Testing

### Task 1.5.1: Run Full Corpus Tests (Lua)

**Objective:** Verify parser against complete test corpus.

**Steps:**
1. Create corpus test runner for Lua
2. Run all tests from `spec/test-corpus/`
3. Fix any failing tests
4. Document any intentional differences

**Code location:** `tests/integration/wls/corpus_runner.lua`

**Estimated tokens:** ~5,000

---

### Task 1.5.2: Run Full Corpus Tests (TypeScript)

**Objective:** Verify TypeScript parser against corpus.

**Steps:**
1. Update corpus test runner
2. Run all tests
3. Fix any failing tests
4. Verify parity with Lua results

**Code location:** `packages/parser/src/corpus.test.ts`

**Estimated tokens:** ~4,000

---

### Task 1.5.3: Cross-Platform Parity Verification

**Objective:** Ensure identical parsing between implementations.

**Steps:**
1. Create parity test suite
2. Parse same input in both parsers
3. Compare AST structures
4. Document any differences
5. Fix discrepancies

**Deliverables:**
- Parity test suite
- Verification report

**Estimated tokens:** ~5,000

---

### Task 1.5.4: Update Parser Documentation

**Objective:** Document completed parser features.

**Steps:**
1. Update API documentation
2. Add usage examples
3. Document error message format
4. Document source map API
5. Update spec if needed

**Deliverables:**
- Updated README files
- API documentation

**Estimated tokens:** ~3,000

---

### Review Checkpoint 1.5 (Gap 1 Complete)

**Verification:**
- [ ] 100% corpus tests pass (Lua)
- [ ] 100% corpus tests pass (TypeScript)
- [ ] Parsers produce identical AST
- [ ] Documentation complete
- [ ] No regressions

**Final metrics:**
| Metric | Before | After |
|--------|--------|-------|
| Lua parser completeness | 70% | 100% |
| TS parser completeness | 95% | 100% |
| Corpus tests passing | 51/51 | 100+/100+ |
| Error recovery | None | Full |
| Source maps | None | Complete |

**Sign-off requirements:**
- All tests pass
- Code reviewed
- Documentation updated
- Ready to proceed to Gap 2
