# WLS Implementation Orchestration

## Overview

This document defines how to execute stages, manage dependencies, and ensure quality through the git workflow.

## Execution Model

Each stage:
1. Creates a feature branch from `main`
2. Implements the changes
3. Runs local tests
4. Commits with conventional commit message
5. Creates a PR
6. Waits for GitHub Actions to pass
7. Merges PR to `main`

## Stage Execution Template

```bash
# 1. Setup
STAGE="1.01"
BRANCH="feature/wls-stage-${STAGE}"
REPO="whisker-editor-web"  # or whisker-core, whisker-language-specification

cd ~/code/github.com/writewhisker/${REPO}
git fetch origin
git checkout main
git pull origin main
git checkout -b ${BRANCH}

# 2. Execute stage prompt (Claude implements changes)

# 3. Run local tests
pnpm test  # or: busted

# 4. Commit
git add -A
git commit -m "feat(validation): implement stage ${STAGE} - [description]

[Stage description from prompt]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 5. Push and create PR
git push -u origin ${BRANCH}
gh pr create --title "Stage ${STAGE}: [Title]" --body "## Summary
[Stage objective]

## Changes
- [List of changes]

## Testing
- [ ] Local tests pass
- [ ] GitHub Actions pass

## Stage Dependencies
- Depends on: [list]
- Enables: [list]
"

# 6. Wait for CI
gh pr checks ${BRANCH} --watch

# 7. Merge
gh pr merge ${BRANCH} --squash --delete-branch
```

## Repository Mapping

| Stage Prefix | Primary Repository | Secondary |
|--------------|-------------------|-----------|
| 1.01-1.05 | whisker-language-specification | - |
| 1.06-1.13 | whisker-editor-web | - |
| 1.14-1.19 | whisker-core | - |
| 1.20-1.22 | whisker-language-specification | both |
| 2.01-2.03 | whisker-language-specification | - |
| 2.04-2.10 | whisker-editor-web | - |
| 2.11-2.12 | whisker-core | - |
| 2.13-2.14 | whisker-core | - |
| 2.15 | whisker-language-specification | both |
| 3.01-3.09 | whisker-editor-web | - |
| 3.10 | whisker-core | - |
| 3.11-3.13 | whisker-editor-web | - |
| 3.14-3.15 | whisker-editor-web | - |
| 3.16-3.17 | whisker-editor-web | - |
| 4.* | all | - |
| 5.* | whisker-language-specification | - |
| 6.* | whisker-editor-web, whisker-core | spec |

## Dependency Graph

```
Phase 1: Validation
├── 1.01 ─┬─ 1.02 ─┬─ 1.03 ─┬─ 1.04 ─── 1.05  [Spec: Sequential]
│         │        │        │
│         └────────┴────────┴─────────────────  [Can parallelize within spec]
│
├── 1.06 ── 1.07 ── 1.08 ─┬─ 1.09 ─┬─ 1.10 ─┬─ 1.11 ── 1.12 ── 1.13  [TS]
│                         │        │        │
│                         └────────┴────────┘  [Validators can parallelize]
│
├── 1.14 ── 1.15 ── 1.16 ─┬─ 1.17 ─┬─ 1.18 ── 1.19  [Lua]
│                         │        │
│                         └────────┘  [Validators can parallelize]
│
└── 1.20 ── 1.21 ── 1.22  [Corpus: After TS + Lua]

Phase 2: Flow Control (Requires Phase 1 complete)
├── 2.01 ─┬─ 2.02 ─┬─ 2.03  [Spec: Sequential]
│
├── 2.04 ─┬─ 2.05 ─┬─ 2.06 ─┬─ 2.07 ── 2.08 ─┬─ 2.09 ─┬─ 2.10  [TS]
│         │        │        │                │        │
│         └────────┴────────┘ [Parser parallel] └──────┘ [Runtime parallel]
│
├── 2.11 ── 2.12 ── 2.13 ── 2.14  [Lua: Parser then runtime]
│
└── 2.15  [Corpus: After TS + Lua runtime]

Phase 3: Tooling (Requires Phase 2 complete)
├── 3.01 ── 3.02 ── 3.03 ─┬─ 3.04 ── 3.05  [Import chain]
│                         │
│                         └── [Harlowe/SugarCube parallel]
│
├── 3.06 ── 3.07 ─┬─ 3.08  [Export chain]
│                 │
│                 └── [HTML/PWA parallel after 3.07]
│
├── 3.09  [CLI: After import + export]
│
├── 3.10  [Lua: Can parallel with 3.06-3.09]
│
├── 3.11 ─┬─ 3.12 ─┬─ 3.13 ─┬─ 3.14 ─┬─ (Phase 4)  [Extended tooling]
│         │        │        │        │
│         │        │        │        └─ 3.15  [Publishing parallel]
│         │        │        │
│         └────────┴────────┘ [Can parallelize: ChoiceScript, Ink, Watch]
│
└── 3.16 ── 3.17  [VCS tools: Can parallel with 3.11-3.15]

Phase 4: Testing (Can start after Phase 1)
├── 4.01 ─┬─ 4.02 ─┬─ 4.03  [TS coverage - can parallelize]
│
├── 4.04  [Lua coverage - parallel with TS]
│
├── 4.05  [Corpus - after features complete]
│
└── 4.06  [Integration - after all]

Phase 5: Documentation (Can start after Phase 2)
├── 5.01  [API setup - independent]
│
├── 5.02 ── 5.03  [Tutorials - sequential]
│
├── 5.04  [Migration - parallel with tutorials]
│
├── 5.05  [Examples - parallel]
│
└── 5.06  [Site - after all docs]

Phase 6: WLS 2.0 (Requires Phases 1-5 complete)
├── 6.01  [Migration tool - first]
│
├── 6.02 ── 6.03  [Threads - sequential]
│
├── 6.04  [State machines - parallel with threads]
│
├── 6.05  [Timed content - parallel]
│
├── 6.06  [External functions - parallel]
│
├── 6.07  [Audio - after 6.06]
│
├── 6.08  [Text effects - parallel with 6.07]
│
├── 6.09  [Parameterized passages - parallel]
│
└── 6.10  [Corpus - after all]
```

## Parallel Execution Groups

### Group A: Can run simultaneously
- 1.08, 1.09, 1.10, 1.11 (TS validators)
- 1.16, 1.17, 1.18 (Lua validators)

### Group B: Can run simultaneously
- 2.04, 2.05, 2.06, 2.07 (TS parsers)
- 3.03, 3.04 (Converters)
- 3.07, 3.08 (Exporters)

### Group C: Can run simultaneously
- 4.01, 4.02, 4.03, 4.04 (Coverage expansion)
- 5.02, 5.04, 5.05 (Documentation)

### Group D: Can run simultaneously
- 6.04, 6.05, 6.06, 6.08, 6.09 (WLS 2.0 features)

### Group E: Extended tooling (after 3.10)
- 3.11 (ChoiceScript import)
- 3.12 (Ink verification)
- 3.13 (Watch mode)
- 3.16 (VCS diff)

### Group F: Publishing (after Group E)
- 3.14 (IFDB publisher)
- 3.15 (itch.io publisher)
- 3.17 (VCS merge)

## Cross-Repository Stages

Some stages modify multiple repositories. Execute in this order:

1. **Specification first** - Define the behavior
2. **TypeScript second** - Primary implementation
3. **Lua third** - Match TypeScript behavior
4. **Corpus last** - Verify cross-platform parity

For stages like 1.20-1.22 (corpus):
```bash
# Run corpus tests against both implementations
cd ~/code/github.com/whisker-language-specification-1.0/phase-4-validation
./tools/run-corpus.sh --platform=typescript
./tools/run-corpus.sh --platform=lua
./tools/compare-platforms.sh
```

## Preserving Previous Work

Each stage builds on previous work. The git workflow ensures this:

1. **Always branch from latest `main`**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/stage-X.XX
   ```

2. **Never force push to main**

3. **Squash merge to keep history clean**
   ```bash
   gh pr merge --squash --delete-branch
   ```

4. **If conflicts arise**, rebase on main:
   ```bash
   git fetch origin
   git rebase origin/main
   # Resolve conflicts
   git push --force-with-lease
   ```

## CI Requirements

All PRs must pass:

### whisker-editor-web
- `pnpm lint`
- `pnpm typecheck`
- `pnpm test`
- `pnpm build`

### whisker-core
- `luacheck .`
- `busted`

### whisker-language-specification
- Corpus tests (when applicable)
- Markdown linting

## Rollback Procedure

If a stage introduces issues:

```bash
# Revert the merge commit
git revert -m 1 <merge-commit-sha>
git push origin main

# Fix the issue in a new branch
git checkout -b fix/stage-X.XX-issue
# Make fixes
git commit -m "fix: resolve issue from stage X.XX"
gh pr create
```

## Monitoring Progress

Track implementation progress:

```bash
# Check merged stages
git log --oneline --grep="Stage" | head -20

# Check open PRs
gh pr list --state open

# Check CI status
gh run list --limit 10
```
