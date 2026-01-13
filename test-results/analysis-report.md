# WLS Test Corpus Analysis Report

**Date:** 2025-12-30
**Platform:** whisker-editor-web
**Results:** 180/250 passed (72.0%)

## Summary by Category

| Category | Passed | Failed | Pass Rate |
|----------|--------|--------|-----------|
| syntax | 44 | 6 | 88% |
| variables | 27 | 8 | 77% |
| conditionals | 35 | 5 | 87.5% |
| choices | 21 | 9 | 70% |
| alternatives | 20 | 5 | 80% |
| api | 1 | 24 | 4% |
| formats | 6 | 9 | 40% |
| edge-cases | 26 | 4 | 87% |

## Failure Analysis

### 1. Parser Bug: Once-Only Alternatives `{!| }` (5 failures)

**Issue:** The lexer treats `!` as an error (suggesting `not` for logical negation) without checking if it's part of a once-only alternative `{!| }` syntax.

**Affected tests:**
- `alt-once-basic`
- `alt-once-exhausted`
- `alt-once-single`
- `alt-once-in-sentence`
- `alt-once-with-sequence`

**Error:** `Use "not" instead of ! for logical not`

**Fix needed:** Update lexer to check if `!` follows `{` and precedes `|` for alternatives.

### 2. Test Corpus Syntax Mismatch: Lua Embedding (24 failures)

**Issue:** Test corpus uses `{{ expression }}` for Lua embedding, but whisker-editor-web uses `${ expression }` for interpolation.

**Affected tests:** All API tests use incorrect syntax:
```whisker
# Test corpus syntax (incorrect for this platform):
Value: {{ whisker.state.get("gold") }}

# Correct whisker-editor-web syntax:
Value: ${whisker.state.get("gold")}
```

**Tests affected:**
- All `api-*` tests (24 total)

**Resolution:** Either update test corpus to use `${}` or these tests require runtime (Lua) execution.

### 3. Semantic Validation Not Implemented (18 failures)

The parser performs syntax validation only. The following semantic checks are NOT performed:

| Check | Tests |
|-------|-------|
| Duplicate passage names | `syntax-passage-duplicate` |
| Passage name validation (spaces) | `syntax-passage-invalid-space` |
| Passage name validation (hyphens) | `syntax-passage-invalid-hyphen` |
| Undefined variable access | `var-undefined-access`, `var-declare-order` |
| Reserved variable prefixes | `var-declare-reserved-prefix` |
| Type mismatch detection | `var-type-mismatch-*` |
| Missing choice targets | `choice-missing-target` |
| Invalid choice targets | `choice-invalid-target` |
| Unclosed conditionals | `cond-block-unclosed` |
| Orphan close tags | `cond-block-orphan-close` |
| Empty file detection | `format-text-empty-file` |
| Division by zero | `edge-division-by-zero` |
| Modulo by zero | `edge-modulo-zero` |

**Note:** These are semantic/runtime validations that could be added to a validator pass after parsing.

### 4. Format Tests: JSON Not Supported (4 failures)

**Issue:** whisker-editor-web parser only handles Whisker text format, not JSON format.

**Affected tests:**
- `format-json-minimal`
- `format-json-full`
- `format-json-missing-format`
- `format-json-missing-passages`

**Error:** `TypeError: Cannot read properties of undefined (reading 'length')`

**Resolution:** These tests require JSON format support or should be excluded for text parser.

### 5. Unicode Support (1 failure)

**Issue:** Parser doesn't support Unicode characters in content.

**Test:** `format-text-utf8`
**Error:** `Unexpected character: 世`

**Fix needed:** Update lexer to accept Unicode characters in text content.

### 6. Other Syntax Edge Cases (3 failures)

- `syntax-passage-invalid-number-start`: Different error message than expected
- `syntax-comment-before-passage`: Comments before first passage not supported
- `cond-block-logical-not`: Uses `!` for negation (should use `not`)

## Recommendations

### Critical (Must Fix)
1. **Once-only alternatives bug** - Fix lexer to properly handle `{!| }` syntax

### High Priority (Should Fix)
2. **Unicode support** - Allow Unicode characters in text content
3. **Comments before passages** - Support comments before first passage marker

### Medium Priority (Enhancement)
4. **Semantic validator** - Add post-parse validation for:
   - Duplicate passages
   - Undefined variables
   - Invalid targets
   - Type mismatches

### Low Priority (Documentation)
5. **Test corpus alignment** - Document syntax differences:
   - `${}` for interpolation (not `{{}}`)
   - `not` for logical negation (not `!`)

### Out of Scope for Parser
6. **API tests** - Require runtime execution (Lua)
7. **JSON format** - Different parser needed

## Action Items for Task 4.4 (Fix Discrepancies)

1. [ ] Fix once-only alternative `{!| }` lexer bug
2. [ ] Add Unicode character support in text content
3. [ ] Support comments before first passage
4. [ ] Update test corpus to use correct `${}` syntax
5. [ ] Consider adding semantic validator pass
