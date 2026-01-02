# Phase 1: Unified Semantic Validation

## Objective

Implement a comprehensive semantic validation system with identical behavior in both whisker-core (Lua) and whisker-editor-web (TypeScript).

## Scope

- 35+ error codes across 7 categories
- Cross-platform parity with identical error codes and messages
- Test corpus with 50+ validation cases

## Error Categories

| Category | Code | Validators |
|----------|------|------------|
| Structure | STR | MissingStartPassage, UnreachablePassages, DuplicatePassages, EmptyPassages, OrphanPassages, Bottleneck |
| Links | LNK | DeadLinks, SelfLink, SpecialTargetCase, EmptyChoiceTarget, CircularLink |
| Variables | VAR | UndefinedVariable, UnusedVariable, InvalidName, TypeMismatch, Scoping, Shadowing, ReservedName, UninitializedRead |
| Expressions | EXP | EmptyExpression, UnmatchedParen, InvalidOperator, MalformedString, InvalidNumber, NestedExpression, UnclosedBlock |
| Types | TYP | TypeMismatch, ArithmeticOnString, ComparisonMismatch, InvalidAssignment, ListTypeMismatch |
| Flow | FLW | DeadEnd, NoTerminal, CycleDetected, InfiniteLoop, UnreachableCode, ConditionalAlwaysFalse |
| Quality | QUA | LowBranching, HighComplexity, LongPassage, DeepNesting, TooManyVariables |

## Implementation Steps

### Step 1: Specification Document
Create `phase-1-specification/spec/11-VALIDATION.md`:
- Define all error codes with examples
- Specify severity levels (error/warning/info)
- Document validation semantics

### Step 2: TypeScript Implementation
Update `packages/story-validation/`:

1. Create unified error codes:
```typescript
// src/error-codes/wls-error-codes.ts
export const WLS_ERROR_CODES = {
  'WLS-STR-001': { id: 'missing_start_passage', severity: 'error' },
  'WLS-STR-002': { id: 'unreachable_passage', severity: 'warning' },
  // ... all codes
};
```

2. Implement new validators:
- `DuplicatePassagesValidator`
- `SelfLinkValidator`
- `VariableScopingValidator`
- `TypeChecker`
- `CycleDetector`
- `DeadEndDetector`

3. Update existing validators with WLS error codes

### Step 3: Lua Implementation
Create `lib/whisker/validators/`:

```
validators/
├── init.lua              # Main validator engine
├── error_codes.lua       # All error code definitions
├── structural.lua        # STR validators
├── links.lua             # LNK validators
├── variables.lua         # VAR validators
├── expressions.lua       # EXP validators
├── types.lua             # TYP validators
├── flow.lua              # FLW validators
└── quality.lua           # QUA validators
```

### Step 4: Test Corpus
Create `phase-4-validation/test-corpus/validation/`:
- Add 50+ validation test cases
- Cover all error codes
- Include edge cases

## Priority Order

High priority (implement first):
1. WLS-STR-001: missing_start_passage (error)
2. WLS-LNK-001: dead_link (error)
3. WLS-VAR-001: undefined_variable (error)
4. WLS-STR-003: duplicate_passage (error)

Medium priority:
5. WLS-STR-002: unreachable_passage (warning)
6. WLS-VAR-002: unused_variable (warning)
7. WLS-FLW-001: dead_end (info)

Lower priority:
8. Type checking (WLS-TYP-*)
9. Flow analysis (WLS-FLW-*)
10. Quality metrics (WLS-QUA-*)

## Validation Pipeline Order

1. **Structural** (independent) - Start passage, duplicates, empty
2. **Links** (requires passages) - Dead links, special targets
3. **Variables** (requires data flow) - Undefined, unused, scoping
4. **Expressions** (requires AST) - Syntax validation
5. **Types** (requires expressions) - Type checking
6. **Flow** (requires all above) - Cycles, dead ends
7. **Quality** (optional) - Metrics and thresholds

## Key Files to Modify

**TypeScript:**
- `packages/story-validation/src/types.ts`
- `packages/story-validation/src/validators/index.ts`
- `packages/story-validation/src/StoryValidator.ts`
- `packages/story-validation/src/error-codes/` (new)

**Lua:**
- `lib/whisker/validators/` (new directory)
- `lib/whisker/parser/ws_parser.lua` (integration)

**Specification:**
- `phase-1-specification/spec/11-VALIDATION.md` (new)

**Test Corpus:**
- `phase-4-validation/test-corpus/validation/` (new)
