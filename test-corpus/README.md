# WLS Test Corpus

This directory contains the official test corpus for validating WLS implementations.

## Structure

```
test-corpus/
├── advanced/        # Advanced feature tests
├── alternatives/    # Text alternative tests
├── api/             # Lua API tests
├── basic/           # Basic functionality tests
├── choices/         # Choice system tests
├── conditionals/    # Control flow tests
├── edge-cases/      # Boundary and edge case tests
├── error-handling/  # Error handling tests
├── export/          # Export format tests
├── flow-control/    # Flow control tests
├── formats/         # File format tests
├── import/          # Import system tests
├── integration/     # Integration tests
├── parser/          # Parser-specific tests
├── performance/     # Performance benchmark tests
├── regression/      # Regression tests
├── runtime/         # Runtime behavior tests
├── syntax/          # Lexical and syntactic tests
├── unicode/         # Unicode handling tests
├── validation/      # Semantic validation tests
├── variables/       # Variable system tests
└── wls-2.0/         # Advanced WLS features (historical name)
```

## Test Format

Each test file uses YAML format:

```yaml
name: test-name
description: What this test validates
category: category-name
input: |
  :: Start
  Test content...
expected:
  passages: 1
  output: "Expected output text"
  variables:
    gold: 100
  error: null  # or error message for error tests
```

## Running Tests

Implementations should:

1. Parse the `input` field as a Whisker story
2. Execute from the start passage
3. Compare results against `expected` fields
4. Report pass/fail for each test

## Test Categories

| Category | Description |
|----------|-------------|
| advanced | Advanced feature combinations |
| alternatives | Sequence, cycle, shuffle, once-only |
| api | Lua API function tests |
| basic | Basic functionality tests |
| choices | Choice types, conditions, actions |
| conditionals | Block/inline conditionals, nesting |
| edge-cases | Boundary conditions, limits |
| error-handling | Error reporting and recovery |
| export | Export format tests |
| flow-control | Flow control and navigation |
| formats | Text and JSON format tests |
| import | Import system tests |
| integration | Cross-feature integration tests |
| parser | Parser-specific edge cases |
| performance | Performance benchmarks |
| regression | Regression tests for fixed bugs |
| runtime | Runtime behavior tests |
| syntax | Lexical structure, tokens, parsing |
| unicode | Unicode handling tests |
| validation | Semantic validation tests |
| variables | Variable declaration, types, scope |
| wls-2.0 | Advanced features (threads, state machines, etc.) |

**Total Categories**: 22

## Conformance

An implementation is conformant if it passes all non-error tests and correctly rejects all error tests with appropriate error messages.

## Historical Directory Names

The `wls-2.0/` directory name is historical and reflects the directory structure from earlier development. WLS is now a **unified specification** with no version distinctions. The tests in `wls-2.0/` cover advanced features (threads, state machines, timed content, external functions, effects, parameterized passages, audio, and migration) that are all part of the single WLS specification.
