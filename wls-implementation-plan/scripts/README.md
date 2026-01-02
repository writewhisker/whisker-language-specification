# WLS Automation Scripts

Scripts for automating WLS stage execution with Claude Code.

## Quick Start

```bash
# 1. Add to PATH (add to ~/.bashrc or ~/.zshrc)
export WLS_SPEC=~/code/github.com/whisker-language-specification-1.0
export PATH="$WLS_SPEC/wls-implementation-plan/scripts:$PATH"

# 2. Reload shell
source ~/.bashrc

# 3. Execute a stage
claude-wls stage 2.13
```

## Commands

### `claude-wls stage <X.XX>`

Execute a single stage. Opens Claude Code in the correct repository with full stage context.

```bash
claude-wls stage 2.13
claude-wls stage 3.11
```

Claude will:
1. Create feature branch `feature/wls-stage-X.XX`
2. Implement all required changes
3. Run tests and verify success criteria
4. Commit with proper message
5. Create PR

### `claude-wls phase <N>`

List all stages in a phase:

```bash
claude-wls phase 3
```

Output:
```
Phase 3 Stages
===========================================

  3.11-choicescript-importer
  3.12-ink-import-verification
  3.13-watch-mode
  3.14-ifdb-publisher
  3.15-itch-publisher
  3.16-vcs-diff
  3.17-vcs-merge

Run: claude-wls stage <X.XX>
```

### `claude-wls group <A|B|E|F>`

Show parallel execution instructions for a group:

```bash
claude-wls group E
```

Output:
```
Parallel Execution: Group E
===========================================

Open these terminal windows and run:

Window 1:
  cd ~/code/.../whisker-editor-web && claude-wls stage 3.11

Window 2:
  cd ~/code/.../whisker-editor-web && claude-wls stage 3.12

Window 3:
  cd ~/code/.../whisker-editor-web && claude-wls stage 3.13

Window 4:
  cd ~/code/.../whisker-editor-web && claude-wls stage 3.16

All windows can run simultaneously.
```

## Parallel Execution

### Available Groups

| Group | Stages | Description |
|-------|--------|-------------|
| A | 1.08-1.11 | TypeScript validators |
| B | 2.04-2.07 | TypeScript parsers |
| E | 3.11, 3.12, 3.13, 3.16 | Extended tooling |
| F | 3.14, 3.15, 3.17 | Publishing & VCS |

### Example: Running Group E in 4 Windows

```bash
# Terminal 1
claude-wls stage 3.11

# Terminal 2
claude-wls stage 3.12

# Terminal 3
claude-wls stage 3.13

# Terminal 4
claude-wls stage 3.16
```

All 4 stages will execute simultaneously, each creating their own PR.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `WLS_SPEC` | `~/code/github.com/whisker-language-specification-1.0` | Spec repo |
| `WLS_TS` | `~/code/github.com/writewhisker/whisker-editor-web` | TS repo |
| `WLS_LUA` | `~/code/github.com/writewhisker/whisker-core` | Lua repo |

## Files

| Script | Purpose |
|--------|---------|
| `claude-wls` | Main execution script |
| `wls-execute` | Lower-level stage executor |
| `setup.sh` | Shell environment setup |

## Troubleshooting

### "Stage file not found"

Ensure the stage file exists:
```bash
ls $WLS_SPEC/wls-implementation-plan/phases/*/stages/
```

### "Repository not found"

Check environment variables:
```bash
echo $WLS_SPEC
echo $WLS_TS
echo $WLS_LUA
```

### Claude doesn't start

Ensure `claude` CLI is installed and in PATH:
```bash
which claude
claude --version
```
