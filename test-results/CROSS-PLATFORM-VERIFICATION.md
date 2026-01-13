# WLS Cross-Platform Validation Verification

**Date:** 2025-12-31
**Version:** WLS

## Summary

Both TypeScript (whisker-editor-web) and Lua (whisker-core) validators produce **100% identical results** across all 51 validation test cases.

| Platform | Tests | Passed | Failed | Pass Rate |
|----------|-------|--------|--------|-----------|
| TypeScript | 51 | 51 | 0 | 100.0% |
| Lua | 51 | 51 | 0 | 100.0% |
| **Cross-Platform Parity** | 51 | 51 | 0 | **100.0%** |

## Error Codes Verified

Both platforms correctly detect and report the following error codes:

### Structural (WLS-STR-*)
| Code | Severity | Description | Verified |
|------|----------|-------------|----------|
| WLS-STR-001 | error | Missing start passage | Yes |
| WLS-STR-002 | warning | Unreachable passage | Yes |
| WLS-STR-003 | error | Duplicate passage names | Yes |
| WLS-STR-004 | warning | Empty passage content | Yes |

### Links (WLS-LNK-*)
| Code | Severity | Description | Verified |
|------|----------|-------------|----------|
| WLS-LNK-001 | error | Dead link (non-existent target) | Yes |
| WLS-LNK-002 | warning | Self-link without action | Yes |
| WLS-LNK-003 | warning | Special target case mismatch | Yes |
| WLS-LNK-004 | warning | BACK on start passage (only choice) | Yes |
| WLS-LNK-005 | error | Empty choice target | Yes |

### Variables (WLS-VAR-*)
| Code | Severity | Description | Verified |
|------|----------|-------------|----------|
| WLS-VAR-001 | error | Undefined variable | Yes |
| WLS-VAR-002 | warning | Unused variable | Yes |
| WLS-VAR-003 | error | Invalid variable name | Yes |

### Flow (WLS-FLW-*)
| Code | Severity | Description | Verified |
|------|----------|-------------|----------|
| WLS-FLW-001 | info | Dead end (no choices) | Yes |

## Test Categories

### structural-tests.yaml (13 tests)
- Start passage validation (3 tests)
- Unreachable passage detection (4 tests)
- Duplicate name detection (3 tests)
- Empty content detection (3 tests)

### links-tests.yaml (17 tests)
- Dead link detection (4 tests)
- Self-link warnings (3 tests)
- Special target case (4 tests)
- BACK on start (3 tests)
- Empty target (3 tests)

### variables-tests.yaml (11 tests)
- Undefined variable detection (4 tests)
- Unused variable warnings (4 tests)
- Invalid name detection (3 tests)

### flow-tests.yaml (5 tests)
- Dead end detection (5 tests)

### combined-tests.yaml (5 tests)
- Multiple validation issues (5 tests)

## Intentional Differences

**None.** Both platforms implement identical validation semantics.

## Running Verification

```bash
# Run TypeScript validator
node tools/validation-corpus-runner.cjs

# Run Lua validator
lua tools/validation-corpus-runner.lua

# Compare results
node tools/compare-validation-results.cjs
```

## Files

- `validation-ts-results.json` - TypeScript validation results
- `validation-lua-results.json` - Lua validation results
- `compare-validation-results.cjs` - Cross-platform comparison tool

## Conclusion

WLS validation is fully cross-platform compatible. Stories validated by either implementation will produce identical error codes, severities, and issue counts.
