# WLS Implementation Plan

Complete implementation plan for WLS 1.0 completion, WLS 1.1, and WLS 2.0.

## Overview

| Version | Status | Focus |
|---------|--------|-------|
| WLS 1.0 | Gaps 1-6 Complete | Validation completion |
| WLS 1.1 | Planned | Flow control, tooling, testing, docs |
| WLS 2.0 | Planned | Threads, state machines, media, extensibility |

## Repositories

| Repository | Purpose |
|------------|---------|
| `whisker-core` | Lua reference implementation |
| `whisker-editor-web` | TypeScript implementation + editor |
| `whisker-language-specification-1.0` | Specification + test corpus |

## Implementation Phases

### Phase 1: Validation (WLS 1.0 Completion)
**Priority: P0 | Complexity: High**

Complete unified semantic validation across both platforms.

- 35+ error codes in 7 categories (STR, LNK, VAR, EXP, TYP, FLW, QUA)
- Identical behavior in Lua and TypeScript
- Test corpus with 50+ validation cases

See: [phases/01-validation/](phases/01-validation/)

### Phase 2: Flow Control (WLS 1.1)
**Priority: P1 | Complexity: High**

Complete advanced flow control from Ink.

- Gather points with `-` syntax
- Tunnels with `->->` return
- Inline conditionals
- Once-only text

See: [phases/02-flow-control/](phases/02-flow-control/)

### Phase 3: Tooling (WLS 1.1)
**Priority: P1 | Complexity: High**

Import/export and publishing infrastructure.

- Twine import (Harlowe, SugarCube)
- Ink import
- HTML/PWA export
- IFDB/itch.io publishing

See: [phases/03-tooling/](phases/03-tooling/)

### Phase 4: Testing (WLS 1.1)
**Priority: P1 | Complexity: Medium**

Expand test coverage to 95%+.

- Parser tests: 85% -> 95%
- Runtime tests: 70% -> 90%
- Corpus tests: 100 -> 200+

See: [phases/04-testing/](phases/04-testing/)

### Phase 5: Documentation (WLS 1.1)
**Priority: P2 | Complexity: Medium**

Complete documentation infrastructure.

- API reference
- Tutorial series
- Migration guides
- Examples library

See: [phases/05-documentation/](phases/05-documentation/)

### Phase 6: WLS 2.0
**Priority: P3 | Complexity: Very High**

Major version with breaking changes.

- Threads (parallel narrative)
- LIST state machines
- Timed content
- External functions
- Audio/Media API
- Text effects
- Hooks system
- Parameterized passages

See: [phases/06-wls-2.0/](phases/06-wls-2.0/)

## Error Code Reference

```
WLS-{CATEGORY}-{NUMBER}
```

| Category | Code | Count | Examples |
|----------|------|-------|----------|
| Structure | STR | 6 | missing_start, unreachable, duplicate |
| Links | LNK | 5 | dead_link, special_target_case |
| Variables | VAR | 8 | undefined, unused, invalid_name |
| Expressions | EXP | 7 | empty_expression, unmatched_paren |
| Types | TYP | 5 | type_mismatch, arithmetic_on_string |
| Flow | FLW | 6 | dead_end, cycle_detected, infinite_loop |
| Quality | QUA | 5 | low_branching, high_complexity |

## Success Metrics

| Metric | WLS 1.0 | WLS 1.1 | WLS 2.0 |
|--------|---------|---------|---------|
| Parser completeness | 100% | 100% | 100% |
| Test coverage | 85% | 95% | 95% |
| Corpus tests | 100 | 200+ | 300+ |
| Import formats | 1 | 5 | 5 |
| Export formats | 2 | 5+ | 7+ |
| Ink parity | 70% | 70% | 95% |
| Harlowe parity | 80% | 80% | 90% |
| SugarCube parity | 75% | 75% | 85% |

## Quick Start

1. Read the CLAUDE.md in this directory for implementation context
2. Pick a phase from phases/
3. Read the PROMPT.md to understand the task
4. Implement following the verification requirements
5. Run verification steps from VERIFICATION.md

## Directory Structure

```
wls-implementation-plan/
├── README.md                           # This file
├── CLAUDE.md                           # Implementation context
├── phases/
│   ├── 01-validation/
│   │   ├── PROMPT.md                   # Task prompt
│   │   └── VERIFICATION.md             # Verification steps
│   ├── 02-flow-control/
│   ├── 03-tooling/
│   ├── 04-testing/
│   ├── 05-documentation/
│   └── 06-wls-2.0/
└── repos/
    ├── whisker-core-CLAUDE.md          # Lua repo context
    ├── whisker-editor-web-CLAUDE.md    # TypeScript repo context
    └── whisker-specification-CLAUDE.md # Spec repo context
```
