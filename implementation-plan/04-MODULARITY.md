# Gap 4: Modularity

## Problem Statement

WLS 1.0 lacks mechanisms for code reuse and organization in large projects:

1. **External Includes** - No way to split stories across files
2. **Function Definitions** - No reusable logic blocks
3. **Namespaces** - No passage name scoping for modular content

These features are essential for maintainable, large-scale interactive fiction.

## Goals

1. Implement `INCLUDE` directive for multi-file stories
2. Add function definitions with parameters
3. Create namespace/scope mechanism for passages
4. Update both runtimes to handle modular content
5. Ensure proper error handling for missing modules

## Syntax Reference

### Include Directive
```whisker
INCLUDE "common/dialogs.ws"
INCLUDE "characters/merchant.ws"
INCLUDE "items/*.ws"  // Future: glob patterns

:: Start
-> common/greeting ->
+ [Trade] -> Merchant::StartTrade
```

### Function Definitions
```whisker
FUNCTION roll_dice(sides)
  RETURN {~1|2|3|4|5|6} when sides == 6
  // More complex logic
END

:: Combat
You roll: ${roll_dice(6)}
{roll_dice(20) > 15: hit = true}
```

### Namespaces
```whisker
NAMESPACE Merchant

:: StartTrade  // Full name: Merchant::StartTrade
Welcome to my shop!
+ [Weapons] -> Weapons
+ [Exit] -> ::Start  // :: prefix = root namespace

:: Weapons  // Full name: Merchant::Weapons
Choose a weapon.

END NAMESPACE
```

## Affected Files

### whisker-core
- `lib/whisker/parser/ws_lexer.lua`
- `lib/whisker/parser/ws_parser.lua`
- `lib/whisker/core/loader.lua` (new)
- `lib/whisker/core/engine.lua`
- `lib/whisker/validators/modules.lua` (new)

### whisker-editor-web
- `packages/parser/src/lexer.ts`
- `packages/parser/src/parser.ts`
- `packages/parser/src/ast.ts`
- `packages/story-player/src/StoryPlayer.ts`
- `packages/import/src/formats/WLSImporter.ts`
- `packages/story-validation/src/validators/`

### whisker-language-specification
- `spec/08-MODULES.md` (new)
- `test-corpus/modules/`

---

## Phase 4.1: Specification Update

### Task 4.1.1: Define Include Syntax and Semantics

**Objective:** Formally specify file inclusion.

**Steps:**
1. Define INCLUDE directive syntax
2. Specify path resolution rules
3. Define circular include detection
4. Document include order semantics
5. Specify error handling for missing files

**Deliverables:**
- New `spec/08-MODULES.md` section 8.1

**Estimated tokens:** ~4,000

---

### Task 4.1.2: Define Function Syntax and Semantics

**Objective:** Formally specify function definitions.

**Steps:**
1. Define FUNCTION/END syntax
2. Specify parameter passing (by value)
3. Define RETURN statement
4. Document local variable scope
5. Specify recursion handling

**Deliverables:**
- Updated `spec/08-MODULES.md` section 8.2

**Estimated tokens:** ~5,000

---

### Task 4.1.3: Define Namespace Syntax and Semantics

**Objective:** Formally specify namespaces.

**Steps:**
1. Define NAMESPACE/END NAMESPACE syntax
2. Specify passage name resolution
3. Define `::` prefix for root access
4. Document nested namespace behavior
5. Specify conflict resolution

**Deliverables:**
- Updated `spec/08-MODULES.md` section 8.3

**Estimated tokens:** ~4,000

---

### Task 4.1.4: Create Test Corpus Cases

**Objective:** Define comprehensive test cases.

**Steps:**
1. Create `test-corpus/modules/include-tests.yaml`
2. Create `test-corpus/modules/function-tests.yaml`
3. Create `test-corpus/modules/namespace-tests.yaml`
4. Include error cases
5. Document expected behaviors

**Deliverables:**
- 25+ include test cases
- 25+ function test cases
- 25+ namespace test cases

**Estimated tokens:** ~6,000

---

### Review Checkpoint 4.1

**Verification:**
- [ ] Include syntax fully specified
- [ ] Function syntax fully specified
- [ ] Namespace syntax fully specified
- [ ] Test cases comprehensive
- [ ] Edge cases documented

**Criteria for proceeding:**
- Specification approved
- No circular dependency issues in design
- Clear semantics for all features

---

## Phase 4.2: Include System Implementation

### Task 4.2.1: Lexer Updates for Modules

**Objective:** Add module-related tokens.

**Steps:**
1. Add `INCLUDE` keyword token
2. Add `FUNCTION` keyword token
3. Add `NAMESPACE` keyword token
4. Add `RETURN` keyword token
5. Add `END` keyword token
6. Add `::` scope operator
7. Add lexer tests

**Code locations:**
- `lib/whisker/parser/ws_lexer.lua`
- `packages/parser/src/lexer.ts`

**Estimated tokens:** ~4,000

---

### Task 4.2.2: Include Directive Parsing (Lua)

**Objective:** Parse INCLUDE statements.

**Steps:**
1. Implement `parse_include()` function
2. Handle quoted path strings
3. Create `IncludeNode` AST node
4. Store include list in story metadata
5. Add parser tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~4,000

---

### Task 4.2.3: Include Directive Parsing (TypeScript)

**Objective:** Parse INCLUDE in TypeScript.

**Steps:**
1. Implement `parseInclude()` method
2. Create AST interface
3. Track includes in parse result
4. Add parser tests

**Code location:** `packages/parser/src/parser.ts`

**Estimated tokens:** ~4,000

---

### Task 4.2.4: File Loader (Lua)

**Objective:** Implement file loading and merging.

**Steps:**
1. Create `lib/whisker/core/loader.lua`
2. Implement `load_story()` function
3. Handle recursive includes
4. Detect circular dependencies
5. Merge passage namespaces
6. Add loader tests

**Code location:** `lib/whisker/core/loader.lua`

**Estimated tokens:** ~6,000

---

### Task 4.2.5: File Loader (TypeScript)

**Objective:** Implement file loading for web.

**Steps:**
1. Create async `loadStory()` function
2. Handle URL-based includes
3. Implement fetch-based loading
4. Detect circular dependencies
5. Add loader tests

**Code location:** `packages/import/src/formats/WLSImporter.ts`

**Estimated tokens:** ~6,000

---

### Review Checkpoint 4.2

**Verification:**
- [ ] INCLUDE statements parse correctly
- [ ] File loading works
- [ ] Circular includes detected
- [ ] Passages properly merged
- [ ] Tests pass

**Test command:**
```bash
cd whisker-core && busted tests/wls/test_loader.lua
cd whisker-editor-web && pnpm --filter @writewhisker/import test
```

---

## Phase 4.3: Function Implementation

### Task 4.3.1: Function Parsing (Lua)

**Objective:** Parse function definitions.

**Steps:**
1. Implement `parse_function()` function
2. Parse parameter list
3. Parse function body
4. Handle RETURN statements
5. Create `FunctionNode` AST node
6. Add parser tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~5,000

---

### Task 4.3.2: Function Parsing (TypeScript)

**Objective:** Parse functions in TypeScript.

**Steps:**
1. Implement `parseFunction()` method
2. Parse parameters and body
3. Handle nested structures
4. Add parser tests

**Code location:** `packages/parser/src/parser.ts`

**Estimated tokens:** ~5,000

---

### Task 4.3.3: Function Runtime (Lua)

**Objective:** Execute function calls.

**Steps:**
1. Create function registry in engine
2. Implement call stack for functions
3. Handle parameter binding
4. Implement RETURN value propagation
5. Add stack overflow protection
6. Add runtime tests

**Code location:** `lib/whisker/core/engine.lua`

**Estimated tokens:** ~7,000

---

### Task 4.3.4: Function Runtime (TypeScript)

**Objective:** Execute functions in story player.

**Steps:**
1. Add function registry to player
2. Implement call evaluation
3. Handle local variable scope
4. Implement return handling
5. Add runtime tests

**Code locations:**
- `packages/story-player/src/StoryPlayer.ts`
- `packages/scripting/src/expressions.ts`

**Estimated tokens:** ~7,000

---

### Review Checkpoint 4.3

**Verification:**
- [ ] Functions parse correctly
- [ ] Function calls execute
- [ ] Parameters work correctly
- [ ] Return values propagate
- [ ] Recursion depth limited
- [ ] Tests pass

**Test scenario:**
```whisker
FUNCTION greet(name)
  RETURN "Hello, " + name + "!"
END

:: Start
${greet("Hero")}
```

---

## Phase 4.4: Namespace Implementation

### Task 4.4.1: Namespace Parsing (Lua)

**Objective:** Parse namespace blocks.

**Steps:**
1. Implement `parse_namespace()` function
2. Track current namespace context
3. Prefix passage names automatically
4. Handle END NAMESPACE
5. Add parser tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~5,000

---

### Task 4.4.2: Namespace Parsing (TypeScript)

**Objective:** Parse namespaces in TypeScript.

**Steps:**
1. Implement `parseNamespace()` method
2. Track namespace stack
3. Generate fully qualified names
4. Add parser tests

**Code location:** `packages/parser/src/parser.ts`

**Estimated tokens:** ~5,000

---

### Task 4.4.3: Namespace Resolution (Lua)

**Objective:** Resolve passage references.

**Steps:**
1. Implement qualified name resolution
2. Handle `::` root references
3. Implement relative resolution
4. Update navigation logic
5. Add resolution tests

**Code location:** `lib/whisker/core/engine.lua`

**Estimated tokens:** ~5,000

---

### Task 4.4.4: Namespace Resolution (TypeScript)

**Objective:** Resolve namespaces in player.

**Steps:**
1. Add namespace resolution to player
2. Handle cross-namespace navigation
3. Update link validation
4. Add resolution tests

**Code location:** `packages/story-player/src/StoryPlayer.ts`

**Estimated tokens:** ~5,000

---

### Review Checkpoint 4.4

**Verification:**
- [ ] Namespaces parse correctly
- [ ] Passage names qualified
- [ ] Resolution works both ways
- [ ] Root references work
- [ ] Tests pass

---

## Phase 4.5: Validators and Integration

### Task 4.5.1: Module Validators (Lua)

**Objective:** Validate module usage.

**Steps:**
1. Create `lib/whisker/validators/modules.lua`
2. Add `WLS-MOD-001: include_not_found`
3. Add `WLS-MOD-002: circular_include`
4. Add `WLS-MOD-003: undefined_function`
5. Add `WLS-MOD-004: namespace_conflict`
6. Add validator tests

**Code location:** `lib/whisker/validators/modules.lua`

**Estimated tokens:** ~5,000

---

### Task 4.5.2: Module Validators (TypeScript)

**Objective:** Validate modules in TypeScript.

**Steps:**
1. Create `ModuleValidator.ts`
2. Create `FunctionValidator.ts`
3. Implement same error codes as Lua
4. Add to default validator
5. Add tests

**Code location:** `packages/story-validation/src/validators/`

**Estimated tokens:** ~5,000

---

### Task 4.5.3: Update Link Validators

**Objective:** Update link validation for namespaces.

**Steps:**
1. Update dead link detection
2. Handle namespace-qualified links
3. Update unreachable passage detection
4. Add tests for namespace links

**Code locations:**
- `lib/whisker/validators/links.lua`
- `packages/story-validation/src/validators/DeadLinksValidator.ts`

**Estimated tokens:** ~4,000

---

### Task 4.5.4: Corpus Test Execution

**Objective:** Run all module tests.

**Steps:**
1. Run Lua corpus tests
2. Run TypeScript corpus tests
3. Compare results
4. Fix any failures
5. Document coverage

**Estimated tokens:** ~3,000

---

### Task 4.5.5: Update Examples

**Objective:** Add modularity examples.

**Steps:**
1. Create `examples/advanced/18-includes.ws`
2. Create `examples/advanced/19-functions.ws`
3. Create `examples/advanced/20-namespaces.ws`
4. Create multi-file example project
5. Update example index

**Estimated tokens:** ~5,000

---

### Review Checkpoint 4.5 (Gap 4 Complete)

**Verification:**
- [ ] Include system works end-to-end
- [ ] Functions work in both runtimes
- [ ] Namespaces properly scope passages
- [ ] Validators catch errors
- [ ] Corpus tests pass
- [ ] Examples work

**Final metrics:**
| Metric | Before | After |
|--------|--------|-------|
| Multi-file support | No | Yes |
| Reusable functions | No | Yes |
| Passage scoping | Global | Namespace |
| New error codes | 64 | 68 |
| New examples | 17 | 20 |

**New error codes:**
- WLS-MOD-001: include_not_found
- WLS-MOD-002: circular_include
- WLS-MOD-003: undefined_function
- WLS-MOD-004: namespace_conflict

**Sign-off requirements:**
- All modularity features complete
- Large story organization possible
- Ready for Gap 5
