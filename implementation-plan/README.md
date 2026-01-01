# WLS 1.1/2.0 Implementation Plan

This directory contains the comprehensive implementation plan for addressing all identified gaps in the Whisker Language Specification and its implementations.

## Plan Structure

```
implementation-plan/
├── README.md                           # This file
├── 00-OVERVIEW.md                      # Executive summary and dependencies
├── 01-PARSER-COMPLETENESS.md           # Gap 1: Detailed phases and tasks
├── 02-ADVANCED-FLOW-CONTROL.md         # Gap 2: Detailed phases and tasks
├── 03-DATA-STRUCTURES.md               # Gap 3: Detailed phases and tasks
├── 04-MODULARITY.md                    # Gap 4: Detailed phases and tasks
├── 05-PRESENTATION-LAYER.md            # Gap 5: Detailed phases and tasks
├── 06-DEVELOPER-EXPERIENCE.md          # Gap 6: Detailed phases and tasks
├── 07-TOOLING.md                       # Gap 7: Detailed phases and tasks
├── 08-TEST-COVERAGE.md                 # Gap 8: Detailed phases and tasks
├── 09-DOCUMENTATION.md                 # Gap 9: Detailed phases and tasks
├── gap-01/CLAUDE.md                    # Claude Code context for Gap 1
├── gap-02/CLAUDE.md                    # Claude Code context for Gap 2
├── gap-03/CLAUDE.md                    # Claude Code context for Gap 3
├── gap-04/CLAUDE.md                    # Claude Code context for Gap 4
├── gap-05/CLAUDE.md                    # Claude Code context for Gap 5
├── gap-06/CLAUDE.md                    # Claude Code context for Gap 6
├── gap-07/CLAUDE.md                    # Claude Code context for Gap 7
├── gap-08/CLAUDE.md                    # Claude Code context for Gap 8
└── gap-09/CLAUDE.md                    # Claude Code context for Gap 9
```

## CLAUDE.md Files

Each gap has a `CLAUDE.md` file in its subdirectory (`gap-XX/CLAUDE.md`) that provides:

- **Context**: What the gap is about and why it matters
- **Repositories**: Paths to relevant codebases
- **Key Files**: Specific files to modify in each repository
- **Commands**: How to run tests and validate changes
- **New Error Codes**: Any new WLS error codes to implement
- **Implementation Notes**: Important considerations and gotchas
- **Success Criteria**: How to know when the gap is complete

When working on a gap, read the CLAUDE.md file first to get oriented.

## Gap Summary

| Gap | Focus | Key Deliverables |
|-----|-------|------------------|
| 1 | Parser | AST parity, error recovery, source maps |
| 2 | Flow | Gather points (`-`), tunnels (`->passage->`, `<-`) |
| 3 | Data | LIST, ARRAY, MAP types with operations |
| 4 | Modules | INCLUDE, FUNCTION, NAMESPACE support |
| 5 | Presentation | Markdown, CSS classes, audio/video, theming |
| 6 | DX | Language server, VSCode extension, debugger |
| 7 | Tools | Complete import/export, publishing, build |
| 8 | Testing | 200+ corpus tests, parity verification, fuzzing |
| 9 | Docs | Complete spec, tutorials, API reference, migration |

## Repositories Affected

| Repository | Language | Primary Changes |
|------------|----------|-----------------|
| whisker-core | Lua | Parser, runtime, validators |
| whisker-editor-web | TypeScript | Parser, player, tooling |
| whisker-language-specification | Markdown | Spec updates |

## Priority Order

1. **Gap 1**: Parser Completeness (Foundation)
2. **Gap 8**: Test Coverage (Quality gate)
3. **Gap 6**: Developer Experience (DX improvements)
4. **Gap 7**: Tooling (CLI, LSP)
5. **Gap 2**: Advanced Flow Control (Major feature)
6. **Gap 4**: Modularity (Organization)
7. **Gap 3**: Data Structures (WLS 2.0)
8. **Gap 5**: Presentation Layer (WLS 2.0)
9. **Gap 9**: Documentation (Ongoing)

## Phase Statistics

| Gap | Phases | Tasks | New Error Codes | New Examples |
|-----|--------|-------|-----------------|--------------|
| Gap 1 | 5 | 20 | 0 | 0 |
| Gap 2 | 5 | 18 | 5 | 2 |
| Gap 3 | 5 | 18 | 3 | 3 |
| Gap 4 | 5 | 18 | 4 | 3 |
| Gap 5 | 5 | 18 | 4 | 4 |
| Gap 6 | 5 | 22 | 0 | 0 |
| Gap 7 | 6 | 24 | 0 | 0 |
| Gap 8 | 5 | 18 | 0 | 0 |
| Gap 9 | 6 | 21 | 0 | 0 |
| **Total** | **47** | **177** | **16** | **12** |

## New CLI Tools (Planned)

| Tool | Gap | Purpose |
|------|-----|---------|
| `whisker-lint` | 6 | Standalone linter |
| `whisker-fmt` | 6 | Code formatter |
| `whisker-preview` | 6 | Terminal preview |
| `whisker-import` | 7 | Format import |
| `whisker-build` | 7 | Build pipeline |
| `whisker-publish` | 7 | Publishing |
| `whisker-init` | 7 | Project scaffolding |
| `whisker-lsp` | 6 | Language server |

## How to Use This Plan

1. Work through gaps in priority order
2. Complete all phases within a gap before moving to the next
3. Run review checkpoint after each phase
4. Update STATUS.md after each phase completion
5. Adjust estimates based on actual progress

**See [RUNNING.md](./RUNNING.md) for detailed execution instructions.**

## Quick Start

```bash
# 1. Read the gap context
cat gap-01/CLAUDE.md

# 2. Read the detailed plan
cat 01-PARSER-COMPLETENESS.md

# 3. Create feature branches
cd /Users/jims/code/github.com/writewhisker/whisker-core
git checkout -b feature/gap-01-parser-completeness

# 4. Work through tasks, running tests after each
busted tests/wls/test_parser.lua

# 5. Complete review checkpoint before next phase
```
