# Running the Implementation Plan

This guide explains how to execute each stage of the WLS implementation plan.

## Overview

The implementation follows a hierarchical structure:

```
Gap (9 total)
└── Phase (4-6 per gap)
    └── Task (3-5 per phase)
        └── Review Checkpoint (end of each phase)
```

## Prerequisites

### Repository Setup

Ensure all repositories are cloned and accessible:

```bash
# Verify repositories exist
ls -la /Users/jims/code/github.com/writewhisker/whisker-core
ls -la /Users/jims/code/github.com/writewhisker/whisker-editor-web
ls -la /Users/jims/code/github.com/whisker-language-specification-1.0
```

### Dependencies

```bash
# whisker-core (Lua)
cd /Users/jims/code/github.com/writewhisker/whisker-core
# Requires: Lua 5.4+, busted (test framework)

# whisker-editor-web (TypeScript)
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm install
```

---

## Starting a Gap

### Step 1: Read the Context

```bash
# Read the CLAUDE.md for quick orientation
cat /Users/jims/code/github.com/whisker-language-specification-1.0/implementation-plan/gap-01/CLAUDE.md

# Read the full plan for detailed tasks
cat /Users/jims/code/github.com/whisker-language-specification-1.0/implementation-plan/01-PARSER-COMPLETENESS.md
```

### Step 2: Create a Feature Branch

```bash
# In each affected repository
cd /Users/jims/code/github.com/writewhisker/whisker-core
git checkout -b feature/gap-01-parser-completeness

cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
git checkout -b feature/gap-01-parser-completeness
```

### Step 3: Set Up Tracking

Create a STATUS.md file or use the todo list to track progress through phases.

---

## Running a Phase

Each phase contains 3-5 tasks that build on each other.

### Phase Workflow

1. **Read the phase objectives** from the gap plan file
2. **Work through each task** sequentially
3. **Run tests after each task** to verify correctness
4. **Complete the review checkpoint** before moving to next phase

### Example: Gap 1, Phase 1.1 (Parser Audit)

```bash
# Task 1.1.1: Document current Lua parser state
cd /Users/jims/code/github.com/writewhisker/whisker-core
# Review lib/whisker/parser/ws_parser.lua
# Document supported vs unsupported features

# Task 1.1.2: Compare with TypeScript parser
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
# Review packages/parser/src/parser.ts
# Create comparison document

# Task 1.1.3: Identify gaps
# Create prioritized list of missing features

# Task 1.1.4: Create tracking issues
# Document each gap as a trackable item
```

---

## Running Tests

### Lua Tests (whisker-core)

```bash
cd /Users/jims/code/github.com/writewhisker/whisker-core

# Run all tests
busted

# Run specific test file
busted tests/wls/test_parser.lua

# Run tests matching pattern
busted --filter="lexer"

# Run with verbose output
busted --verbose
```

### TypeScript Tests (whisker-editor-web)

```bash
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web

# Run all tests
pnpm test

# Run specific package tests
pnpm --filter @writewhisker/parser test -- --run
pnpm --filter @writewhisker/story-player test -- --run
pnpm --filter @writewhisker/story-validation test -- --run

# Run tests in watch mode
pnpm --filter @writewhisker/parser test

# Run single test file
pnpm --filter @writewhisker/parser test -- --run src/parser.test.ts
```

### Corpus Tests

```bash
cd /Users/jims/code/github.com/whisker-language-specification-1.0

# Run corpus tests (when runners are implemented)
# Lua
cd /Users/jims/code/github.com/writewhisker/whisker-core
lua tests/corpus_runner.lua

# TypeScript
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/parser test:corpus
```

---

## Review Checkpoints

At the end of each phase, verify all criteria are met:

### Checkpoint Checklist

1. **All tasks complete** - Every task in the phase is done
2. **Tests pass** - Both Lua and TypeScript tests pass
3. **Parity verified** - Behavior matches between platforms
4. **Documentation updated** - Spec/docs reflect changes
5. **No regressions** - Existing functionality still works

### Running Checkpoint Verification

```bash
# Run full test suite in both repos
cd /Users/jims/code/github.com/writewhisker/whisker-core
busted

cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm test -- --run

# Run corpus parity check (when available)
cd /Users/jims/code/github.com/whisker-language-specification-1.0
node tools/compare-results.js
```

---

## Gap-Specific Commands

### Gap 1: Parser Completeness

```bash
# Lua parser tests
cd /Users/jims/code/github.com/writewhisker/whisker-core
busted tests/wls/test_lexer.lua
busted tests/wls/test_parser.lua

# TypeScript parser tests
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/parser test -- --run
```

### Gap 2: Advanced Flow Control

```bash
# Test flow control
cd /Users/jims/code/github.com/writewhisker/whisker-core
busted tests/wls/test_flow.lua

cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/parser test -- --run
pnpm --filter @writewhisker/story-player test -- --run
```

### Gap 3: Data Structures

```bash
# Test variables and collections
cd /Users/jims/code/github.com/writewhisker/whisker-core
busted tests/wls/test_variables.lua

cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/scripting test -- --run
pnpm --filter @writewhisker/story-player test -- --run
```

### Gap 4: Modularity

```bash
# Test modules and includes
cd /Users/jims/code/github.com/writewhisker/whisker-core
busted tests/wls/test_modules.lua

cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/import test -- --run
```

### Gap 5: Presentation Layer

```bash
# Test rendering
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/story-player test -- --run
pnpm --filter @writewhisker/player-ui test -- --run
```

### Gap 6: Developer Experience

```bash
# Test LSP (when implemented)
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter whisker-lsp test -- --run

# Test CLI tools
cd /Users/jims/code/github.com/writewhisker/whisker-core
lua bin/whisker-lint --help
lua bin/whisker-fmt --help
```

### Gap 7: Tooling

```bash
# Test import/export
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/import test -- --run
pnpm --filter @writewhisker/export test -- --run
```

### Gap 8: Test Coverage

```bash
# Run corpus tests
cd /Users/jims/code/github.com/writewhisker/whisker-core
lua tests/corpus_runner.lua

cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/parser test:corpus

# Compare results
cd /Users/jims/code/github.com/whisker-language-specification-1.0
node tools/compare-results.js

# Run benchmarks
cd /Users/jims/code/github.com/writewhisker/whisker-core
lua benchmarks/parser_bench.lua
```

### Gap 9: Documentation

```bash
# Generate API docs
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm typedoc

cd /Users/jims/code/github.com/writewhisker/whisker-core
ldoc lib/

# Build documentation site
cd /Users/jims/code/github.com/whisker-language-specification-1.0/docs
npm run build
npm run preview
```

---

## Completing a Gap

### Step 1: Final Verification

```bash
# Run all tests
cd /Users/jims/code/github.com/writewhisker/whisker-core
busted

cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm test -- --run
```

### Step 2: Create Pull Requests

```bash
# whisker-core
cd /Users/jims/code/github.com/writewhisker/whisker-core
git add .
git commit -m "feat: implement Gap X - [Description]"
git push -u origin feature/gap-0X-name
gh pr create --title "Gap X: [Title]" --body "..."

# whisker-editor-web
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
git add .
git commit -m "feat: implement Gap X - [Description]"
git push -u origin feature/gap-0X-name
gh pr create --title "Gap X: [Title]" --body "..."
```

### Step 3: Update Specification

```bash
# If spec changes were made
cd /Users/jims/code/github.com/whisker-language-specification-1.0
git add .
git commit -m "docs: update spec for Gap X"
git push
```

### Step 4: Update Status

Mark the gap as complete in tracking documentation.

---

## Quick Reference

| Action | Command |
|--------|---------|
| Run Lua tests | `busted` |
| Run TS tests | `pnpm test -- --run` |
| Run single package | `pnpm --filter @writewhisker/parser test -- --run` |
| Watch mode | `pnpm --filter @writewhisker/parser test` |
| Corpus tests | `lua tests/corpus_runner.lua` |
| Create PR | `gh pr create` |

## Troubleshooting

### Lua Tests Failing

```bash
# Check Lua version
lua -v

# Reinstall busted
luarocks install busted

# Run with debug output
busted --verbose --output=TAP
```

### TypeScript Tests Failing

```bash
# Clear cache and reinstall
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
rm -rf node_modules
pnpm install

# Run with verbose output
pnpm --filter @writewhisker/parser test -- --run --reporter=verbose
```

### Parity Issues

```bash
# Generate detailed comparison
cd /Users/jims/code/github.com/whisker-language-specification-1.0
node tools/compare-results.js --verbose > parity-report.txt
```
