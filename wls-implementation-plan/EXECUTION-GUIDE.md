# WLS Stage Execution Guide

## Overview

This guide explains how to execute each stage to ensure complete, verified implementation.

## Pre-requisites

### Environment Setup

```bash
# Required tools
node --version    # v18+
pnpm --version    # v8+
lua -v            # Lua 5.4
busted --version  # Lua test framework
gh --version      # GitHub CLI

# Repository locations
export WLS_SPEC=~/code/github.com/whisker-language-specification-1.0
export WLS_TS=~/code/github.com/writewhisker/whisker-editor-web
export WLS_LUA=~/code/github.com/writewhisker/whisker-core

# Ensure all repos are up to date
cd $WLS_SPEC && git pull origin main
cd $WLS_TS && git pull origin main
cd $WLS_LUA && git pull origin main
```

### Dependency Check

Before starting any phase, verify dependencies are complete:

```bash
# Check Phase 1 complete before Phase 2
cd $WLS_TS && pnpm --filter @writewhisker/story-validation test -- --run
cd $WLS_LUA && busted spec/validators/

# Check Phase 2 complete before Phase 3
cd $WLS_TS && pnpm --filter @writewhisker/story-player test -- --run
cd $WLS_LUA && busted spec/runtime/
```

### Automation Setup

Add the scripts to your PATH:

```bash
# Add to ~/.bashrc or ~/.zshrc
export WLS_SPEC=~/code/github.com/whisker-language-specification-1.0
export PATH="$WLS_SPEC/wls-implementation-plan/scripts:$PATH"

# Reload
source ~/.bashrc  # or ~/.zshrc
```

---

## Automated Execution (Recommended)

### Execute a Single Stage

```bash
claude-wls stage 2.13
```

This will:
1. Change to the correct repository
2. Launch Claude Code with the stage instructions
3. Claude will create branch, implement, test, commit, and create PR

### Execute Parallel Group

```bash
claude-wls group E
```

This shows which stages can run in parallel. Open N terminal windows:

```
Window 1: cd ~/code/.../whisker-editor-web && claude-wls stage 3.11
Window 2: cd ~/code/.../whisker-editor-web && claude-wls stage 3.12
Window 3: cd ~/code/.../whisker-editor-web && claude-wls stage 3.13
Window 4: cd ~/code/.../whisker-editor-web && claude-wls stage 3.16
```

### List Phase Stages

```bash
claude-wls phase 3
```

Shows all stages in Phase 3 so you can pick which to execute.

---

## Manual Stage Execution Process

### Step 1: Read the Stage File

```bash
# Example for stage 2.13
cat $WLS_SPEC/wls-implementation-plan/phases/02-flow-control/stages/2.13-lua-gather-runtime.md
```

Note these sections:
- **Objective**: What this stage accomplishes
- **Dependencies**: What must be done first
- **Files to Create/Modify**: Scope of changes
- **Prompt**: The implementation instructions
- **Verification**: How to test
- **Success Criteria**: Checklist for completion

### Step 2: Create Feature Branch

```bash
STAGE="2.13"
PHASE="flow-control"
REPO=$WLS_LUA  # Determine from stage file

cd $REPO
git fetch origin
git checkout main
git pull origin main
git checkout -b feature/wls-stage-${STAGE}
```

### Step 3: Execute the Prompt

Open Claude Code in the repository and provide the prompt from the stage file:

```bash
cd $REPO
claude
```

Then paste the prompt content. Claude will implement the changes.

### Step 4: Verify Implementation

Run the verification commands from the stage file:

```bash
# Example for Lua stage
busted spec/runtime/gather_spec.lua

# Example for TypeScript stage
pnpm --filter @writewhisker/story-player test -- --run
```

### Step 5: Check Success Criteria

Go through each success criterion manually:

```markdown
## Success Criteria (from stage file)
- [x] Single-level gathers work correctly
- [x] Nested gathers (- -, - - -) work correctly
- [x] Content after gather is rendered
- [x] Choice branches reconverge properly
```

If any criterion fails, fix before proceeding.

### Step 6: Run Full Test Suite

```bash
# TypeScript repo
cd $WLS_TS
pnpm lint
pnpm typecheck
pnpm test

# Lua repo
cd $WLS_LUA
luacheck .
busted
```

### Step 7: Commit Changes

```bash
git add -A
git status  # Review changes

git commit -m "$(cat <<'EOF'
feat(flow-control): implement stage 2.13 - Lua gather runtime

- Add gather point handling to Lua player
- Track choice depth for nested gathers
- Render content after gather reconvergence

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### Step 8: Push and Create PR

```bash
git push -u origin feature/wls-stage-${STAGE}

gh pr create --title "Stage ${STAGE}: Lua Gather Runtime" --body "$(cat <<'EOF'
## Summary
Implement gather point execution in Lua runtime.

## Changes
- Added gather handling to player.lua
- Track choice depth for nested gathers
- Content after gather point is rendered

## Testing
- [x] Local tests pass (`busted spec/runtime/gather_spec.lua`)
- [ ] GitHub Actions pass

## Success Criteria
- [x] Single-level gathers work correctly
- [x] Nested gathers work correctly
- [x] Content after gather is rendered
- [x] Choice branches reconverge properly

## Stage Dependencies
- Depends on: 2.12 (Lua parser)
- Enables: 2.14 (Lua tunnel runtime)
EOF
)"
```

### Step 9: Wait for CI

```bash
# Watch CI status
gh pr checks --watch

# Or check status periodically
gh pr checks
```

### Step 10: Merge PR

Only after CI passes:

```bash
gh pr merge --squash --delete-branch
```

### Step 11: Update Local Main

```bash
git checkout main
git pull origin main
```

---

## Handling Failures

### Test Failures

```bash
# If tests fail, don't commit. Fix first.
pnpm test -- --run  # See which tests fail

# Ask Claude to fix
claude
> The test XYZ is failing with error ABC. Please fix.

# Re-run tests
pnpm test -- --run

# Once passing, continue with commit
```

### CI Failures

```bash
# Check what failed
gh pr checks
gh run view <run-id> --log-failed

# Fix locally
git checkout feature/wls-stage-${STAGE}
# Make fixes
git add -A
git commit -m "fix: resolve CI failure in stage ${STAGE}"
git push

# CI will re-run automatically
gh pr checks --watch
```

### Merge Conflicts

```bash
git checkout feature/wls-stage-${STAGE}
git fetch origin
git rebase origin/main

# Resolve conflicts
# Edit conflicted files
git add <resolved-files>
git rebase --continue

git push --force-with-lease
```

---

## Parallel Execution

### When to Parallelize

Use parallelization for stages in the same group (see ORCHESTRATION.md):

```
Group E (can run simultaneously after 3.10):
- 3.11 (ChoiceScript import)
- 3.12 (Ink verification)
- 3.13 (Watch mode)
- 3.16 (VCS diff)
```

### How to Run in Parallel

**Option 1: Multiple Terminal Windows**

```bash
# Terminal 1
STAGE="3.11" && cd $WLS_TS && git checkout -b feature/wls-stage-${STAGE}
# Execute stage 3.11

# Terminal 2
STAGE="3.12" && cd $WLS_TS && git checkout -b feature/wls-stage-${STAGE}
# Execute stage 3.12

# Terminal 3
STAGE="3.13" && cd $WLS_TS && git checkout -b feature/wls-stage-${STAGE}
# Execute stage 3.13
```

**Option 2: Sequential PRs, Parallel CI**

```bash
# Create all branches and PRs quickly
for STAGE in 3.11 3.12 3.13 3.16; do
  cd $WLS_TS
  git checkout main && git pull
  git checkout -b feature/wls-stage-${STAGE}
  # Implement stage
  git push -u origin feature/wls-stage-${STAGE}
  gh pr create --title "Stage ${STAGE}" --body "..."
done

# All PRs run CI in parallel
# Merge as each passes
```

### Parallel Constraints

- Same file modifications = CANNOT parallelize
- Different packages = CAN parallelize
- Cross-repo stages = CAN parallelize

---

## Progress Tracking

### Check Completed Stages

```bash
# View merged stage PRs
cd $WLS_TS
git log --oneline --grep="Stage" | head -20

# Check open PRs
gh pr list --state open

# Check CI runs
gh run list --limit 10
```

### Stage Completion Checklist

Create a tracking file:

```bash
cat > $WLS_SPEC/wls-implementation-plan/PROGRESS.md << 'EOF'
# Implementation Progress

## Phase 2: Flow Control
- [x] 2.01 - Spec gather points
- [x] 2.02 - Spec tunnels
- [ ] 2.13 - Lua gather runtime
- [ ] 2.14 - Lua tunnel runtime
- [ ] 2.15 - Corpus flow tests

## Phase 3: Extended Tooling
- [ ] 3.11 - ChoiceScript importer
- [ ] 3.12 - Ink verification
- [ ] 3.13 - Watch mode
- [ ] 3.14 - IFDB publisher
- [ ] 3.15 - itch.io publisher
- [ ] 3.16 - VCS diff
- [ ] 3.17 - VCS merge
EOF
```

Update after each stage completes.

---

## Complete Stage Execution Script

For convenience, here's a script that automates the workflow:

```bash
#!/bin/bash
# execute-stage.sh

set -e

STAGE=$1
REPO=$2
DESCRIPTION=$3

if [ -z "$STAGE" ] || [ -z "$REPO" ]; then
  echo "Usage: ./execute-stage.sh <stage> <repo-path> [description]"
  exit 1
fi

cd "$REPO"

echo "=== Stage $STAGE ==="
echo "Repository: $REPO"
echo ""

# Step 1: Setup branch
echo "Step 1: Creating branch..."
git fetch origin
git checkout main
git pull origin main
git checkout -b "feature/wls-stage-${STAGE}"

# Step 2: Prompt user to implement
echo ""
echo "Step 2: Implement the stage now using Claude Code"
echo "Press Enter when implementation is complete..."
read

# Step 3: Run tests
echo ""
echo "Step 3: Running tests..."
if [ -f "pnpm-lock.yaml" ]; then
  pnpm lint
  pnpm typecheck
  pnpm test
elif [ -f ".busted" ]; then
  luacheck .
  busted
fi

# Step 4: Commit
echo ""
echo "Step 4: Committing..."
git add -A
git commit -m "feat: implement stage ${STAGE} - ${DESCRIPTION}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Step 5: Push and create PR
echo ""
echo "Step 5: Creating PR..."
git push -u origin "feature/wls-stage-${STAGE}"
gh pr create --title "Stage ${STAGE}: ${DESCRIPTION}" --body "## Summary
Stage ${STAGE} implementation.

## Testing
- [ ] GitHub Actions pass

## Dependencies
See stage file for details."

# Step 6: Wait for CI
echo ""
echo "Step 6: Waiting for CI..."
gh pr checks --watch

# Step 7: Merge
echo ""
echo "Step 7: Merging..."
gh pr merge --squash --delete-branch

# Step 8: Update main
git checkout main
git pull origin main

echo ""
echo "=== Stage $STAGE Complete ==="
```

Usage:

```bash
chmod +x execute-stage.sh
./execute-stage.sh 2.13 ~/code/github.com/writewhisker/whisker-core "Lua gather runtime"
```

---

## Quick Reference

| Action | Command |
|--------|---------|
| Read stage | `cat stages/X.XX-*.md` |
| Create branch | `git checkout -b feature/wls-stage-X.XX` |
| Run TS tests | `pnpm test -- --run` |
| Run Lua tests | `busted` |
| Create PR | `gh pr create` |
| Check CI | `gh pr checks --watch` |
| Merge | `gh pr merge --squash --delete-branch` |
| View progress | `git log --oneline --grep="Stage"` |
