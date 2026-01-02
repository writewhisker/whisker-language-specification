# Phase 1: Validation Verification

## Pre-Implementation Checks

- [ ] Read existing validators in `packages/story-validation/src/validators/`
- [ ] Review error codes in `packages/story-validation/src/error-codes.ts`
- [ ] Check test corpus structure in `phase-4-validation/test-corpus/`

## Implementation Verification

### Specification
- [ ] `spec/11-VALIDATION.md` exists with all 35+ error codes
- [ ] Each error code has: id, severity, message format, example
- [ ] Severity levels documented: error, warning, info

### TypeScript Implementation
```bash
cd ~/code/github.com/writewhisker/whisker-editor-web

# Run validation tests
pnpm --filter @writewhisker/story-validation test -- --run

# Check new validators exist
ls packages/story-validation/src/validators/

# Verify error codes file
cat packages/story-validation/src/error-codes/wls-error-codes.ts
```

Required validators:
- [ ] `DuplicatePassagesValidator.ts`
- [ ] `SelfLinkValidator.ts`
- [ ] `VariableScopingValidator.ts`
- [ ] `TypeChecker.ts`
- [ ] `CycleDetector.ts`
- [ ] `DeadEndDetector.ts`

### Lua Implementation
```bash
cd ~/code/github.com/writewhisker/whisker-core

# Run validator tests
busted spec/validators/

# Check validators exist
ls lib/whisker/validators/
```

Required files:
- [ ] `lib/whisker/validators/init.lua`
- [ ] `lib/whisker/validators/error_codes.lua`
- [ ] `lib/whisker/validators/structural.lua`
- [ ] `lib/whisker/validators/links.lua`
- [ ] `lib/whisker/validators/variables.lua`
- [ ] `lib/whisker/validators/expressions.lua`
- [ ] `lib/whisker/validators/types.lua`
- [ ] `lib/whisker/validators/flow.lua`
- [ ] `lib/whisker/validators/quality.lua`

### Test Corpus
```bash
cd ~/code/github.com/whisker-language-specification-1.0/phase-4-validation

# Count validation tests
ls test-corpus/validation/ | wc -l
# Expected: 50+

# Run corpus tests
./run-corpus.sh
```

## Cross-Platform Parity Checks

### Error Code Parity
```bash
# Extract TS error codes
grep -r "WLS-" ~/code/github.com/writewhisker/whisker-editor-web/packages/story-validation/src/ | grep -o "WLS-[A-Z]*-[0-9]*" | sort -u > /tmp/ts-codes.txt

# Extract Lua error codes
grep -r "WLS-" ~/code/github.com/writewhisker/whisker-core/lib/whisker/validators/ | grep -o "WLS-[A-Z]*-[0-9]*" | sort -u > /tmp/lua-codes.txt

# Compare
diff /tmp/ts-codes.txt /tmp/lua-codes.txt
# Expected: no differences
```

### Validation Behavior Parity
For each test case in corpus:
- [ ] TypeScript produces expected error codes
- [ ] Lua produces expected error codes
- [ ] Error messages match (modulo formatting)
- [ ] Severity levels match

## Acceptance Criteria

1. **Specification Complete**
   - [ ] All 35+ error codes documented
   - [ ] Examples for each error code
   - [ ] Severity levels defined

2. **TypeScript Implementation**
   - [ ] All validators implemented
   - [ ] Tests pass: `pnpm --filter @writewhisker/story-validation test`
   - [ ] No regressions in existing tests

3. **Lua Implementation**
   - [ ] All validators implemented
   - [ ] Tests pass: `busted`
   - [ ] Integration with parser works

4. **Cross-Platform Parity**
   - [ ] Same error codes in both platforms
   - [ ] Same validation behavior
   - [ ] Corpus tests pass on both

5. **Test Coverage**
   - [ ] 50+ validation test cases
   - [ ] All error codes have at least one test
   - [ ] Edge cases covered

## Error Code Checklist

### Structure (STR)
- [ ] WLS-STR-001: missing_start_passage
- [ ] WLS-STR-002: unreachable_passage
- [ ] WLS-STR-003: duplicate_passage
- [ ] WLS-STR-004: empty_passage
- [ ] WLS-STR-005: orphan_passage
- [ ] WLS-STR-006: bottleneck

### Links (LNK)
- [ ] WLS-LNK-001: dead_link
- [ ] WLS-LNK-002: self_link
- [ ] WLS-LNK-003: special_target_case
- [ ] WLS-LNK-004: empty_choice_target
- [ ] WLS-LNK-005: circular_link

### Variables (VAR)
- [ ] WLS-VAR-001: undefined_variable
- [ ] WLS-VAR-002: unused_variable
- [ ] WLS-VAR-003: invalid_variable_name
- [ ] WLS-VAR-004: type_mismatch
- [ ] WLS-VAR-005: scope_violation
- [ ] WLS-VAR-006: variable_shadowing
- [ ] WLS-VAR-007: reserved_name
- [ ] WLS-VAR-008: uninitialized_read

### Expressions (EXP)
- [ ] WLS-EXP-001: empty_expression
- [ ] WLS-EXP-002: unmatched_parenthesis
- [ ] WLS-EXP-003: invalid_operator
- [ ] WLS-EXP-004: malformed_string
- [ ] WLS-EXP-005: invalid_number
- [ ] WLS-EXP-006: nested_expression_limit
- [ ] WLS-EXP-007: unclosed_block

### Types (TYP)
- [ ] WLS-TYP-001: type_mismatch
- [ ] WLS-TYP-002: arithmetic_on_string
- [ ] WLS-TYP-003: comparison_mismatch
- [ ] WLS-TYP-004: invalid_assignment
- [ ] WLS-TYP-005: list_type_mismatch

### Flow (FLW)
- [ ] WLS-FLW-001: dead_end
- [ ] WLS-FLW-002: no_terminal
- [ ] WLS-FLW-003: cycle_detected
- [ ] WLS-FLW-004: infinite_loop
- [ ] WLS-FLW-005: unreachable_code
- [ ] WLS-FLW-006: conditional_always_false

### Quality (QUA)
- [ ] WLS-QUA-001: low_branching
- [ ] WLS-QUA-002: high_complexity
- [ ] WLS-QUA-003: long_passage
- [ ] WLS-QUA-004: deep_nesting
- [ ] WLS-QUA-005: too_many_variables
