# Gap 8: Test Coverage

## Problem Statement

WLS 1.0 testing is incomplete:

1. **Corpus Coverage** - Test corpus doesn't cover all features
2. **Cross-Platform Testing** - No automated parity verification
3. **Edge Cases** - Many edge cases untested
4. **Performance Testing** - No benchmarks or load tests
5. **Fuzz Testing** - No randomized input testing

Robust testing is essential for specification compliance.

## Goals

1. Achieve 100% feature coverage in test corpus
2. Automate cross-platform parity testing
3. Add comprehensive edge case tests
4. Implement performance benchmarks
5. Add fuzz testing for parsers

## Current State

| Repository | Unit Tests | Integration | Corpus | Coverage |
|------------|------------|-------------|--------|----------|
| whisker-core | 150+ | Basic | 51 | ~70% |
| whisker-editor-web | 300+ | Good | 51 | ~85% |

## Target State

| Repository | Unit Tests | Integration | Corpus | Coverage |
|------------|------------|-------------|--------|----------|
| whisker-core | 300+ | Complete | 200+ | 95%+ |
| whisker-editor-web | 500+ | Complete | 200+ | 95%+ |

---

## Phase 8.1: Corpus Expansion

### Task 8.1.1: Audit Existing Corpus

**Objective:** Identify coverage gaps.

**Steps:**
1. List all WLS features from specification
2. Map features to existing tests
3. Identify untested features
4. Prioritize by importance
5. Create coverage matrix

**Deliverables:**
- Coverage audit document
- Feature-to-test mapping

**Estimated tokens:** ~4,000

---

### Task 8.1.2: Passage and Structure Tests

**Objective:** Add passage structure test cases.

**Steps:**
1. Add passage header edge cases
2. Add tag combination tests
3. Add metadata tests
4. Add multi-passage tests
5. Add empty/whitespace tests

**Deliverables:**
- 30+ new test cases in `test-corpus/structure/`

**Estimated tokens:** ~5,000

---

### Task 8.1.3: Choice and Link Tests

**Objective:** Add choice/link test cases.

**Steps:**
1. Add complex choice conditions
2. Add nested choice tests
3. Add special target tests (END, BACK)
4. Add sticky/fallback choice tests
5. Add link edge cases

**Deliverables:**
- 30+ new test cases in `test-corpus/choices/`

**Estimated tokens:** ~5,000

---

### Task 8.1.4: Variable and Expression Tests

**Objective:** Add variable test cases.

**Steps:**
1. Add type coercion tests
2. Add complex expression tests
3. Add scope boundary tests
4. Add temp variable tests
5. Add interpolation edge cases

**Deliverables:**
- 30+ new test cases in `test-corpus/variables/`

**Estimated tokens:** ~5,000

---

### Task 8.1.5: Content and Formatting Tests

**Objective:** Add content test cases.

**Steps:**
1. Add shuffle/cycle tests
2. Add sequence tests
3. Add conditional content tests
4. Add glue behavior tests
5. Add whitespace handling tests

**Deliverables:**
- 30+ new test cases in `test-corpus/content/`

**Estimated tokens:** ~5,000

---

### Task 8.1.6: Error Case Tests

**Objective:** Add expected error test cases.

**Steps:**
1. Add syntax error tests
2. Add semantic error tests
3. Add runtime error tests
4. Add each error code test
5. Document expected messages

**Deliverables:**
- 50+ new test cases in `test-corpus/errors/`

**Estimated tokens:** ~6,000

---

### Review Checkpoint 8.1

**Verification:**
- [ ] Coverage audit complete
- [ ] Structure tests added
- [ ] Choice tests added
- [ ] Variable tests added
- [ ] Content tests added
- [ ] Error tests added
- [ ] Corpus at 150+ tests

---

## Phase 8.2: Cross-Platform Parity

### Task 8.2.1: Parity Test Framework (Lua)

**Objective:** Create parity testing infrastructure.

**Steps:**
1. Create corpus runner for Lua
2. Output standardized result format
3. Handle error reporting
4. Support test filtering
5. Add framework tests

**Code location:** `whisker-core/tests/corpus_runner.lua`

**Estimated tokens:** ~5,000

---

### Task 8.2.2: Parity Test Framework (TypeScript)

**Objective:** Create TypeScript parity runner.

**Steps:**
1. Create corpus runner for TypeScript
2. Output identical result format
3. Match error handling
4. Support same filtering
5. Add framework tests

**Code location:** `packages/parser/src/tests/corpusRunner.ts`

**Estimated tokens:** ~5,000

---

### Task 8.2.3: Result Comparator

**Objective:** Compare test results between platforms.

**Steps:**
1. Create comparison tool
2. Identify behavioral differences
3. Generate difference report
4. Categorize differences
5. Add comparator tests

**Code location:** `tools/compare-results.js`

**Estimated tokens:** ~4,000

---

### Task 8.2.4: CI Integration

**Objective:** Automate parity testing in CI.

**Steps:**
1. Create GitHub Actions workflow
2. Run both test suites
3. Compare results automatically
4. Fail on differences
5. Generate parity report

**Deliverables:**
- `.github/workflows/parity.yml`

**Estimated tokens:** ~4,000

---

### Task 8.2.5: Parity Documentation

**Objective:** Document intentional differences.

**Steps:**
1. List known differences
2. Justify each difference
3. Mark implementation-defined behavior
4. Create compatibility guide
5. Update as differences found

**Deliverables:**
- `docs/PARITY.md`

**Estimated tokens:** ~3,000

---

### Review Checkpoint 8.2

**Verification:**
- [ ] Both runners work
- [ ] Results comparable
- [ ] CI automation works
- [ ] Differences documented
- [ ] Parity verified

---

## Phase 8.3: Edge Case Coverage

### Task 8.3.1: Unicode and Encoding Tests

**Objective:** Test Unicode handling.

**Steps:**
1. Test emoji in passages
2. Test RTL text
3. Test CJK characters
4. Test combining characters
5. Test encoding edge cases

**Deliverables:**
- 20+ Unicode test cases

**Estimated tokens:** ~4,000

---

### Task 8.3.2: Boundary Condition Tests

**Objective:** Test limits and boundaries.

**Steps:**
1. Test very long passages
2. Test deeply nested choices
3. Test large variable counts
4. Test expression depth limits
5. Test file size limits

**Deliverables:**
- 20+ boundary test cases

**Estimated tokens:** ~4,000

---

### Task 8.3.3: Race Condition Tests

**Objective:** Test async behavior.

**Steps:**
1. Test rapid state changes
2. Test concurrent saves
3. Test interrupted operations
4. Test recovery scenarios
5. Document async guarantees

**Code location:** `packages/story-player/src/tests/async.test.ts`

**Estimated tokens:** ~4,000

---

### Task 8.3.4: State Persistence Tests

**Objective:** Test save/load robustness.

**Steps:**
1. Test save format versions
2. Test corrupted save handling
3. Test migration scenarios
4. Test partial state restore
5. Test large state serialization

**Deliverables:**
- 20+ persistence test cases

**Estimated tokens:** ~4,000

---

### Review Checkpoint 8.3

**Verification:**
- [ ] Unicode tests pass
- [ ] Boundary tests pass
- [ ] Async tests pass
- [ ] Persistence tests pass
- [ ] Edge cases documented

---

## Phase 8.4: Performance Testing

### Task 8.4.1: Parser Benchmarks

**Objective:** Measure parser performance.

**Steps:**
1. Create benchmark suite
2. Measure parse time vs file size
3. Profile memory usage
4. Identify hotspots
5. Establish baselines

**Code locations:**
- `whisker-core/benchmarks/parser_bench.lua`
- `packages/parser/src/benchmarks/`

**Estimated tokens:** ~5,000

---

### Task 8.4.2: Runtime Benchmarks

**Objective:** Measure runtime performance.

**Steps:**
1. Benchmark passage navigation
2. Benchmark expression evaluation
3. Benchmark variable operations
4. Benchmark save/load
5. Establish baselines

**Code locations:**
- `whisker-core/benchmarks/runtime_bench.lua`
- `packages/story-player/src/benchmarks/`

**Estimated tokens:** ~5,000

---

### Task 8.4.3: Memory Profiling

**Objective:** Track memory usage.

**Steps:**
1. Profile story loading
2. Profile long-running sessions
3. Identify memory leaks
4. Optimize allocations
5. Document memory requirements

**Estimated tokens:** ~4,000

---

### Task 8.4.4: Performance CI

**Objective:** Track performance over time.

**Steps:**
1. Run benchmarks in CI
2. Track results over time
3. Alert on regressions
4. Generate performance graphs
5. Document baseline requirements

**Deliverables:**
- Performance tracking workflow

**Estimated tokens:** ~4,000

---

### Review Checkpoint 8.4

**Verification:**
- [ ] Parser benchmarks established
- [ ] Runtime benchmarks established
- [ ] Memory profiled
- [ ] CI tracking in place
- [ ] No regressions detected

---

## Phase 8.5: Fuzz Testing

### Task 8.5.1: Parser Fuzz Harness (Lua)

**Objective:** Fuzz test Lua parser.

**Steps:**
1. Create AFL/libFuzzer harness
2. Define input grammar
3. Run initial fuzzing
4. Triage crashes
5. Fix discovered bugs

**Code location:** `whisker-core/fuzz/parser_fuzz.lua`

**Estimated tokens:** ~5,000

---

### Task 8.5.2: Parser Fuzz Harness (TypeScript)

**Objective:** Fuzz test TypeScript parser.

**Steps:**
1. Set up js-fuzzer or similar
2. Create input generator
3. Run fuzzing campaigns
4. Triage issues
5. Fix discovered bugs

**Code location:** `packages/parser/src/fuzz/`

**Estimated tokens:** ~5,000

---

### Task 8.5.3: Expression Fuzzer

**Objective:** Fuzz expression evaluator.

**Steps:**
1. Create expression generator
2. Generate random expressions
3. Compare Lua vs TypeScript
4. Find divergences
5. Fix inconsistencies

**Code location:** `tools/expression-fuzzer/`

**Estimated tokens:** ~5,000

---

### Task 8.5.4: Corpus Generation

**Objective:** Generate test cases from fuzzing.

**Steps:**
1. Minimize crash cases
2. Convert to test corpus format
3. Document bug findings
4. Add regression tests
5. Update corpus

**Estimated tokens:** ~3,000

---

### Review Checkpoint 8.5 (Gap 8 Complete)

**Verification:**
- [ ] Corpus at 200+ tests
- [ ] Cross-platform parity verified
- [ ] Edge cases covered
- [ ] Performance benchmarked
- [ ] Fuzzing found no crashes

**Final metrics:**
| Metric | Before | After |
|--------|--------|-------|
| Test corpus size | 51 | 200+ |
| Feature coverage | ~70% | 95%+ |
| Cross-platform parity | Manual | Automated |
| Performance tracked | No | Yes |
| Fuzz testing | No | Yes |

**Test Categories Added:**
- `test-corpus/structure/` - 30+ tests
- `test-corpus/choices/` - 30+ tests
- `test-corpus/variables/` - 30+ tests
- `test-corpus/content/` - 30+ tests
- `test-corpus/errors/` - 50+ tests
- `test-corpus/unicode/` - 20+ tests
- `test-corpus/edge/` - 20+ tests

**Sign-off requirements:**
- Comprehensive test coverage
- Automated parity verification
- Performance baselines established
- Ready for Gap 9
