# Whisker Language Specification - Implementation Context

## Repository

```
~/code/github.com/whisker-language-specification-1.0
```

## Overview

Contains the formal WLS specification, canonical examples, and cross-platform test corpus.

## Directory Structure

```
whisker-language-specification-1.0/
├── phase-1-specification/
│   ├── spec/                   # Formal specification
│   │   ├── 01-INTRODUCTION.md
│   │   ├── 02-FLOW-CONTROL.md
│   │   ├── 03-DATA-STRUCTURES.md
│   │   ├── 04-MODULARITY.md
│   │   ├── 05-PRESENTATION.md
│   │   └── ...
│   └── examples/               # Canonical examples
│       ├── basic/
│       ├── intermediate/
│       └── advanced/
├── phase-4-validation/
│   ├── test-corpus/            # Cross-platform tests
│   │   ├── basic/
│   │   ├── advanced/
│   │   ├── validation/
│   │   └── ...
│   └── tools/                  # Test runners
│       ├── run-corpus.sh
│       ├── run-corpus.ts
│       └── run-corpus.lua
├── implementation-plan/        # Gap analysis and plans
│   ├── 00-OVERVIEW.md
│   ├── 01-PARSER-COMPLETENESS.md
│   └── ...
├── wls-implementation-plan/    # This consolidated plan
│   ├── README.md
│   ├── CLAUDE.md
│   ├── phases/
│   └── repos/
└── docs/                       # Additional documentation
```

## Specification Format

Each spec document follows this structure:

```markdown
# [Feature Name]

## Overview
[Brief description]

## Syntax
[Formal syntax with examples]

## Semantics
[Behavior description]

## Examples
[Code examples]

## Implementation Notes
[Cross-platform considerations]
```

## Test Corpus Format

```yaml
# test-corpus/category/test-name.yaml
- name: test-identifier
  description: What this test verifies
  input: |
    :: Start
    Story content here
  expected:
    passages: 1
    valid: true
    # Additional assertions
```

### Validation Tests
```yaml
- name: val-missing-start
  input: |
    :: NotStart
    Content
  expected:
    valid: false
    errors:
      - code: WLS-STR-001
        severity: error
```

### Runtime Tests
```yaml
- name: runtime-choice
  input: |
    :: Start
    + [Option A] -> A
    + [Option B] -> B
    :: A
    You chose A
    :: B
    You chose B
  expected:
    choices: 2
    play:
      - choose: 0
        output_contains: "You chose A"
```

## Running Corpus Tests

```bash
cd phase-4-validation

# Run all tests on both platforms
./tools/run-corpus.sh

# TypeScript only
./tools/run-corpus.sh --platform=typescript

# Lua only
./tools/run-corpus.sh --platform=lua

# Specific category
./tools/run-corpus.sh --category=validation

# Compare outputs
./tools/compare-platforms.sh
```

## Adding Specification Content

1. Identify the appropriate spec file in `phase-1-specification/spec/`
2. Add or update the section
3. Add canonical example in `phase-1-specification/examples/`
4. Add test cases in `phase-4-validation/test-corpus/`

## Phase-Specific Notes

### Phase 1: Validation
Create:
- `phase-1-specification/spec/11-VALIDATION.md` - Error code specification
- `phase-4-validation/test-corpus/validation/` - 50+ validation tests

### Phase 2: Flow Control
Update:
- `phase-1-specification/spec/02-FLOW-CONTROL.md` - Gather/tunnel syntax
- Add examples in `phase-1-specification/examples/`
- Add tests in `phase-4-validation/test-corpus/flow-control/`

### Phase 3: Tooling
Add:
- Format conversion specification
- Import/export test files
- Sample files for each format

### Phase 4: Testing
Expand:
- All corpus categories
- Target 200+ test cases
- Coverage of all features

### Phase 5: Documentation
Build:
- Documentation site
- Link to specification
- API references

### Phase 6: WLS 2.0
Major updates:
- New spec documents for 2.0 features
- Migration specification
- Breaking change documentation

## Cross-Platform Verification

The test corpus ensures both implementations behave identically:

1. Each test case defines expected behavior
2. TypeScript runner executes and checks
3. Lua runner executes and checks
4. Compare script verifies parity

Any behavioral difference is a bug in one implementation.
