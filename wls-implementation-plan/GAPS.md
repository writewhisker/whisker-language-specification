# WLS Implementation Plan - Gap Analysis

## Overview

This document identifies gaps in the current implementation plan and provides prioritized stages to address them.

## Gap Categories

### Category A: Phase 2 Completion Gaps (High Priority)

| Gap ID | Description | Current Status | Required Work |
|--------|-------------|----------------|---------------|
| GAP-2.1 | Lua runtime gather/tunnel execution | Parser done, runtime missing | Add gather/tunnel handling to Lua player |
| GAP-2.2 | Corpus tests for gather/tunnel | flow-tests.yaml lacks coverage | Add gather/tunnel test cases |

### Category B: Missing Import Formats (Medium Priority)

| Gap ID | Description | Current Status | Required Work |
|--------|-------------|----------------|---------------|
| GAP-3.1 | ChoiceScript import | Not implemented | Create ChoiceScriptImporter |
| GAP-3.2 | Ink import verification | adapter-ink exists, unclear coverage | Verify and complete Ink conversion |
| GAP-3.3 | Ren'Py import verification | adapter-renpy exists | Verify conversion coverage |

### Category C: Missing Export Features (Medium Priority)

| Gap ID | Description | Current Status | Required Work |
|--------|-------------|----------------|---------------|
| GAP-3.4 | PWA export | Stage 3.08 defined but not implemented | Implement PWAExporter |
| GAP-3.5 | Watch mode | Unknown if cli-build has --watch | Verify/implement watch mode |

### Category D: Publishing Integration (Lower Priority)

| Gap ID | Description | Current Status | Required Work |
|--------|-------------|----------------|---------------|
| GAP-3.6 | IFDB publishing | Not implemented | Create IFDB publisher |
| GAP-3.7 | itch.io publishing | Not implemented | Create itch.io publisher |
| GAP-3.8 | Custom hosting export | Unknown | Create hosting export templates |

### Category E: Developer Tooling (Lower Priority)

| Gap ID | Description | Current Status | Required Work |
|--------|-------------|----------------|---------------|
| GAP-3.9 | VCS semantic diff | Not implemented | Create WLS diff tool |
| GAP-3.10 | VCS merge conflict resolution | Not implemented | Create WLS merge tool |
| GAP-3.11 | Story-aware git blame | Not implemented | Create WLS blame integration |

## New Stages Required

### Phase 2 Additions (Insert after 2.12)

```
2.13 - Lua runtime gather execution
2.14 - Lua runtime tunnel execution
2.15 - Corpus gather/tunnel tests
```

### Phase 3 Additions (Insert after 3.10)

```
3.11 - ChoiceScript importer
3.12 - Ink import verification
3.13 - Watch mode implementation
3.14 - IFDB publisher
3.15 - itch.io publisher
3.16 - VCS diff tool
3.17 - VCS merge tool
```

## Dependency Graph Update

```
Phase 2 Additions:
2.12 ── 2.13 ── 2.14 ── 2.15  [Sequential: Lua runtime → tests]

Phase 3 Additions:
3.10 ─┬─ 3.11 ─────────────┬─ 3.14 ─┬─ (Phase 4)
      │                     │        │
      ├─ 3.12 ──────────────┤        ├─ 3.15
      │                     │        │
      ├─ 3.13 ──────────────┤        └─ (Can run in parallel)
      │                     │
      └─ 3.16 ── 3.17 ──────┘ [VCS tools can parallelize with others]
```

## Parallelization Groups

### Group E: Can run simultaneously after 3.10
- 3.11 (ChoiceScript import)
- 3.12 (Ink verification)
- 3.13 (Watch mode)
- 3.16 (VCS diff)

### Group F: Can run simultaneously after Group E
- 3.14 (IFDB publishing)
- 3.15 (itch.io publishing)
- 3.17 (VCS merge)

## Success Criteria

Each gap stage must meet:

1. **Implementation**: Code complete and passing lint/typecheck
2. **Tests**: Unit tests with >80% coverage
3. **Documentation**: API docs and usage examples
4. **Integration**: Works with existing tooling
5. **CI**: GitHub Actions passing

## Priority Order

| Priority | Gaps | Rationale |
|----------|------|-----------|
| P0 | GAP-2.1, GAP-2.2 | Phase 2 must complete before Phase 3 |
| P1 | GAP-3.4, GAP-3.5 | Core export functionality |
| P2 | GAP-3.1, GAP-3.2 | Import ecosystem completeness |
| P3 | GAP-3.6, GAP-3.7 | Publishing workflow |
| P4 | GAP-3.9, GAP-3.10 | Developer experience |
