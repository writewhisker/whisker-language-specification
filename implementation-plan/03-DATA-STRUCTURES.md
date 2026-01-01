# Gap 3: Data Structures

## Problem Statement

WLS 1.0 currently supports only scalar variables (numbers, strings, booleans). Advanced interactive fiction often requires:

1. **Lists/Sets** - Ink-style enumerated types for tracking states
2. **Arrays** - Indexed collections for inventories, sequences
3. **Maps/Objects** - Key-value storage for complex state

Both whisker-core and whisker-editor-web need consistent implementations.

## Goals

1. Define syntax for collection types
2. Implement in both Lua and TypeScript runtimes
3. Add parser support for collection literals and access
4. Create validators for collection operations
5. Ensure save/load compatibility

## Syntax Reference

### Lists (Enumerated Sets)
```whisker
LIST moods = happy, sad, angry, neutral
LIST inventory = (sword), (shield), potion  // parentheses = initially active

{mood: neutral}      // Set value
{mood == happy}      // Test value
{+sword}            // Add to list
{-sword}            // Remove from list
{inventory ? sword}  // Check if contains
```

### Arrays
```whisker
ARRAY items = ["sword", "shield", "potion"]
ARRAY scores = [100, 95, 87, 92]

${items[0]}         // Access by index
${#items}           // Length
{items += "bow"}    // Append
{items[1] = "axe"}  // Replace at index
```

### Maps
```whisker
MAP player = { name: "Hero", health: 100, level: 1 }

${player.name}       // Dot access
${player["health"]}  // Bracket access
{player.level += 1}  // Modify property
{player.mana = 50}   // Add property
```

## Affected Files

### whisker-core
- `lib/whisker/parser/ws_lexer.lua`
- `lib/whisker/parser/ws_parser.lua`
- `lib/whisker/core/variables.lua`
- `lib/whisker/core/engine.lua`
- `lib/whisker/validators/types.lua`

### whisker-editor-web
- `packages/parser/src/lexer.ts`
- `packages/parser/src/parser.ts`
- `packages/parser/src/ast.ts`
- `packages/story-player/src/StoryPlayer.ts`
- `packages/scripting/src/expressions.ts`
- `packages/story-validation/src/validators/`

### whisker-language-specification
- `spec/04-VARIABLES.md`
- `test-corpus/variables/`

---

## Phase 3.1: Specification Update

### Task 3.1.1: Define List Syntax and Semantics

**Objective:** Formally specify LIST type behavior.

**Steps:**
1. Define LIST declaration syntax
2. Specify initial value syntax (parentheses notation)
3. Define list operations (+, -, ?, toggle)
4. Specify comparison operators
5. Document edge cases (empty list, duplicate values)

**Deliverables:**
- Updated `spec/04-VARIABLES.md` section 4.5

**Estimated tokens:** ~4,000

---

### Task 3.1.2: Define Array Syntax and Semantics

**Objective:** Formally specify ARRAY type behavior.

**Steps:**
1. Define ARRAY declaration syntax with literals
2. Specify index access syntax (0-based)
3. Define array operations (push, pop, length, splice)
4. Specify iteration patterns
5. Document bounds checking behavior

**Deliverables:**
- Updated `spec/04-VARIABLES.md` section 4.6

**Estimated tokens:** ~4,000

---

### Task 3.1.3: Define Map Syntax and Semantics

**Objective:** Formally specify MAP type behavior.

**Steps:**
1. Define MAP declaration syntax with object literals
2. Specify dot and bracket access syntax
3. Define map operations (set, delete, has, keys)
4. Specify nested access behavior
5. Document serialization format

**Deliverables:**
- Updated `spec/04-VARIABLES.md` section 4.7

**Estimated tokens:** ~4,000

---

### Task 3.1.4: Create Test Corpus Cases

**Objective:** Define comprehensive test cases.

**Steps:**
1. Create `test-corpus/variables/list-tests.yaml`
2. Create `test-corpus/variables/array-tests.yaml`
3. Create `test-corpus/variables/map-tests.yaml`
4. Include operations, edge cases, errors
5. Document expected behaviors

**Deliverables:**
- 30+ LIST test cases
- 30+ ARRAY test cases
- 30+ MAP test cases

**Estimated tokens:** ~6,000

---

### Review Checkpoint 3.1

**Verification:**
- [ ] LIST syntax fully specified
- [ ] ARRAY syntax fully specified
- [ ] MAP syntax fully specified
- [ ] Test cases comprehensive
- [ ] Edge cases documented

**Criteria for proceeding:**
- Specification approved
- No ambiguities in syntax
- Test cases cover all operations

---

## Phase 3.2: Lexer Updates

### Task 3.2.1: Add Collection Tokens (Lua)

**Objective:** Recognize collection-related tokens.

**Steps:**
1. Add `LIST` keyword token
2. Add `ARRAY` keyword token
3. Add `MAP` keyword token
4. Add bracket tokens `[`, `]`
5. Add collection operators `+=`, `-=`
6. Add lexer tests

**Code location:** `lib/whisker/parser/ws_lexer.lua`

**Estimated tokens:** ~3,000

---

### Task 3.2.2: Add Collection Tokens (TypeScript)

**Objective:** Mirror Lua token changes.

**Steps:**
1. Add `TokenType.List`
2. Add `TokenType.Array`
3. Add `TokenType.Map`
4. Add bracket and brace handling
5. Add compound assignment operators
6. Add lexer tests

**Code location:** `packages/parser/src/lexer.ts`

**Estimated tokens:** ~3,000

---

### Review Checkpoint 3.2

**Verification:**
- [ ] All new tokens recognized
- [ ] Lexer tests pass
- [ ] Parity between Lua and TypeScript

**Test command:**
```bash
cd whisker-core && busted tests/wls/test_lexer.lua
cd whisker-editor-web && pnpm --filter @writewhisker/parser test
```

---

## Phase 3.3: Parser Implementation

### Task 3.3.1: Parse LIST Declarations (Lua)

**Objective:** Parse LIST statements into AST.

**Steps:**
1. Implement `parse_list_declaration()` function
2. Parse list value enumerations
3. Handle initial value markers
4. Create `ListDeclarationNode`
5. Add parser tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~5,000

---

### Task 3.3.2: Parse LIST Declarations (TypeScript)

**Objective:** Parse LIST statements in TypeScript.

**Steps:**
1. Implement `parseListDeclaration()` method
2. Mirror Lua implementation
3. Create AST node interface
4. Add parser tests

**Code location:** `packages/parser/src/parser.ts`

**Estimated tokens:** ~5,000

---

### Task 3.3.3: Parse ARRAY Declarations (Lua)

**Objective:** Parse ARRAY statements into AST.

**Steps:**
1. Implement `parse_array_declaration()` function
2. Parse array literal syntax
3. Handle typed arrays (future)
4. Create `ArrayDeclarationNode`
5. Add parser tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~5,000

---

### Task 3.3.4: Parse ARRAY Declarations (TypeScript)

**Objective:** Parse ARRAY in TypeScript.

**Steps:**
1. Implement `parseArrayDeclaration()` method
2. Parse bracket notation
3. Handle nested arrays
4. Add parser tests

**Code location:** `packages/parser/src/parser.ts`

**Estimated tokens:** ~5,000

---

### Task 3.3.5: Parse MAP Declarations (Lua)

**Objective:** Parse MAP statements into AST.

**Steps:**
1. Implement `parse_map_declaration()` function
2. Parse object literal syntax
3. Handle string and identifier keys
4. Create `MapDeclarationNode`
5. Add parser tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~5,000

---

### Task 3.3.6: Parse MAP Declarations (TypeScript)

**Objective:** Parse MAP in TypeScript.

**Steps:**
1. Implement `parseMapDeclaration()` method
2. Parse brace notation
3. Handle nested maps
4. Add parser tests

**Code location:** `packages/parser/src/parser.ts`

**Estimated tokens:** ~5,000

---

### Task 3.3.7: Parse Collection Access Expressions

**Objective:** Parse index and property access.

**Steps:**
1. Add `parse_member_expression()` for dot access
2. Add `parse_computed_expression()` for bracket access
3. Handle chained access (`a.b[0].c`)
4. Add expression tests

**Code locations:**
- `lib/whisker/parser/ws_parser.lua`
- `packages/parser/src/parser.ts`

**Estimated tokens:** ~6,000

---

### Review Checkpoint 3.3

**Verification:**
- [ ] LIST declarations parse correctly
- [ ] ARRAY declarations parse correctly
- [ ] MAP declarations parse correctly
- [ ] Access expressions work
- [ ] Parser tests pass
- [ ] Parity between Lua and TypeScript

**Criteria for proceeding:**
- All declaration types parse
- Access expressions handle chaining

---

## Phase 3.4: Runtime Implementation

### Task 3.4.1: LIST Runtime (Lua)

**Objective:** Implement LIST operations in runtime.

**Steps:**
1. Create `List` class/module
2. Implement add, remove, toggle operations
3. Implement contains check
4. Handle serialization
5. Add runtime tests

**Code location:** `lib/whisker/core/variables.lua`

**Estimated tokens:** ~6,000

---

### Task 3.4.2: LIST Runtime (TypeScript)

**Objective:** Implement LIST in story player.

**Steps:**
1. Create `WLSList` class
2. Implement all operations
3. Add to expression evaluator
4. Ensure serialization
5. Add runtime tests

**Code locations:**
- `packages/story-player/src/StoryPlayer.ts`
- `packages/scripting/src/expressions.ts`

**Estimated tokens:** ~6,000

---

### Task 3.4.3: ARRAY Runtime (Lua)

**Objective:** Implement ARRAY operations.

**Steps:**
1. Create array wrapper type
2. Implement index access (1-based in Lua, 0-based in WLS)
3. Implement push, pop, splice
4. Handle bounds checking
5. Add runtime tests

**Code location:** `lib/whisker/core/variables.lua`

**Estimated tokens:** ~6,000

---

### Task 3.4.4: ARRAY Runtime (TypeScript)

**Objective:** Implement ARRAY in story player.

**Steps:**
1. Create `WLSArray` wrapper
2. Implement all array methods
3. Add bounds validation
4. Ensure serialization
5. Add runtime tests

**Code locations:**
- `packages/story-player/src/StoryPlayer.ts`
- `packages/scripting/src/expressions.ts`

**Estimated tokens:** ~6,000

---

### Task 3.4.5: MAP Runtime (Lua)

**Objective:** Implement MAP operations.

**Steps:**
1. Create map wrapper (over Lua table)
2. Implement get, set, delete
3. Implement has, keys, values
4. Handle nested access
5. Add runtime tests

**Code location:** `lib/whisker/core/variables.lua`

**Estimated tokens:** ~6,000

---

### Task 3.4.6: MAP Runtime (TypeScript)

**Objective:** Implement MAP in story player.

**Steps:**
1. Create `WLSMap` class
2. Implement all operations
3. Add deep clone for serialization
4. Handle prototype safety
5. Add runtime tests

**Code locations:**
- `packages/story-player/src/StoryPlayer.ts`
- `packages/scripting/src/expressions.ts`

**Estimated tokens:** ~6,000

---

### Review Checkpoint 3.4

**Verification:**
- [ ] LIST operations work in both runtimes
- [ ] ARRAY operations work in both runtimes
- [ ] MAP operations work in both runtimes
- [ ] Serialization preserves state
- [ ] Runtime tests pass

**Test scenario:**
```whisker
:: Start
LIST inventory = sword, (shield)
ARRAY scores = [100, 95]
MAP player = { name: "Hero" }

{+sword}
{scores += 87}
{player.level = 1}

Your inventory: $inventory.
Scores: ${#scores} entries.
Player: ${player.name}
```

---

## Phase 3.5: Validators and Integration

### Task 3.5.1: Collection Type Validators (Lua)

**Objective:** Validate collection usage.

**Steps:**
1. Add `WLS-TYP-006: invalid_list_operation`
2. Add `WLS-TYP-007: array_index_invalid`
3. Add `WLS-TYP-008: map_key_invalid`
4. Implement type checking for operations
5. Add validator tests

**Code location:** `lib/whisker/validators/types.lua`

**Estimated tokens:** ~5,000

---

### Task 3.5.2: Collection Type Validators (TypeScript)

**Objective:** Validate collections in TypeScript.

**Steps:**
1. Create `CollectionValidator.ts`
2. Implement same error codes as Lua
3. Add to default validator
4. Add tests

**Code location:** `packages/story-validation/src/validators/CollectionValidator.ts`

**Estimated tokens:** ~5,000

---

### Task 3.5.3: Update Story Model (TypeScript)

**Objective:** Add collection variable types to model.

**Steps:**
1. Update `Variable` type in story-models
2. Add collection value serialization
3. Update import/export for collections
4. Add model tests

**Code location:** `packages/story-models/src/Variable.ts`

**Estimated tokens:** ~4,000

---

### Task 3.5.4: Corpus Test Execution

**Objective:** Run all collection tests.

**Steps:**
1. Run Lua corpus tests
2. Run TypeScript corpus tests
3. Compare results
4. Fix any failures
5. Document coverage

**Estimated tokens:** ~3,000

---

### Task 3.5.5: Update Examples

**Objective:** Add collection examples.

**Steps:**
1. Create `examples/advanced/15-lists.ws`
2. Create `examples/advanced/16-arrays.ws`
3. Create `examples/advanced/17-maps.ws`
4. Update example index

**Estimated tokens:** ~4,000

---

### Review Checkpoint 3.5 (Gap 3 Complete)

**Verification:**
- [ ] All collection types implemented
- [ ] Validators catch type errors
- [ ] Corpus tests pass
- [ ] Examples work correctly
- [ ] Documentation updated

**Final metrics:**
| Metric | Before | After |
|--------|--------|-------|
| Variable types | 3 (num, str, bool) | 6 (+list, array, map) |
| New error codes | 61 | 64 |
| New examples | 14 | 17 |

**Sign-off requirements:**
- Collections work in both runtimes
- Type safety enforced
- Ready for Gap 4
