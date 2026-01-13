# Chapter 12: Modules

**Whisker Language Specification 1.0**

---

## 12.1 Overview

Modules provide code organization and reuse mechanisms for large Whisker projects. WLS supports three modularity features:

| Feature | Purpose | Syntax |
|---------|---------|--------|
| INCLUDE | Import external files | `INCLUDE "path/file.ws"` |
| FUNCTION | Define reusable logic | `FUNCTION name(params)...END` |
| NAMESPACE | Scope passage names | `NAMESPACE Name...END NAMESPACE` |

## 12.2 Include Directive

### 12.2.1 Basic Syntax

The INCLUDE directive imports content from external files:

```whisker
INCLUDE "path/to/file.ws"
```

**Rules:**
- INCLUDE must appear at the top of the file, before passages
- Paths are relative to the including file's location
- File extension `.ws` is required
- Quotes are required around the path

**Example:**

```whisker
// main.ws
INCLUDE "common/dialogs.ws"
INCLUDE "characters/merchant.ws"

:: Start
@tags: start
Welcome to the game!
+ [Talk to merchant] -> Merchant::Greeting
```

### 12.2.2 Path Resolution

Paths are resolved relative to the including file:

```
project/
├── main.ws              # INCLUDE "lib/utils.ws"
├── lib/
│   ├── utils.ws         # Resolved from main.ws
│   └── helpers.ws       # INCLUDE "helpers.ws" from utils.ws
└── chapters/
    └── chapter1.ws      # INCLUDE "../lib/utils.ws"
```

**Resolution Rules:**

| Path | Meaning |
|------|---------|
| `"file.ws"` | Same directory as including file |
| `"dir/file.ws"` | Subdirectory relative to including file |
| `"../file.ws"` | Parent directory |
| `"../dir/file.ws"` | Sibling directory |

### 12.2.3 Include Order

Files are processed in order of inclusion:

1. Parse the main file
2. For each INCLUDE (in order):
   - Resolve the file path
   - Parse the included file recursively
   - Merge content into the main story
3. Resolve all passage references

**Merging Rules:**

| Content | Merge Behavior |
|---------|----------------|
| Passages | Added to story (namespace-prefixed if applicable) |
| Variables | Merged into global @vars |
| Functions | Added to function registry |
| Metadata | First file's metadata takes precedence |

### 12.2.4 Circular Include Detection

Circular includes are forbidden and produce an error:

```whisker
// a.ws
INCLUDE "b.ws"  // OK

// b.ws
INCLUDE "a.ws"  // ERROR: WLS-MOD-002 circular_include
```

**Detection:**
- Track include stack during parsing
- Error if a file appears twice in the stack
- Report the circular chain in the error message

### 12.2.5 Error Codes

| Code | Name | Severity | Description |
|------|------|----------|-------------|
| WLS-MOD-001 | include_not_found | error | Included file does not exist |
| WLS-MOD-002 | circular_include | error | Circular include detected |

## 12.3 Functions

### 12.3.1 Basic Syntax

Functions define reusable logic blocks:

```whisker
FUNCTION name(param1, param2)
  // Function body
  RETURN value
END
```

**Components:**

| Component | Description |
|-----------|-------------|
| `FUNCTION` | Keyword starting definition |
| `name` | Valid identifier |
| `(params)` | Comma-separated parameter list |
| Body | Statements and expressions |
| `RETURN` | Optional return statement |
| `END` | Keyword ending definition |

**Example:**

```whisker
FUNCTION greet(name)
  RETURN "Hello, " .. name .. "!"
END

FUNCTION roll_dice(sides)
  RETURN math.random(1, sides)
END

:: Start
{= greet("Player") }
You rolled: {= roll_dice(6) }
```

### 12.3.2 Parameters

Parameters are passed by value:

```whisker
FUNCTION add(a, b)
  RETURN a + b
END

:: Test
Result: {= add(5, 3) }  // Outputs: Result: 8
```

**Parameter Rules:**
- Parameters are local to the function
- Modifications do not affect caller's variables
- Parameters can have any type (number, string, boolean, table)
- Missing arguments default to `nil`

### 12.3.3 Return Values

Use RETURN to provide a value from the function:

```whisker
FUNCTION calculate_damage(base, modifier)
  local damage = base * modifier
  RETURN damage
END

// Without RETURN, function returns nil
FUNCTION log_message(msg)
  // Side effect only
END
```

**Return Rules:**
- RETURN immediately exits the function
- Value is passed back to the caller
- Multiple RETURN statements allowed (only first executed)
- Omitting RETURN returns `nil`

### 12.3.4 Local Variables

Variables declared in functions are local:

```whisker
FUNCTION process()
  local temp = 100      // Local to function
  $global = 200         // Modifies story variable
  RETURN temp
END
```

**Scope Rules:**

| Declaration | Scope |
|-------------|-------|
| `local var` | Function only |
| `$var` | Story-wide (game state) |
| Parameters | Function only |

### 12.3.5 Recursion

Functions can call themselves with depth limits:

```whisker
FUNCTION factorial(n)
  IF n <= 1 THEN
    RETURN 1
  END
  RETURN n * factorial(n - 1)
END
```

**Recursion Limits:**
- Default max depth: 100 calls
- Exceeding limit raises WLS-MOD-005: stack_overflow
- Depth is tracked per call chain

### 12.3.6 Error Codes

| Code | Name | Severity | Description |
|------|------|----------|-------------|
| WLS-MOD-003 | undefined_function | error | Called function not defined |
| WLS-MOD-005 | stack_overflow | error | Recursion depth exceeded |
| WLS-MOD-006 | invalid_function_name | error | Function name not valid identifier |

## 12.4 Namespaces

### 12.4.1 Basic Syntax

Namespaces group related passages:

```whisker
NAMESPACE Merchant

:: Greeting
Welcome to my shop!
+ [Browse wares] -> Inventory
+ [Leave] -> ::Start  // Root namespace

:: Inventory
Here are my wares.

END NAMESPACE
```

**Rules:**
- NAMESPACE keyword followed by identifier
- All passages until END NAMESPACE are prefixed
- Internal references resolve within namespace
- Use `::` prefix for root/global passages

### 12.4.2 Qualified Names

Passages get fully qualified names:

```whisker
NAMESPACE Combat

:: Start           // Becomes Combat::Start
:: Attack          // Becomes Combat::Attack

END NAMESPACE

:: Start           // Global ::Start (no namespace)
+ [Fight] -> Combat::Start
```

**Name Resolution:**

| Reference | From Global | From Combat NS |
|-----------|-------------|----------------|
| `Start` | ::Start | Combat::Start |
| `Combat::Start` | Combat::Start | Combat::Start |
| `::Start` | ::Start | ::Start |

### 12.4.3 Nested Namespaces

Namespaces can be nested:

```whisker
NAMESPACE Game

NAMESPACE Combat
:: Attack          // Game::Combat::Attack
END NAMESPACE

NAMESPACE Dialog
:: Greeting        // Game::Dialog::Greeting
END NAMESPACE

END NAMESPACE
```

**Resolution in Nested Namespaces:**
- Relative references check current namespace first
- Then parent namespaces
- Finally global namespace
- Use `::` for explicit global access

### 12.4.4 Cross-Namespace Navigation

Navigate between namespaces using qualified names:

```whisker
NAMESPACE Town

:: Square
+ [Enter shop] -> Shop::Entrance
+ [Leave town] -> ::Wilderness::Entrance

END NAMESPACE

NAMESPACE Shop

:: Entrance
+ [Return to square] -> Town::Square

END NAMESPACE
```

### 12.4.5 Namespace and Include Interaction

Included files can define namespaces:

```whisker
// merchant.ws
NAMESPACE Merchant
:: Greeting
Hello!
END NAMESPACE

// main.ws
INCLUDE "merchant.ws"

:: Start
+ [Talk to merchant] -> Merchant::Greeting
```

**Conflict Rules:**
- Duplicate qualified passage names are errors
- Same namespace in multiple files merges content
- Conflicts raise WLS-MOD-004

### 12.4.6 Error Codes

| Code | Name | Severity | Description |
|------|------|----------|-------------|
| WLS-MOD-004 | namespace_conflict | error | Duplicate qualified passage name |
| WLS-MOD-007 | invalid_namespace_name | error | Namespace name not valid identifier |
| WLS-MOD-008 | unmatched_end_namespace | error | END NAMESPACE without NAMESPACE |

## 12.5 Complete Example

```whisker
// game.ws - Main game file
@title: Modular Adventure
@author: Whisker Team

INCLUDE "lib/combat.ws"
INCLUDE "lib/inventory.ws"
INCLUDE "chapters/intro.ws"

// Global functions
FUNCTION check_health()
  IF $health <= 0 THEN
    RETURN "dead"
  ELIF $health < 20 THEN
    RETURN "critical"
  ELSE
    RETURN "healthy"
  END
END

:: Start
@tags: start
Welcome, $playerName!
Your status: {= check_health() }

+ [Check inventory] -> Inventory::Main
+ [Enter combat] -> Combat::Arena
+ [Begin adventure] -> Intro::Beginning
```

```whisker
// lib/combat.ws
NAMESPACE Combat

FUNCTION roll_attack(base)
  RETURN base + math.random(1, 6)
END

:: Arena
Prepare for battle!
+ [Attack] -> Attack
+ [Flee] -> ::Start

:: Attack
@onEnter: $lastAttack = roll_attack($strength)
You strike for {$lastAttack} damage!
+ [Continue] -> Arena

END NAMESPACE
```

```whisker
// lib/inventory.ws
NAMESPACE Inventory

:: Main
Your inventory:
{ $hasKey }
- Rusty Key
{/}
{ $gold > 0 }
- Gold: $gold
{/}

+ [Back] -> ::Start

END NAMESPACE
```

## 12.6 Error Code Summary

| Code | Name | Severity | Category |
|------|------|----------|----------|
| WLS-MOD-001 | include_not_found | error | modules |
| WLS-MOD-002 | circular_include | error | modules |
| WLS-MOD-003 | undefined_function | error | modules |
| WLS-MOD-004 | namespace_conflict | error | modules |
| WLS-MOD-005 | stack_overflow | error | modules |
| WLS-MOD-006 | invalid_function_name | error | modules |
| WLS-MOD-007 | invalid_namespace_name | error | modules |
| WLS-MOD-008 | unmatched_end_namespace | error | modules |

## 12.7 Implementation Notes

### 12.7.1 Parser Requirements

The parser must:
1. Recognize INCLUDE, FUNCTION, NAMESPACE, END, RETURN keywords
2. Track current namespace context during parsing
3. Generate fully qualified passage names
4. Build function registry during parsing
5. Handle nested namespace stacks

### 12.7.2 Runtime Requirements

The runtime must:
1. Load and merge included files
2. Maintain function call stack
3. Resolve namespace-qualified passage references
4. Enforce recursion limits
5. Handle local variable scoping in functions

### 12.7.3 Validation Requirements

Validators must check:
1. Include file existence
2. Circular include chains
3. Function existence before calls
4. Namespace-qualified link validity
5. Duplicate qualified passage names
