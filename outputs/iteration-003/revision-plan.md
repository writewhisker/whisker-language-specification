# Revision Plan: WLS 1.0.0 → 1.0.1 (Iteration 003)

**Generated**: 2026-01-17
**Current Version**: 1.0.0
**Target Version**: 1.0.1
**Iteration**: 003

---

## Revision Summary

| Category | Revisions | Priority |
|----------|-----------|----------|
| Error Handling | 2 | P1 |
| Implementation Limits | 2 | P1 |
| Execution Semantics | 2 | P2 |
| Documentation | 4 | P2 |
| **Total** | **10** | - |

---

## P1 Revisions (1.0.1)

### REV-053: Error Recovery Semantics

**Section**: 2.9 (Add 2.9.4)
**Issues Addressed**: IM-001, CD-MAJ-001, QA-MAJ-003, RI-MAJ-001
**Personas**: Core Developer, QA Engineer, Runtime Implementer

**Current Text**: Section 2.9.2 says runtime errors "SHOULD not crash" and "allow recovery when possible" without specifics.

**Proposed Text**:
```markdown
### 2.9.4 Recovery Semantics

For recoverable errors, implementations MUST:

1. **Log the error** with appropriate WLS error code
2. **Use default value** per the error recovery table
3. **Continue execution** from the next statement
4. **Preserve state** - changes before error are kept
5. **Complete passage rendering** normally
6. **Present choices** if rendering completes

#### Recovery Table

| Error Type | Default Value | Continues? |
|------------|---------------|------------|
| Undefined variable | `""` | Yes |
| Type mismatch | Skip operation | Yes |
| Division by zero | `0` | Yes |
| Invalid array index | `nil` | Yes |
| Invalid map key | `nil` | Yes |

#### Non-Recoverable Errors

These errors MUST halt execution:
- WLS-SYN-* (syntax errors)
- WLS-STR-001 (missing start passage)
- WLS-LNK-001 (navigation to non-existent passage)
- WLS-FLW-004 (infinite loop detected)
- WLS-MOD-005 (stack overflow)
```

**Justification**: Three personas identified this gap as blocking conformance testing and implementation clarity.

---

### REV-054: Numeric Limits Specification

**Section**: 4.3.1 (Add 4.3.1.1)
**Issues Addressed**: IM-006, EC-MAJ-001, QA-MAJ-002
**Personas**: Edge Case Hunter, QA Engineer, Runtime Implementer

**Current Text**: No numeric limits specified.

**Proposed Text**:
```markdown
### 4.3.1.1 Numeric Representation

WLS numbers follow IEEE 754 double-precision floating-point:

| Property | Value |
|----------|-------|
| Range | ±1.7976931348623157E+308 |
| Precision | 15-17 significant decimal digits |
| Integer range | ±9007199254740991 (2^53 - 1) |

#### Special Values

| Value | Supported | Behavior |
|-------|-----------|----------|
| Infinity | Yes | Result of overflow |
| -Infinity | Yes | Result of negative overflow |
| NaN | Yes | Result of undefined operations |

#### Overflow Behavior

- Positive overflow → `Infinity`
- Negative overflow → `-Infinity`
- Underflow → `0`

#### Examples

```whisker
$big = 1e309        // Infinity
$tiny = 1e-400      // 0 (underflow)
$weird = 0 / 0      // NaN
$inf = 1 / 0        // Infinity
```
```

**Justification**: Edge Case Hunter and QA Engineer identified this as necessary for portable conformance testing.

---

### REV-055: Unicode Handling Specification

**Section**: 3.2.1 (Add 3.2.1.1)
**Issues Addressed**: IM-007, EC-MAJ-002
**Personas**: Edge Case Hunter, Parser/Compiler Engineer

**Current Text**: "WLS source files MUST be encoded in UTF-8" without edge case handling.

**Proposed Text**:
```markdown
### 3.2.1.1 Unicode Handling

#### Encoding

- **Required**: UTF-8 without BOM (BOM tolerated, stripped)
- **Rejected**: UTF-16, UTF-32 (error WLS-ENC-001)

#### Normalization

- Input SHOULD be in NFC (Canonical Composition)
- Implementations MAY normalize to NFC on read
- String comparison uses byte-level equality

#### String Length

- `#$string` returns **code point count**, not byte count
- Grapheme clusters may span multiple code points

#### Identifiers

- ASCII only: `[A-Za-z_][A-Za-z0-9_]*`
- Unicode letters NOT permitted in identifiers
- Unicode permitted in string content and comments

#### Examples

```whisker
$emoji = "🎮🎲"
${#$emoji}         // 2 (code points)
$name = "Café"     // Valid string
// $Café = 1       // INVALID: non-ASCII identifier
```
```

**Justification**: Edge Case Hunter identified multiple undefined Unicode scenarios.

---

### REV-056: Identical Behavior Definition

**Section**: 1.7 (Add 1.7.3)
**Issues Addressed**: DC-006, QA-MAJ-001
**Personas**: QA Engineer

**Current Text**: Conformance requires "identical output" without definition.

**Proposed Text**:
```markdown
### 1.7.3 Output Comparison Rules

"Identical output" for conformance testing means:

| Aspect | Comparison Rule |
|--------|-----------------|
| Rendered text | Byte-for-byte UTF-8 match |
| Whitespace | Significant (preserved) |
| Floating-point | Exact match or ≤1e-10 epsilon |
| Error codes | Exact match |
| Error messages | NOT compared (implementation-specific) |
| Debug output | NOT compared |
| Timing | NOT compared |

#### Test Oracle

Conformance tests specify expected output as UTF-8 strings. Implementations pass if output matches exactly, with floating-point epsilon tolerance.
```

**Justification**: QA Engineer identified this as essential for conformance testing.

---

## P2 Revisions (1.1.0)

### REV-057: Passage Execution Order

**Section**: 2.7 (Add 2.7.5)
**Issues Addressed**: IM-002, RI-MAJ-001
**Personas**: Runtime Implementer, Core Developer

**Proposed Text**:
```markdown
### 2.7.5 Passage Execution Order

When navigating to a passage, execution proceeds:

1. **Pre-enter**: Increment visit count for passage
2. **History**: Add passage to navigation history
3. **Initialize**: Create empty temp variable scope
4. **onEnter**: Fire `onEnter` hook (if defined)
5. **Render**: Process content top-to-bottom
   - Execute assignments immediately
   - Evaluate conditionals
   - Resolve alternatives
   - Expand hooks
6. **Choices**: Evaluate choice conditions, build list
7. **Present**: Display content and available choices
8. **Await**: Wait for player selection
9. **Action**: Execute selected choice's action block
10. **onExit**: Fire `onExit` hook (if defined)
11. **Cleanup**: Clear temp variables
12. **Navigate**: Go to choice target (return to step 1)
```

---

### REV-058: Implementation Limits Table

**Section**: Add Appendix C
**Issues Addressed**: HC-004, QA-MAJ-002
**Personas**: QA Engineer, Runtime Implementer, Edge Case Hunter

**Proposed Text**:
```markdown
## Appendix C: Implementation Limits

Conformant implementations MUST support at least these minimums:

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| Conditional nesting depth | 50 | 100 |
| Tunnel call depth | 100 | 1000 |
| History entries | 1000 | 10000 |
| Story variables | 1000 | 10000 |
| Temp variables per passage | 100 | 1000 |
| String length | 1 MB | 16 MB |
| Array elements | 10000 | 100000 |
| Map entries | 10000 | 100000 |
| Passage content size | 1 MB | 16 MB |
| Identifier length | 255 | 1024 |
| Include depth | 10 | 50 |

Implementations MAY provide configuration to adjust these limits.

Exceeding limits SHOULD produce appropriate WLS-LIM-* errors.
```

---

### REV-059: Brace Disambiguation Guide

**Section**: Add Section 3.8.3
**Issues Addressed**: HC-002, GR-001, PC-MAJ-001
**Personas**: Parser/Compiler Engineer, Language Designer

**Proposed Text**:
```markdown
### 3.8.3 Brace Construct Disambiguation

The `{` character begins several constructs. Parsers distinguish them by lookahead:

| After `{` | Construct | Example |
|-----------|-----------|---------|
| `\|` | Alternative | `{\| a \| b }` |
| `$`/`_` then `:` then non-`:` | Inline conditional | `{$x: yes \| no}` |
| `$`/`_` then `=` | Action block | `{$x = 1}` |
| `@` | Hook operation | `{@show: name}` |
| identifier `:` value | Map literal | `{key: val}` |
| expression `}` newline | Conditional block | `{$flag}` |

#### Parsing Strategy

1. Consume `{`
2. If next is `|`, parse as alternative
3. If next is `@`, parse as hook operation
4. Parse expression/identifier
5. Lookahead for `:`, `=`, `}`, or `|`
6. Dispatch based on lookahead

#### Maximum Lookahead: 3 tokens
```

---

### REV-060: Common Patterns Section

**Section**: Add Chapter 10.X
**Issues Addressed**: DC-001, TW-MAJ-001
**Personas**: Tech Writer S2, IF Author

**Proposed Text**: (abbreviated)
```markdown
## 10.X Common Patterns

### 10.X.1 Inventory System
[Pattern for LIST-based inventory]

### 10.X.2 Relationship Tracking
[Pattern for NPC relationships]

### 10.X.3 Dialog Trees
[Pattern for conversation menus]

### 10.X.4 Time/Turn Counting
[Pattern for turn tracking]

### 10.X.5 Stat Checks
[Pattern for attribute-gated choices]
```

---

## Documentation-Only Changes

### DOC-001: Quick Start Tutorial
**Location**: New chapter after Introduction
**Issues**: DC-007
**Content**: 5-minute "Hello World" guide

### DOC-002: Migration Guides
**Location**: Appendix
**Issues**: DC-002, ITC-MAJ-001
**Content**: Ink → WLS, Twine → WLS, ChoiceScript → WLS tables

### DOC-003: TextMate Grammar
**Location**: Appendix or separate file
**Issues**: DC-004
**Content**: Complete .tmLanguage.json

### DOC-004: Glossary
**Location**: Appendix
**Issues**: DC-008
**Content**: Alphabetized term definitions

---

## Implementation Notes

### Version Increment
- 1.0.0 → 1.0.1: P1 revisions (PATCH - clarifications only)
- 1.0.1 → 1.1.0: P2 revisions (MINOR - additive documentation)

### Backwards Compatibility
All revisions are clarifications or additions. No breaking changes.

### Test Corpus Updates
Add tests for:
- Numeric edge cases (infinity, NaN)
- Unicode handling
- Recovery behavior verification

---

*End of Revision Plan*
