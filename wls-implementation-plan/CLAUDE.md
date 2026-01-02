# WLS Implementation Context

## Project Overview

WLS (Whisker Language Specification) is an interactive fiction language with:
- **Lua implementation** in `whisker-core`
- **TypeScript implementation** in `whisker-editor-web`
- **Specification and tests** in `whisker-language-specification-1.0`

## Cross-Platform Parity

**Critical requirement**: Both implementations must produce identical behavior.

- Same error codes and messages
- Same parsing results
- Same runtime behavior
- Verified via shared test corpus

## Repository Locations

```
~/code/github.com/writewhisker/whisker-core
~/code/github.com/writewhisker/whisker-editor-web
~/code/github.com/whisker-language-specification-1.0
```

## Implementation Order

Always implement in this order:
1. **Specification** - Define behavior in spec/ documents
2. **Test corpus** - Add tests in phase-4-validation/test-corpus/
3. **TypeScript** - Implement in whisker-editor-web
4. **Lua** - Implement in whisker-core
5. **Verify** - Run cross-platform tests

## Key Patterns

### TypeScript (whisker-editor-web)

Validators in `packages/story-validation/src/validators/`:
```typescript
export class MyValidator implements StoryValidator {
  validate(story: Story): ValidationResult[] {
    // Return array of validation errors
  }
}
```

Parser in `packages/parser/`:
```typescript
// Uses PEG.js grammar in src/whisker.pegjs
```

### Lua (whisker-core)

Validators in `lib/whisker/validators/`:
```lua
local M = {}
function M.validate(story)
  local errors = {}
  -- Add errors to table
  return errors
end
return M
```

Parser in `lib/whisker/parser/`:
```lua
-- Hand-written recursive descent parser
local ws_parser = require("whisker.parser.ws_parser")
```

## Error Code Format

```
WLS-{CATEGORY}-{NUMBER}
```

Categories: STR, LNK, VAR, EXP, TYP, FLW, QUA

Example:
```
WLS-STR-001: missing_start_passage
WLS-LNK-001: dead_link
WLS-VAR-001: undefined_variable
```

## Test Corpus Format

```yaml
- name: test-name
  input: |
    :: Start
    Hello world
  expected:
    passages: 1
    errors: []
```

For validation tests:
```yaml
- name: val-dead-link
  input: |
    :: Start
    + [Go] -> NonExistent
  expected:
    errors:
      - code: WLS-LNK-001
        severity: error
        message: "Dead link to 'NonExistent'"
```

## Running Tests

TypeScript:
```bash
cd ~/code/github.com/writewhisker/whisker-editor-web
pnpm test
pnpm --filter @writewhisker/story-validation test
```

Lua:
```bash
cd ~/code/github.com/writewhisker/whisker-core
busted
```

Cross-platform:
```bash
cd ~/code/github.com/whisker-language-specification-1.0/phase-4-validation
./run-corpus.sh
```

## Commit Guidelines

- Prefix commits with affected component: `[parser]`, `[validation]`, `[runtime]`
- Reference WLS error codes when fixing validation issues
- Include test cases with all changes
- Update specification if behavior changes

## Phase-Specific Notes

### Phase 1: Validation
- Focus on error codes and messages
- TypeScript has partial implementation to extend
- Lua needs new validator module

### Phase 2: Flow Control
- Gather points use `-` prefix
- Tunnels use `->->` for return
- Requires runtime call stack

### Phase 3: Tooling
- Twine import is highest priority
- Use existing parser infrastructure
- Export builds on story models

### Phase 4: Testing
- Target 95% coverage
- Prioritize edge cases
- Add corpus tests for all features

### Phase 5: Documentation
- API docs use TypeDoc/LDoc
- Tutorials target beginners
- Migration guides for each format

### Phase 6: WLS 2.0
- Breaking changes allowed
- Threads are highest complexity
- Build migration tools first

---

# Stage Execution Protocol

When asked to "execute stage X.XX" or "execute phase X", follow these instructions.

## Command Reference

| Command | Action |
|---------|--------|
| `execute stage 2.13` | Execute single stage 2.13 |
| `execute phase 2 remaining` | Execute all incomplete Phase 2 stages |
| `execute group E` | Execute parallel group E (3.11, 3.12, 3.13, 3.16) |

## Execution Steps

### 1. Read the Stage File

Stage files are in `wls-implementation-plan/phases/<phase>/stages/`:
```
01-validation/stages/1.XX-*.md
02-flow-control/stages/2.XX-*.md
03-tooling/stages/3.XX-*.md
04-testing/stages/4.XX-*.md
05-documentation/stages/5.XX-*.md
06-wls-2.0/stages/6.XX-*.md
```

### 2. Determine Repository

| Stage | Repository |
|-------|------------|
| 1.01-1.05, 1.20-1.22 | whisker-language-specification-1.0 |
| 1.06-1.13, 2.04-2.10, 3.01-3.17 | whisker-editor-web |
| 1.14-1.19, 2.11-2.14 | whisker-core |
| 2.01-2.03, 2.15 | whisker-language-specification-1.0 |

### 3. Create Feature Branch

```bash
cd <repository>
git fetch origin && git checkout main && git pull origin main
git checkout -b feature/wls-stage-X.XX
```

### 4. Implement the Stage

Read the "Prompt" section and implement exactly what it describes:
- Create/modify files from "Files to Create/Modify"
- Write tests as specified
- Follow patterns shown in the prompt

### 5. Run Verification

**TypeScript:**
```bash
pnpm lint && pnpm typecheck && pnpm test -- --run
```

**Lua:**
```bash
luacheck . && busted
```

### 6. Check Success Criteria

Verify ALL items in "Success Criteria" are satisfied.

### 7. Commit

```bash
git add -A
git commit -m "$(cat <<'EOF'
feat(<scope>): implement stage X.XX - <description>

<changes>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### 8. Push and Create PR

```bash
git push -u origin feature/wls-stage-X.XX
gh pr create --title "Stage X.XX: <Title>" --body "## Summary
<objective>

## Changes
- <changes>

## Testing
- [x] Local tests pass

## Success Criteria
<criteria>

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
```

### 9. Report

```
Stage X.XX complete.
PR: <url>
Tests: PASS
Success Criteria: ALL MET
```

## Parallel Execution Groups

These stages can run simultaneously in separate terminal windows:

| Group | Stages | Prerequisite |
|-------|--------|--------------|
| E | 3.11, 3.12, 3.13, 3.16 | After 3.10 |
| F | 3.14, 3.15, 3.17 | After Group E |
| Lua Flow | 2.13, 2.14 | After 1.19 (sequential) |

## Failure Handling

**Test failure:** Fix code, re-run tests.
**CI failure:** `gh run view <id> --log-failed`, fix, push.
**Merge conflict:** `git rebase origin/main`, resolve, `git push --force-with-lease`
