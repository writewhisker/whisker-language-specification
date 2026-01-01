# Gap 8: Test Coverage

## Context

Expand test corpus, implement cross-platform parity testing, and add fuzzing.

## Repositories

- **whisker-core**: `/Users/jims/code/github.com/writewhisker/whisker-core`
- **whisker-editor-web**: `/Users/jims/code/github.com/writewhisker/whisker-editor-web`
- **specification**: `/Users/jims/code/github.com/whisker-language-specification-1.0`

## Current State

| Repository | Unit Tests | Corpus Tests | Coverage |
|------------|------------|--------------|----------|
| whisker-core | ~150 | 51 | ~70% |
| whisker-editor-web | ~300 | 51 | ~85% |

## Target State

| Repository | Unit Tests | Corpus Tests | Coverage |
|------------|------------|--------------|----------|
| whisker-core | 300+ | 200+ | 95%+ |
| whisker-editor-web | 500+ | 200+ | 95%+ |

## Test Corpus Structure

```
test-corpus/
├── structure/          # Passage headers, tags, metadata
├── choices/            # Choice syntax, conditions, actions
├── variables/          # Declarations, types, scope
├── content/            # Shuffles, sequences, conditionals
├── errors/             # Expected error cases
├── unicode/            # Emoji, RTL, CJK
├── edge/               # Boundary conditions, limits
└── validation/         # Each error code
```

## Key Files to Create/Modify

### Test Corpus (specification)
- `test-corpus/structure/*.yaml` - 30+ tests
- `test-corpus/choices/*.yaml` - 30+ tests
- `test-corpus/variables/*.yaml` - 30+ tests
- `test-corpus/content/*.yaml` - 30+ tests
- `test-corpus/errors/*.yaml` - 50+ tests

### Corpus Runners
- `whisker-core/tests/corpus_runner.lua`
- `packages/parser/src/tests/corpusRunner.ts`

### Parity Tools
- `tools/compare-results.js` - Compare Lua vs TypeScript results
- `.github/workflows/parity.yml` - CI automation

## Commands

```bash
# Run Lua corpus
cd /Users/jims/code/github.com/writewhisker/whisker-core
lua tests/corpus_runner.lua

# Run TypeScript corpus
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/parser test:corpus

# Compare results
cd /Users/jims/code/github.com/whisker-language-specification-1.0
node tools/compare-results.js

# Run benchmarks
cd /Users/jims/code/github.com/writewhisker/whisker-core
lua benchmarks/parser_bench.lua
```

## Test Case Format

```yaml
- name: choice-with-condition
  description: Choice with conditional display
  input: |
    :: Start
    {hasKey = true}
    + {hasKey} [Open door] -> Room
    + [Look around] -> Start
  expected:
    passages: 1
    choices: 2
    variables: [hasKey]
```

## Parity Testing

1. Run both corpus runners
2. Output standardized JSON results
3. Compare with diff tool
4. Report any behavioral differences
5. Document intentional differences

## Fuzzing

- Parser fuzz harness (Lua + TypeScript)
- Expression evaluator fuzzer
- Generate test cases from crashes
- Add regression tests

## Success Criteria

- Corpus at 200+ tests
- All tests pass on both platforms
- No parity differences (or documented)
- Benchmarks established
- No fuzzer crashes
