# Issue Register: WLS 1.0.0 (Iteration 003)

**Generated**: 2026-01-17
**Spec Version**: 1.0.0
**Iteration**: 003

---

## Summary Statistics

| Severity | Count | Resolved | Pending |
|----------|-------|----------|---------|
| Critical | 0 | 0 | 0 |
| Major | 28 | 0 | 28 |
| Minor | 70 | 0 | 70 |
| **Total** | **98** | **0** | **98** |

---

## High-Consensus Issues (3+ Personas)

### HC-001: Error Recovery Semantics Underspecified
**Severity**: Major | **Consensus**: 3 personas
**Identified By**: Core Developer, QA Engineer, Runtime Implementer

**Description**: Runtime error recovery behavior is not fully specified. What happens after a recoverable error? Does execution continue? Is state rolled back?

**Suggested Fix**: Add Section 2.9.4 "Recovery Semantics" specifying:
- Execution continues from next statement
- Default values used per error type
- Partial changes preserved
- Error logged with WLS code

**Priority**: P1

---

### HC-002: Brace Syntax Overloading
**Severity**: Major | **Consensus**: 3 personas
**Identified By**: Parser/Compiler Engineer, Language Designer, Tech Writer

**Description**: The `{` character begins multiple constructs (conditional, inline conditional, map, action block), creating parsing complexity and cognitive load.

**Suggested Fix**:
1. Document disambiguation rules explicitly
2. Consider alternative syntax for maps (`#{...}`)
3. Add parsing strategy appendix

**Priority**: P2

---

### HC-003: Ecosystem/Community Gap
**Severity**: Major | **Consensus**: 3 personas
**Identified By**: Ink/Twine/CS User, Skeptical Adopter, Game Narrative Designer

**Description**: No production implementations, no community, no tutorials beyond the spec itself.

**Suggested Fix**: Address via ecosystem development:
1. Ship reference implementations publicly
2. Create showcase projects
3. Establish community forums
4. Develop official tutorials

**Priority**: P1 (for adoption, not spec)

---

### HC-004: Implementation Limits Not Specified
**Severity**: Major | **Consensus**: 3 personas
**Identified By**: QA Engineer, Runtime Implementer, Edge Case Hunter

**Description**: No minimum requirements for numeric limits, string lengths, array sizes, nesting depths.

**Suggested Fix**: Add "Implementation Limits" table:
```markdown
| Limit | Minimum |
|-------|---------|
| Nesting depth | 50 |
| History length | 1000 |
| String length | 1MB |
| Variables | 10000 |
```

**Priority**: P2

---

### HC-005: Execution Order Not Explicit
**Severity**: Major | **Consensus**: 2 personas
**Identified By**: Runtime Implementer, Core Developer

**Description**: Passage execution order (visit count, hooks, temp vars, rendering, choices) is not explicitly documented.

**Suggested Fix**: Add Section 2.7.5 "Passage Execution Order" with numbered sequence.

**Priority**: P2

---

## Major Issues by Category

### Grammar/Parsing (4 issues)

| ID | Issue | Personas | Priority |
|----|-------|----------|----------|
| GR-001 | Brace context requires semantic lookahead | Parser/Compiler | P2 |
| GR-002 | Newline sensitivity inconsistent | Parser/Compiler | P3 |
| GR-003 | Brace overloading creates cognitive load | Language Designer | P2 |
| GR-004 | `~=` violates principle of least surprise | Language Designer | P3 |

### Documentation (8 issues)

| ID | Issue | Personas | Priority |
|----|-------|----------|----------|
| DC-001 | No "Common Patterns" section | Tech Writer S2 | P2 |
| DC-002 | Migration path unclear | Tech Writer S2, Ink/Twine | P2 |
| DC-003 | No automated migration tools | Ink/Twine/CS | P3 |
| DC-004 | TextMate grammar not provided | Editor/Tooling | P2 |
| DC-005 | No story graph visualization spec | Narrative Designer | P3 |
| DC-006 | "Identical behavior" undefined | QA Engineer | P2 |
| DC-007 | Getting Started tutorial missing | Tech Writer S1 | P2 |
| DC-008 | Glossary needed | Tech Writer S1, S2 | P3 |

### Implementation (8 issues)

| ID | Issue | Personas | Priority |
|----|-------|----------|----------|
| IM-001 | Error recovery semantics underspecified | Core Dev, QA, Runtime | P1 |
| IM-002 | Execution order not explicit | Runtime, Core Dev | P2 |
| IM-003 | Concurrent access not addressed | Runtime | P3 |
| IM-004 | Incremental parsing not fully specified | Editor/Tooling | P3 |
| IM-005 | `whisker.passage.go()` mid-render behavior | Core Developer | P2 |
| IM-006 | Numeric limits unspecified | Edge Case Hunter | P2 |
| IM-007 | Unicode edge cases underspecified | Edge Case Hunter | P2 |
| IM-008 | Random state reproducibility unclear | Runtime, QA | P3 |

### Adoption/Ecosystem (4 issues)

| ID | Issue | Personas | Priority |
|----|-------|----------|----------|
| AD-001 | No production-proven implementations | Skeptical Adopter | P1* |
| AD-002 | Community size = zero | Skeptical Adopter, Ink/Twine | P1* |
| AD-003 | Complex relationship tracking verbose | IF Author | P3 |
| AD-004 | No built-in dialog system | IF Author | P3 |

*Priority P1 for adoption, not spec changes

### Project/Planning (4 issues)

| ID | Issue | Personas | Priority |
|----|-------|----------|----------|
| PJ-001 | Acceptance criteria format varies | Project Manager | P3 |
| PJ-002 | MVP vs full scope not delineated | Project Manager | P3 |
| PJ-003 | Integration points underspecified | Project Manager | P2 |
| PJ-004 | No content locking/approval workflow | Narrative Designer | P3 |

---

## Minor Issues Summary (70 total)

### By Category

| Category | Count | Key Issues |
|----------|-------|------------|
| Documentation polish | 20 | Glossary, diagrams, cheat sheet |
| Syntax clarification | 15 | Escape sequences, identifier limits |
| Edge case specification | 15 | Negative index, empty alternatives |
| Tooling details | 10 | Folding regions, hover content |
| Workflow enhancements | 10 | Stat screens, turn tracking |

### High-Frequency Minor Issues (Multiple Personas)

| Issue | Personas |
|-------|----------|
| Glossary needed | Tech Writer S1, S2 |
| Visual diagrams missing | Tech Writer S1, Narrative Designer |
| Cheat sheet wanted | Tech Writer S1, S2 |
| Visit count syntax verbose | IF Author, Ink/Twine |

---

## Issues by Persona

| Persona | Critical | Major | Minor |
|---------|----------|-------|-------|
| Core Developer | 0 | 2 | 5 |
| QA Engineer | 0 | 3 | 5 |
| Technical Writer (S1) | 0 | 0 | 5 |
| Project Manager | 0 | 3 | 5 |
| Parser/Compiler Engineer | 0 | 2 | 5 |
| Language Designer | 0 | 2 | 5 |
| Technical Writer (S2) | 0 | 2 | 5 |
| Interactive Fiction Author | 0 | 2 | 5 |
| Ink/Twine/ChoiceScript User | 0 | 2 | 5 |
| Game Narrative Designer | 0 | 2 | 5 |
| Editor/Tooling Developer | 0 | 2 | 5 |
| Runtime Implementer | 0 | 2 | 5 |
| Skeptical Adopter | 0 | 2 | 5 |
| Edge Case Hunter | 0 | 2 | 5 |

---

## Recommended Priority Order

### P1 - Address in 1.0.1
1. IM-001: Error recovery semantics
2. IM-006: Numeric limits
3. IM-007: Unicode handling
4. DC-006: "Identical behavior" definition

### P2 - Address in 1.1.0
1. HC-002: Brace disambiguation documentation
2. IM-002: Execution order specification
3. IM-005: Mid-render navigation behavior
4. DC-001: Common patterns section
5. DC-002: Migration guides
6. DC-004: TextMate grammar
7. DC-007: Getting Started tutorial
8. PJ-003: Integration interface

### P3 - Consider for Future
1. All remaining major issues
2. All minor issues
3. Ecosystem development (parallel track)

---

*End of Issue Register*
