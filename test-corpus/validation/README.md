# WLS Validation Test Corpus

This directory contains tests for semantic validation of WLS stories. These tests verify that both TypeScript (whisker-editor-web) and Lua (whisker-core) validators produce consistent results.

## Test Files

| File | Description | Error Codes |
|------|-------------|-------------|
| `structural-tests.yaml` | Passage structure validation | WLS-STR-001 to WLS-STR-004 |
| `links-tests.yaml` | Choice link validation | WLS-LNK-001 to WLS-LNK-005 |
| `variables-tests.yaml` | Variable usage validation | WLS-VAR-001 to WLS-VAR-003 |
| `flow-tests.yaml` | Story flow validation | WLS-FLW-001 |
| `combined-tests.yaml` | Multiple validation issues | Mixed |

## Test Format

```yaml
tests:
  - name: val-str-001-missing-start
    description: Story with no Start passage
    input: |
      :: NotStart
      This is not the start.
    expected:
      valid: true        # Parse validity
      passages: 1        # Number of passages
    validation:
      errors:            # Expected error issues
        - code: WLS-STR-001
          severity: error
      warnings: []       # Expected warning issues
      info: []           # Expected info issues
```

## Error Codes Tested

### Structure (STR)
- **WLS-STR-001**: Missing start passage
- **WLS-STR-002**: Unreachable passage
- **WLS-STR-003**: Duplicate passage names
- **WLS-STR-004**: Empty passage

### Links (LNK)
- **WLS-LNK-001**: Dead link (target doesn't exist)
- **WLS-LNK-002**: Self-link without state change
- **WLS-LNK-003**: Special target wrong case
- **WLS-LNK-004**: BACK on start passage
- **WLS-LNK-005**: Empty choice target

### Variables (VAR)
- **WLS-VAR-001**: Undefined variable
- **WLS-VAR-002**: Unused variable
- **WLS-VAR-003**: Invalid variable name

### Flow (FLW)
- **WLS-FLW-001**: Dead end (no choices)

## Running Tests

### TypeScript (whisker-editor-web)
```bash
pnpm --filter @writewhisker/story-validation test
```

### Lua (whisker-core)
```bash
lua tools/validation-corpus-runner.lua
```

## Test Count

| Category | Tests |
|----------|-------|
| Structural | 13 |
| Links | 17 |
| Variables | 11 |
| Flow | 5 |
| Combined | 5 |
| **Total** | **51** |
