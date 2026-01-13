# WLS Behavioral Differences Report

**Version:** 1.0
**Date:** 2025-12-30
**Status:** Partial (whisker-core not yet available)

## Overview

This document catalogs behavioral differences between WLS implementations:
- **whisker-core**: Lua runtime (Phase 2 - pending)
- **whisker-editor-web**: TypeScript/Browser (Phase 3 - complete)

## Test Results Summary

| Platform | Tests | Passed | Failed | Pass Rate |
|----------|-------|--------|--------|-----------|
| whisker-core | 250 | - | - | - |
| whisker-editor-web | 250 | 180 | 70 | 72% |

## Behavioral Categories

### 1. State Management

#### Expected Behavior (WLS Spec)
- Variables use `$name` syntax
- Assignment: `$var = value`
- Interpolation: `${expr}`
- Scopes: story-scope (`$var`), temp-scope (`_var`)

#### whisker-editor-web Status
| Feature | Status | Notes |
|---------|--------|-------|
| Variable declaration | PASS | `$name = value` works |
| Variable access | PASS | `$name` reads variable |
| Interpolation | PASS | `${expr}` evaluates expression |
| Temp-scope variables | PASS | `_name` available |
| Undefined access | NO VALIDATION | Parser doesn't check |
| Type mismatch | NO VALIDATION | Parser doesn't check |

#### Tests Affected
- `var-undefined-access` - Parser accepts undefined variables
- `var-declare-order` - Parser doesn't enforce declaration order
- `var-type-mismatch-*` - Parser doesn't check types

### 2. Navigation

#### Expected Behavior (WLS Spec)
- Choice targets: `+ [text] -> Target`
- Passage transitions via runtime
- History tracking

#### whisker-editor-web Status
| Feature | Status | Notes |
|---------|--------|-------|
| Choice parsing | PASS | Both `+` and `*` work |
| Target parsing | PASS | Extracts target name |
| Target validation | NO VALIDATION | Invalid targets accepted |
| Navigation runtime | NOT TESTED | Requires runtime |

#### Tests Affected
- `choice-missing-target` - Parser accepts missing target
- `choice-invalid-target` - Parser doesn't validate existence

### 3. Choice Processing

#### Expected Behavior (WLS Spec)
- Once-only: `+ [text] -> Target`
- Sticky: `* [text] -> Target`
- Conditions: `{condition} + [text] -> Target`

#### whisker-editor-web Status
| Feature | Status | Notes |
|---------|--------|-------|
| Once-only choices | PASS | `+` creates once choice |
| Sticky choices | PASS | `*` creates sticky choice |
| Choice conditions | PARTIAL | Condition parsing works |
| Condition with `!` | FAIL | Error: use `not` |

#### Tests Affected
- `choice-condition-visit` - Uses `!` instead of `not`

### 4. Content Rendering

#### Expected Behavior (WLS Spec)
- Plain text content
- Variable interpolation: `${expr}`
- Conditional blocks: `{cond}...{/}`
- Alternatives: `{| a | b | c }`

#### whisker-editor-web Status
| Feature | Status | Notes |
|---------|--------|-------|
| Plain text | PARTIAL | ASCII works, Unicode fails |
| Interpolation | PASS | `${expr}` works |
| Conditional blocks | PASS | Parsing works |
| Sequence alternatives | PASS | `{| a | b }` |
| Cycle alternatives | PASS | `{&| a | b }` |
| Shuffle alternatives | PASS | `{~| a | b }` |
| Once-only alternatives | **FAIL** | `{!| a | b }` rejected |

#### Tests Affected
- `alt-once-*` (5 tests) - Parser bug with `{!| }`
- `format-text-utf8` - Unicode characters rejected

### 5. Conditional Blocks

#### Expected Behavior (WLS Spec)
- Block: `{condition} content {/}`
- Else: `{else}` or `{elif condition}`
- Inline: `{cond? true | false}`
- Logical: `and`, `or`, `not`

#### whisker-editor-web Status
| Feature | Status | Notes |
|---------|--------|-------|
| Block conditionals | PASS | `{cond}...{/}` works |
| Else clause | PASS | `{else}` works |
| Elif clause | PASS | `{elif cond}` works |
| Inline conditionals | PASS | `{cond? a | b}` works |
| Logical `and` | PASS | Works correctly |
| Logical `or` | PASS | Works correctly |
| Logical `not` | PASS | Works correctly |
| Logical `!` | **FAIL** | Must use `not` |

#### Tests Affected
- `cond-block-logical-not` - Uses `!` instead of `not`
- `cond-block-unclosed` - No validation for unclosed
- `cond-block-orphan-close` - No validation for orphan `{/}`

## Detailed Behavioral Differences

### BD-001: Once-Only Alternatives `{!| }`

**Category:** Parser Bug
**Severity:** High
**Tests:** 5

**Expected (per WLS):**
```whisker
:: Start
{!| First | Second | Third }
```
Should parse as once-only alternatives.

**Actual (whisker-editor-web):**
```
Error: Use "not" instead of ! for logical not
```

**Root Cause:**
Lexer treats `!` as C-style negation operator and rejects it, without checking if it's inside `{!| }` context for alternatives.

**Fix:** Update lexer to check for `{!` sequence before treating `!` as error.

---

### BD-002: Lua Embedding Syntax

**Category:** Spec/Corpus Mismatch
**Severity:** Medium (Corpus issue, not parser)
**Tests:** 24

**Test Corpus Uses:**
```whisker
Value: {{ whisker.state.get("gold") }}
```

**WLS Syntax (whisker-editor-web):**
```whisker
Value: ${whisker.state.get("gold")}
```

**Root Cause:**
Test corpus was written with different syntax expectations. The WLS spec uses `${}` for expressions/interpolation.

**Resolution:** Update test corpus to use correct syntax, or mark API tests as runtime-only.

---

### BD-003: Unicode Character Support

**Category:** Parser Limitation
**Severity:** Medium
**Tests:** 1

**Expected:**
```whisker
:: Start
Hello 世界
```
Should parse successfully.

**Actual:**
```
Error: Unexpected character: 世
```

**Root Cause:**
Lexer only recognizes ASCII characters in text content.

**Fix:** Update lexer to accept Unicode characters in content.

---

### BD-004: Semantic Validation

**Category:** Missing Feature
**Severity:** Low (Parser vs Validator scope)
**Tests:** 18

The parser performs syntax validation only. Semantic validation is not implemented for:

| Validation | Expected | Actual |
|------------|----------|--------|
| Duplicate passages | Error | Accepted |
| Invalid passage names | Error | Accepted (spaces, hyphens) |
| Undefined variables | Error | Accepted |
| Invalid choice targets | Error | Accepted |
| Unclosed conditionals | Error | Accepted |
| Division by zero | Error | Accepted |

**Resolution:** Consider adding a separate semantic validation pass.

---

### BD-005: JSON Format Support

**Category:** Format Support
**Severity:** Low
**Tests:** 4

**Expected:**
Parser should handle JSON format stories.

**Actual:**
```
TypeError: Cannot read properties of undefined (reading 'length')
```

**Root Cause:**
whisker-editor-web parser only handles Whisker text format, not JSON.

**Resolution:** These tests are out of scope for text parser. Mark as format-specific.

---

## Cross-Platform Comparison

### Pending (whisker-core not available)

When whisker-core becomes available, compare:

| Scenario | Core | Editor | Difference |
|----------|------|--------|------------|
| Passage parsing | - | PASS | - |
| Variable handling | - | PASS | - |
| Choice processing | - | PARTIAL | - |
| Conditional evaluation | - | PASS | - |
| Alternative selection | - | PARTIAL | - |
| API functions | - | N/A | - |

## Recommendations

### Critical Fixes (Before WLS Release)

1. **Fix `{!| }` once-only alternatives** - Parser bug
2. **Add Unicode support** - Content internationalization

### High Priority Enhancements

3. **Update test corpus** - Use correct `${}` syntax
4. **Add semantic validator** - Catch errors at parse time

### Future Considerations

5. **JSON format parser** - Separate tool
6. **Cross-platform runtime testing** - When whisker-core available

## Appendix: Test Failure Matrix

| Test ID | Category | Issue | Priority |
|---------|----------|-------|----------|
| alt-once-basic | alternatives | BD-001 | P1 |
| alt-once-exhausted | alternatives | BD-001 | P1 |
| alt-once-single | alternatives | BD-001 | P1 |
| alt-once-in-sentence | alternatives | BD-001 | P1 |
| alt-once-with-sequence | alternatives | BD-001 | P1 |
| format-text-utf8 | formats | BD-003 | P2 |
| api-* (24 tests) | api | BD-002 | P3 |
| syntax-passage-duplicate | syntax | BD-004 | P3 |
| syntax-passage-invalid-space | syntax | BD-004 | P3 |
| var-undefined-access | variables | BD-004 | P3 |
| choice-missing-target | choices | BD-004 | P3 |
| format-json-* (4 tests) | formats | BD-005 | P4 |
