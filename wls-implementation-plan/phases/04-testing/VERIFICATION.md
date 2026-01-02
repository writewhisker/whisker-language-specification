# Phase 4: Testing Verification

## Pre-Implementation Checks

- [ ] Review current test structure
- [ ] Check coverage configuration
- [ ] Identify untested areas
- [ ] Set up coverage reporting

## Coverage Verification

### TypeScript Coverage
```bash
cd ~/code/github.com/writewhisker/whisker-editor-web

# Run with coverage
pnpm test -- --coverage

# Check thresholds
pnpm test -- --coverage --coverageThreshold='{"global":{"lines":95}}'
```

**Package Targets:**

| Package | Current | Target |
|---------|---------|--------|
| @writewhisker/parser | 95% | 98% |
| @writewhisker/story-models | 90% | 95% |
| @writewhisker/story-validation | 80% | 95% |
| @writewhisker/story-player | 70% | 90% |
| @writewhisker/import | - | 90% |
| @writewhisker/export | - | 90% |

### Lua Coverage
```bash
cd ~/code/github.com/writewhisker/whisker-core

# Run with LuaCov
busted --coverage

# Generate report
luacov
cat luacov.report.out | grep -A5 "Summary"
```

**Module Targets:**

| Module | Current | Target |
|--------|---------|--------|
| whisker.parser | 85% | 95% |
| whisker.runtime | 70% | 90% |
| whisker.validators | 80% | 95% |

## Corpus Test Verification

### Count Tests
```bash
cd ~/code/github.com/whisker-language-specification-1.0/phase-4-validation

# Count YAML test files
find test-corpus -name "*.yaml" | wc -l
# Target: 200+

# Count individual test cases
grep -r "^- name:" test-corpus/ | wc -l
# Target: 200+
```

### Run Corpus
```bash
# TypeScript runner
./tools/run-corpus.sh --platform=typescript

# Lua runner
./tools/run-corpus.sh --platform=lua

# Both (for parity check)
./tools/run-corpus.sh --all
```

### Corpus Categories
- [ ] `basic/` has 50+ tests
- [ ] `advanced/` has 30+ tests
- [ ] `edge-cases/` has 30+ tests
- [ ] `validation/` has 50+ tests
- [ ] `import/` has 20+ tests
- [ ] `export/` has 20+ tests

## Test Quality Verification

### No Skipped Tests
```bash
# TypeScript
grep -r "\.skip\|\.todo\|xit\|xdescribe" packages/*/src/**/*.test.ts
# Expected: none (or documented reasons)

# Lua
grep -r "pending\|xit\|xdescribe" spec/
# Expected: none (or documented reasons)
```

### Meaningful Assertions
```bash
# Check for empty test bodies
grep -rA5 "it\(.*function" packages/*/src/**/*.test.ts | grep -B5 "^--$"
# Expected: none
```

### Error Cases Tested
```bash
# Count error test cases
grep -r "toThrow\|rejects\|error" packages/*/src/**/*.test.ts | wc -l
# Should be substantial
```

## Cross-Platform Parity

### Same Tests, Same Results
```bash
cd ~/code/github.com/whisker-language-specification-1.0/phase-4-validation

# Run comparison
./tools/compare-platforms.sh

# Check for differences
cat comparison-report.txt
# Expected: no behavioral differences
```

### Corpus Test Parity
For each test case:
- [ ] TypeScript passes
- [ ] Lua passes
- [ ] Output matches (where applicable)

## Performance Testing

### Parser Performance
```bash
# TypeScript
pnpm --filter @writewhisker/parser test -- --grep "performance"

# Lua
busted spec/parser/performance_spec.lua
```

**Benchmarks:**
- [ ] Parse 10KB story < 100ms
- [ ] Parse 100KB story < 1s
- [ ] Parse 1MB story < 10s

### Runtime Performance
- [ ] 1000 passage transitions < 1s
- [ ] 10000 variable updates < 1s
- [ ] Save/load cycle < 100ms

## Acceptance Criteria

1. **Coverage Thresholds**
   - [ ] TypeScript overall: 95%+
   - [ ] Lua overall: 90%+
   - [ ] Critical paths: 98%+

2. **Corpus Size**
   - [ ] 200+ test cases
   - [ ] All features covered
   - [ ] Edge cases documented

3. **Cross-Platform**
   - [ ] All corpus tests pass on both
   - [ ] No behavioral differences

4. **Performance**
   - [ ] Benchmarks documented
   - [ ] No regressions

5. **CI Integration**
   - [ ] Coverage checked on every PR
   - [ ] Corpus run on every PR
   - [ ] Performance tracked

## Test File Checklist

### Parser Tests
- [ ] `passage-names.test.ts` - All valid/invalid names
- [ ] `choice-syntax.test.ts` - All choice variations
- [ ] `conditional-blocks.test.ts` - All conditional forms
- [ ] `data-structures.test.ts` - LIST, ARRAY, MAP
- [ ] `functions.test.ts` - FUNCTION, NAMESPACE
- [ ] `unicode.test.ts` - Non-ASCII characters
- [ ] `whitespace.test.ts` - Indentation, blank lines
- [ ] `error-recovery.test.ts` - Malformed input

### Runtime Tests
- [ ] `passage-navigation.test.ts`
- [ ] `choice-selection.test.ts`
- [ ] `variable-operations.test.ts`
- [ ] `save-load.test.ts`
- [ ] `special-passages.test.ts`
- [ ] `function-calls.test.ts`

### Validator Tests
- [ ] `structural-validators.test.ts`
- [ ] `link-validators.test.ts`
- [ ] `variable-validators.test.ts`
- [ ] `expression-validators.test.ts`
- [ ] `type-validators.test.ts`
- [ ] `flow-validators.test.ts`
- [ ] `quality-validators.test.ts`
