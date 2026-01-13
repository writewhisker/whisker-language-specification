# Edge Cases Test Corpus

This directory contains test cases for edge cases and boundary conditions in WLS parsing and validation.

## Test Files

### unicode-edge-cases.yaml
Tests for Unicode character handling:
- Emoji (including ZWJ sequences)
- Right-to-left text (Arabic, Hebrew)
- Combining characters and diacritical marks
- CJK characters (Chinese, Japanese, Korean)
- Mathematical and currency symbols
- Special Unicode characters (BOM, zero-width, etc.)

### whitespace-edge-cases.yaml
Tests for whitespace handling:
- Leading/trailing whitespace
- Tab and space handling
- Line ending variations (LF, CRLF, CR)
- Blank lines and empty content
- Indentation edge cases
- Special whitespace characters (NBSP, em-space, etc.)

### nesting-limits.yaml
Tests for deeply nested structures:
- Choice nesting (up to 10 levels)
- Conditional nesting
- Expression nesting
- Alternative sequences
- Tunnel chains
- Namespace nesting
- Mixed deep nesting scenarios

### empty-elements.yaml
Tests for empty or minimal elements:
- Empty passages
- Empty choices
- Empty content blocks
- Empty declarations (LIST, ARRAY, MAP)
- Empty functions and namespaces
- Minimal valid files
- Empty interpolations

## Running Tests

### TypeScript
```bash
pnpm test:corpus
```

### Lua
```bash
busted --tags=corpus
```

## Adding New Tests

Each test case should include:
- `id`: Unique identifier
- `description`: What the test verifies
- `input`: WLS source code
- `expected`: Expected parsing/validation results

Example:
```yaml
- id: example_test
  description: Description of what this tests
  input: |
    :: Start
    Content
  expected:
    valid: true
    passages: 1
```
