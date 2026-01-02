# Phase 4: Testing (WLS 1.1)

## Objective

Expand test coverage to 95%+ across all components with comprehensive test corpus.

## Current State

| Component | Current | Target |
|-----------|---------|--------|
| Lua Parser | 85% | 95% |
| TypeScript Parser | 95% | 98% |
| Validators | 80% | 95% |
| Runtime | 70% | 90% |
| Corpus Tests | 100 | 200+ |

## Test Categories

### 1. Unit Tests
Test individual functions and classes in isolation.

**TypeScript:**
```typescript
describe('parsePassage', () => {
  it('parses simple passage', () => {
    const result = parsePassage(':: Start\nHello world');
    expect(result.name).toBe('Start');
    expect(result.content).toContain('Hello world');
  });
});
```

**Lua:**
```lua
describe("parse_passage", function()
  it("parses simple passage", function()
    local result = parse_passage(":: Start\nHello world")
    assert.equals("Start", result.name)
    assert.matches("Hello world", result.content)
  end)
end)
```

### 2. Integration Tests
Test component interactions.

- Parser + Validator
- Parser + Runtime
- Import + Export round-trip
- CLI end-to-end

### 3. Corpus Tests
Standardized test cases that run on both platforms.

**Format:**
```yaml
- name: basic-story
  description: Simple story with one passage
  input: |
    :: Start
    Hello, world!
  expected:
    passages: 1
    valid: true

- name: variable-usage
  description: Variable assignment and interpolation
  input: |
    :: Start
    {do $name = "Alice"}
    Hello, $name!
  expected:
    passages: 1
    variables: ["name"]
    output_contains: "Hello, Alice!"
```

### 4. Regression Tests
Tests for previously fixed bugs.

### 5. Edge Case Tests
Tests for boundary conditions and unusual inputs.

## Implementation Steps

### Step 1: Test Infrastructure
Create shared test utilities:

```typescript
// packages/test-utils/src/index.ts
export function parseAndValidate(input: string): TestResult;
export function runStory(input: string, choices: number[]): StoryOutput;
export function compareWithLua(input: string): boolean;
```

### Step 2: Parser Test Expansion

**New test files:**
- `parser/edge-cases.test.ts`
- `parser/unicode.test.ts`
- `parser/whitespace.test.ts`
- `parser/error-recovery.test.ts`
- `parser/large-files.test.ts`

**Coverage targets:**
- Every grammar rule tested
- Error cases for each rule
- Unicode in all positions
- Whitespace variations

### Step 3: Runtime Test Expansion

**New test files:**
- `runtime/choice-selection.test.ts`
- `runtime/variable-scoping.test.ts`
- `runtime/save-restore.test.ts`
- `runtime/special-passages.test.ts`
- `runtime/performance.test.ts`

**Coverage targets:**
- All runtime state transitions
- Save/load cycle
- Memory limits
- Concurrent operations

### Step 4: Validator Test Expansion

**New test files:**
- `validators/all-error-codes.test.ts`
- `validators/false-positives.test.ts`
- `validators/performance.test.ts`

**Coverage targets:**
- Every error code triggered
- No false positives on valid stories
- Performance on large stories

### Step 5: Corpus Expansion

**New corpus categories:**
```
test-corpus/
├── basic/              # Fundamental features (50+ tests)
├── advanced/           # Complex features (30+ tests)
├── edge-cases/         # Boundary conditions (30+ tests)
├── validation/         # Error detection (50+ tests)
├── import/             # Import format tests (20+ tests)
├── export/             # Export format tests (20+ tests)
└── regression/         # Bug fixes (varies)
```

### Step 6: Coverage Tooling

**TypeScript:**
```bash
pnpm test -- --coverage
# Generate HTML report
pnpm test -- --coverage --reporter=html
```

**Lua:**
```bash
busted --coverage
# Generate LuaCov report
luacov
```

**CI Integration:**
```yaml
- name: Check coverage
  run: |
    pnpm test -- --coverage
    if [ $(jq '.total.lines.pct' coverage/coverage-summary.json) -lt 95 ]; then
      echo "Coverage below 95%"
      exit 1
    fi
```

## Key Files

**TypeScript:**
- `packages/*/src/**/*.test.ts`
- `packages/test-utils/` (new)
- `vitest.config.ts`

**Lua:**
- `spec/**/*_spec.lua`
- `spec/helpers/`
- `.busted`

**Corpus:**
- `phase-4-validation/test-corpus/**/*.yaml`
- `phase-4-validation/tools/run-corpus.ts`
- `phase-4-validation/tools/run-corpus.lua`

## Test Naming Convention

```
{component}-{feature}-{scenario}.test.ts
```

Examples:
- `parser-passage-unicode-names.test.ts`
- `validator-deadlink-special-targets.test.ts`
- `runtime-variables-scoping-temp.test.ts`
