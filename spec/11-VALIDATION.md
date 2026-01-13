# 11. Semantic Validation

This section defines the semantic validation rules for WLS. These validations are performed after parsing to catch logical errors, structural issues, and potential runtime problems.

## 11.1 Validation Error Format

All validation errors use a consistent format:

```
WLS-{CATEGORY}-{NUMBER}
```

### Categories

| Code | Category | Description |
|------|----------|-------------|
| STR | Structure | Story structure issues |
| LNK | Links | Navigation and link issues |
| VAR | Variables | Variable system issues |
| EXP | Expressions | Expression syntax issues |
| TYP | Types | Type checking issues |
| FLW | Flow | Flow analysis issues |
| QUA | Quality | Quality metrics |

### Severity Levels

- **error**: Must be fixed before story can run
- **warning**: Should be addressed, may cause issues
- **info**: Informational, style or quality suggestion

## 11.2 Structural Validations (STR)

### WLS-STR-001: missing_start_passage
**Severity**: error

No start passage is defined. Every story must have a passage named "Start" or specify a start passage via `@start:` directive.

```whisker
// ERROR: No Start passage
:: Introduction
Welcome to the story.
```

**Fix**: Add a passage named "Start" or use `@start: Introduction`

### WLS-STR-002: unreachable_passage
**Severity**: warning

A passage cannot be reached from the start passage through any path of choices.

```whisker
:: Start
+ [Go to Middle] -> Middle

:: Middle
+ [End] -> END

:: Orphan
This passage is unreachable.  // WARNING: unreachable
```

### WLS-STR-003: duplicate_passage
**Severity**: error

Multiple passages have the same name.

```whisker
:: Room
First room.

:: Room  // ERROR: duplicate
Second room.
```

### WLS-STR-004: empty_passage
**Severity**: warning

A passage has no content and no choices.

```whisker
:: Empty  // WARNING: empty passage

:: Next
Content here.
```

### WLS-STR-005: orphan_passage
**Severity**: info

A passage has no incoming links (except the start passage).

```whisker
:: Start
+ [Go] -> A

:: A
Content.  // Has incoming link from Start

:: B
Content.  // INFO: No passages link here
+ [Go] -> A
```

### WLS-STR-006: no_terminal
**Severity**: info

The story has no terminal passages (passages that end the story via `-> END` or have no choices).

## 11.3 Link Validations (LNK)

### WLS-LNK-001: dead_link
**Severity**: error

A choice targets a passage that doesn't exist.

```whisker
:: Start
+ [Go somewhere] -> NonExistent  // ERROR: dead link
```

### WLS-LNK-002: self_link_no_change
**Severity**: warning

A choice links to the same passage without any state change (action block).

```whisker
:: Loop
+ [Stay here] -> Loop  // WARNING: infinite loop potential
```

**OK** (has state change):
```whisker
:: Loop
+ [Stay here] { $count += 1 } -> Loop  // OK: state changes
```

### WLS-LNK-003: special_target_case
**Severity**: warning

A special target (END, BACK, RESTART) is used with incorrect case.

```whisker
+ [Quit] -> end     // WARNING: should be END
+ [Back] -> Back    // WARNING: should be BACK
+ [Again] -> restart // WARNING: should be RESTART
```

### WLS-LNK-004: back_on_start
**Severity**: warning

BACK is used on the start passage where there's no history to go back to.

```whisker
:: Start
+ [Go back] -> BACK  // WARNING: BACK on start
```

### WLS-LNK-005: empty_choice_target
**Severity**: error

A choice has no target specified.

```whisker
:: Start
+ [Missing target]  // ERROR: no target
```

## 11.4 Variable Validations (VAR)

### WLS-VAR-001: undefined_variable
**Severity**: error

A variable is used before it is defined.

```whisker
:: Start
Value: $score  // ERROR: score is undefined
$score = 100   // Defined too late
```

### WLS-VAR-002: unused_variable
**Severity**: warning

A variable is declared but never used.

```whisker
@vars
  unused: 0  // WARNING: never used

:: Start
$other = 10
Value: $other
```

### WLS-VAR-003: invalid_variable_name
**Severity**: error

Variable name doesn't follow naming rules (must start with letter or underscore, contain only alphanumerics and underscores).

```whisker
$123invalid = 1    // ERROR: starts with number
$my-var = 2        // ERROR: contains hyphen
$my var = 3        // ERROR: contains space
```

### WLS-VAR-004: reserved_prefix
**Severity**: warning

Variable uses a reserved prefix (`whisker_`, `__`).

```whisker
$whisker_custom = 1  // WARNING: reserved prefix
$__internal = 2      // WARNING: reserved prefix
```

### WLS-VAR-005: shadowing
**Severity**: warning

A temporary variable shadows a story variable with the same name.

```whisker
@vars
  count: 0

:: Start
$_count = 10  // WARNING: shadows $count
```

### WLS-VAR-006: lone_dollar
**Severity**: warning

A `$` appears but is not followed by a valid variable name.

```whisker
:: Start
Price: $50    // WARNING: $ not followed by identifier (treated as text)
```

### WLS-VAR-007: unclosed_interpolation
**Severity**: error

Expression interpolation `${` is not closed with `}`.

```whisker
:: Start
Value: ${score + 10  // ERROR: missing }
```

### WLS-VAR-008: temp_cross_passage
**Severity**: error

A temporary variable (`$_var`) is referenced in a different passage from where it was defined.

```whisker
:: Start
$_local = 10
+ [Go] -> Other

:: Other
Value: $_local  // ERROR: temp var from different passage
```

## 11.5 Expression Validations (EXP)

### WLS-EXP-001: empty_expression
**Severity**: error

An expression block is empty.

```whisker
:: Start
${}              // ERROR: empty expression
+ { } [Go] -> A  // ERROR: empty condition
```

### WLS-EXP-002: unclosed_block
**Severity**: error

A conditional block `{` is not closed with `{/}`.

```whisker
:: Start
{ $flag }
  Content.
// ERROR: missing {/}
```

### WLS-EXP-003: assignment_in_condition
**Severity**: warning

Single `=` (assignment) used in a condition where `==` (comparison) was likely intended.

```whisker
+ { $x = 5 } [Option] -> A  // WARNING: did you mean ==?
```

### WLS-EXP-004: missing_operand
**Severity**: error

A binary operator is missing an operand.

```whisker
$x = 5 +    // ERROR: missing right operand
$y = >= 10  // ERROR: missing left operand
```

### WLS-EXP-005: invalid_operator
**Severity**: error

An unknown or invalid operator is used.

```whisker
{ $x === 5 }  // ERROR: use == not ===
{ $x != 5 }   // ERROR: use ~= not !=
```

### WLS-EXP-006: unmatched_parenthesis
**Severity**: error

Parentheses are not balanced.

```whisker
$x = (5 + 3   // ERROR: missing )
$y = 5 + 3)   // ERROR: extra )
```

### WLS-EXP-007: incomplete_expression
**Severity**: error

Expression is syntactically incomplete.

```whisker
{ $gold >= }  // ERROR: incomplete comparison
```

## 11.6 Type Validations (TYP)

### WLS-TYP-001: type_mismatch
**Severity**: error

Incompatible types in an operation.

```whisker
$result = "hello" + 5  // ERROR: can't add string and number
```

### WLS-TYP-002: arithmetic_on_string
**Severity**: error

Arithmetic operator used on string value.

```whisker
$name = "Alice"
$x = $name * 2  // ERROR: can't multiply string
```

### WLS-TYP-003: concat_non_string
**Severity**: warning

Concatenation operator used with non-string (implicit conversion).

```whisker
$msg = "Count: " .. 5  // WARNING: 5 will be converted to "5"
```

### WLS-TYP-004: comparison_type_mismatch
**Severity**: warning

Comparing values of different types.

```whisker
{ "5" == 5 }  // WARNING: comparing string to number
```

### WLS-TYP-005: boolean_expected
**Severity**: warning

Non-boolean value used in boolean context (condition).

```whisker
{ $name }  // WARNING: string used as boolean (truthy check)
  Hello!
{/}
```

## 11.7 Flow Analysis (FLW)

### WLS-FLW-001: dead_end
**Severity**: info

A passage has no choices and is not a terminal passage (doesn't use `-> END`).

```whisker
:: DeadEnd
This passage has no way out.  // INFO: dead end
```

### WLS-FLW-002: bottleneck
**Severity**: info

All paths through the story must pass through this single passage.

```whisker
:: Start
+ [Path A] -> Middle
+ [Path B] -> Middle

:: Middle  // INFO: bottleneck - all paths go through here
+ [Continue] -> End
```

### WLS-FLW-003: cycle_detected
**Severity**: info

The story contains cycles (loops back to earlier passages). This is normal for many stories.

### WLS-FLW-004: infinite_loop
**Severity**: warning

A potential infinite loop exists with no exit condition.

```whisker
:: Loop
+ [Again] -> Loop  // WARNING: no way to exit
```

**OK** (has exit):
```whisker
:: Loop
+ { $count < 3 } [Again] { $count += 1 } -> Loop
+ { $count >= 3 } [Done] -> END
```

### WLS-FLW-005: unreachable_choice
**Severity**: warning

A choice condition is always false.

```whisker
:: Start
$gold = 0
+ { $gold > 100 } [Buy] -> Shop  // WARNING: condition always false
```

### WLS-FLW-006: always_true_condition
**Severity**: info

A choice condition is always true (could be simplified).

```whisker
+ { true } [Go] -> Next  // INFO: condition always true
```

## 11.8 Quality Metrics (QUA)

### WLS-QUA-001: low_branching
**Severity**: info

Average choices per passage is below threshold (default: 1.5).

### WLS-QUA-002: high_complexity
**Severity**: info

Story complexity score exceeds threshold (based on passage count, choice count, variable count).

### WLS-QUA-003: long_passage
**Severity**: info

A passage exceeds the word count threshold (default: 500 words).

### WLS-QUA-004: deep_nesting
**Severity**: warning

Conditional nesting exceeds threshold (default: 5 levels).

```whisker
{ $a }
  { $b }
    { $c }
      { $d }
        { $e }
          { $f }  // WARNING: 6 levels deep
          {/}
        {/}
      {/}
    {/}
  {/}
{/}
```

### WLS-QUA-005: many_variables
**Severity**: info

Story has more variables than threshold (default: 50).

## 11.9 Validation API

Implementations should provide a validation API:

```lua
-- Lua
local validator = require("whisker.validators")
local result = validator.validate(story, {
  phases = {"structural", "links", "variables"},
  minSeverity = "warning"
})

for _, error in ipairs(result.errors) do
  print(error.code .. ": " .. error.message)
end
```

```typescript
// TypeScript
import { StoryValidator } from '@writewhisker/story-validation';

const validator = new StoryValidator();
const result = validator.validate(story, {
  phases: ['structural', 'links', 'variables'],
  minSeverity: 'warning'
});

result.issues.forEach(issue => {
  console.log(`${issue.code}: ${issue.message}`);
});
```

## 11.10 Validation Result Format

```typescript
interface ValidationResult {
  valid: boolean;           // true if no errors
  issues: ValidationIssue[];
  statistics: {
    errors: number;
    warnings: number;
    info: number;
    byCategory: Record<string, number>;
  };
}

interface ValidationIssue {
  code: string;            // e.g., "WLS-LNK-001"
  severity: 'error' | 'warning' | 'info';
  category: string;        // e.g., "links"
  message: string;         // Human-readable message
  location?: {
    passageId?: string;
    passageName?: string;
    line?: number;
    column?: number;
  };
  context?: Record<string, unknown>;
  suggestion?: string;
}
```
