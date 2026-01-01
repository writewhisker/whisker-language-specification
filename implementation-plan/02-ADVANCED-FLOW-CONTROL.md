# Gap 2: Advanced Flow Control

## Problem Statement

WLS 1.0 specifies but does not implement two advanced flow control features from Ink:

1. **Gather Points** - Allow branches to reconverge with `-` syntax
2. **Tunnels** - Subroutine-style passages with `->passage->` and `<-`

Both features are critical for reducing passage explosion and enabling reusable content.

## Goals

1. Implement gather points in both parsers and runtimes
2. Implement tunnels in both parsers and runtimes
3. Update validators to handle new syntax
4. Add comprehensive tests
5. Update specification documentation

## Syntax Reference

### Gather Points
```whisker
:: Conversation
"What do you think?"
+ [Agree] She smiled.
+ [Disagree] She frowned.
+ [Stay silent] She waited.
- "Either way, we should continue."  // Gather point
+ [Ask another question] -> AnotherQuestion
- The conversation ends.  // Another gather point
```

### Tunnels
```whisker
:: Morning
You wake up.
-> BrushTeeth ->    // Tunnel call
-> EatBreakfast ->  // Another tunnel
Ready for the day!
+ [Go to work] -> Work

:: BrushTeeth
You brush your teeth.
<-  // Return to caller

:: EatBreakfast
* [Cereal] Quick and easy.
* [Eggs] Delicious but slow.
- <-  // Return after gather
```

## Affected Files

### whisker-core
- `lib/whisker/parser/ws_lexer.lua`
- `lib/whisker/parser/ws_parser.lua`
- `lib/whisker/core/engine.lua`
- `lib/whisker/core/control_flow.lua`
- `lib/whisker/validators/flow.lua`

### whisker-editor-web
- `packages/parser/src/lexer.ts`
- `packages/parser/src/parser.ts`
- `packages/parser/src/ast.ts`
- `packages/story-player/src/StoryPlayer.ts`
- `packages/story-validation/src/validators/`

### whisker-language-specification
- `spec/05-CONTROL_FLOW.md`
- `test-corpus/flow/`

---

## Phase 2.1: Specification Update

### Task 2.1.1: Draft Gather Points Specification

**Objective:** Formally specify gather point syntax and semantics.

**Steps:**
1. Define gather point syntax (`-` at line start)
2. Specify nesting rules (gather levels)
3. Define scope and visibility
4. Document interaction with choices
5. Provide examples

**Deliverables:**
- Updated `spec/05-CONTROL_FLOW.md` section 5.6

**Estimated tokens:** ~4,000

---

### Task 2.1.2: Draft Tunnels Specification

**Objective:** Formally specify tunnel syntax and semantics.

**Steps:**
1. Define tunnel call syntax (`->passage->`)
2. Define return syntax (`<-`)
3. Specify call stack behavior
4. Define parameter passing (future consideration)
5. Document error conditions

**Deliverables:**
- Updated `spec/05-CONTROL_FLOW.md` section 5.7

**Estimated tokens:** ~4,000

---

### Task 2.1.3: Define AST Node Types

**Objective:** Design AST representation for new features.

**Steps:**
1. Define `GatherNode` type
2. Define `TunnelCallNode` type
3. Define `TunnelReturnNode` type
4. Update grammar EBNF
5. Document node relationships

**Deliverables:**
- Updated `spec/GRAMMAR.ebnf`
- AST type definitions

**Estimated tokens:** ~3,000

---

### Task 2.1.4: Create Test Corpus Cases

**Objective:** Define test cases before implementation.

**Steps:**
1. Create `test-corpus/flow/gather-tests.yaml`
2. Create `test-corpus/flow/tunnel-tests.yaml`
3. Include edge cases
4. Include error cases
5. Document expected behavior

**Deliverables:**
- 20+ gather point test cases
- 20+ tunnel test cases

**Estimated tokens:** ~5,000

---

### Review Checkpoint 2.1

**Verification:**
- [ ] Gather points fully specified
- [ ] Tunnels fully specified
- [ ] EBNF grammar updated
- [ ] Test cases defined
- [ ] No ambiguities in specification

**Criteria for proceeding:**
- Specification reviewed and approved
- Test cases cover all edge cases
- AST design finalized

---

## Phase 2.2: Parser Implementation

### Task 2.2.1: Lexer Updates (Lua)

**Objective:** Add tokens for gather points and tunnels.

**Steps:**
1. Add `GATHER` token (`-` at line start with specific context)
2. Add `TUNNEL_CALL` token (`->identifier->`)
3. Add `TUNNEL_RETURN` token (`<-`)
4. Update token precedence
5. Add lexer tests

**Code location:** `lib/whisker/parser/ws_lexer.lua`

**Estimated tokens:** ~4,000

---

### Task 2.2.2: Lexer Updates (TypeScript)

**Objective:** Add tokens in TypeScript lexer.

**Steps:**
1. Mirror Lua token changes
2. Add `TokenType.Gather`
3. Add `TokenType.TunnelCall`
4. Add `TokenType.TunnelReturn`
5. Add lexer tests

**Code location:** `packages/parser/src/lexer.ts`

**Estimated tokens:** ~4,000

---

### Task 2.2.3: Gather Point Parsing (Lua)

**Objective:** Parse gather points into AST.

**Steps:**
1. Implement `parse_gather()` function
2. Track gather nesting level
3. Integrate with choice parsing
4. Handle gather scope
5. Add parser tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~6,000

---

### Task 2.2.4: Gather Point Parsing (TypeScript)

**Objective:** Parse gather points in TypeScript.

**Steps:**
1. Implement `parseGather()` method
2. Track nesting with stack
3. Integrate with choice parsing
4. Validate gather placement
5. Add parser tests

**Code location:** `packages/parser/src/parser.ts`

**Estimated tokens:** ~6,000

---

### Task 2.2.5: Tunnel Parsing (Lua)

**Objective:** Parse tunnel calls and returns.

**Steps:**
1. Implement `parse_tunnel_call()` function
2. Implement `parse_tunnel_return()` function
3. Validate tunnel target exists
4. Handle inline tunnel calls
5. Add parser tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~5,000

---

### Task 2.2.6: Tunnel Parsing (TypeScript)

**Objective:** Parse tunnels in TypeScript.

**Steps:**
1. Implement `parseTunnelCall()` method
2. Implement `parseTunnelReturn()` method
3. Add validation
4. Handle edge cases
5. Add parser tests

**Code location:** `packages/parser/src/parser.ts`

**Estimated tokens:** ~5,000

---

### Review Checkpoint 2.2

**Verification:**
- [ ] All new tokens recognized
- [ ] Gather points parse correctly
- [ ] Tunnels parse correctly
- [ ] Parser tests pass
- [ ] Parity between Lua and TypeScript

**Test command:**
```bash
cd whisker-core && busted tests/wls/test_flow.lua
cd whisker-editor-web && pnpm --filter @writewhisker/parser test
```

**Criteria for proceeding:**
- All syntax parses correctly
- AST structure matches specification

---

## Phase 2.3: Runtime Implementation

### Task 2.3.1: Gather Point Execution (Lua)

**Objective:** Execute gather points in runtime.

**Steps:**
1. Update `control_flow.lua` to handle gathers
2. Track current gather level
3. Implement gather scope resolution
4. Handle choice completion to gather
5. Add runtime tests

**Code location:** `lib/whisker/core/control_flow.lua`

**Estimated tokens:** ~7,000

---

### Task 2.3.2: Gather Point Execution (TypeScript)

**Objective:** Execute gather points in story player.

**Steps:**
1. Update `StoryPlayer.ts` for gathers
2. Track gather state
3. Implement gather continuation
4. Handle choice-to-gather flow
5. Add runtime tests

**Code location:** `packages/story-player/src/StoryPlayer.ts`

**Estimated tokens:** ~7,000

---

### Task 2.3.3: Tunnel Call Stack (Lua)

**Objective:** Implement tunnel call/return mechanism.

**Steps:**
1. Add call stack to engine state
2. Implement `tunnel_call()` function
3. Implement `tunnel_return()` function
4. Handle stack overflow protection
5. Add runtime tests

**Code location:** `lib/whisker/core/engine.lua`

**Estimated tokens:** ~6,000

---

### Task 2.3.4: Tunnel Call Stack (TypeScript)

**Objective:** Implement tunnels in story player.

**Steps:**
1. Add call stack to player state
2. Implement tunnel navigation
3. Implement return handling
4. Add stack depth limit
5. Add runtime tests

**Code location:** `packages/story-player/src/StoryPlayer.ts`

**Estimated tokens:** ~6,000

---

### Task 2.3.5: State Persistence for Tunnels

**Objective:** Ensure tunnel state survives save/load.

**Steps:**
1. Add call stack to save format
2. Restore call stack on load
3. Handle version migration
4. Add save/load tests

**Code locations:**
- `lib/whisker/core/game_state.lua`
- `packages/story-player/src/StoryPlayer.ts`

**Estimated tokens:** ~4,000

---

### Review Checkpoint 2.3

**Verification:**
- [ ] Gather points execute correctly
- [ ] Tunnels call and return work
- [ ] State persistence works
- [ ] No infinite loops possible
- [ ] Runtime tests pass

**Test scenario:**
```whisker
:: Start
-> Greeting ->
You feel welcomed.
+ [Continue] -> END

:: Greeting
{~|Hello!|Hi there!|Greetings!}
<-
```

**Criteria for proceeding:**
- Full execution working
- Save/load preserves tunnel state

---

## Phase 2.4: Validator Updates

### Task 2.4.1: Gather Point Validation (Lua)

**Objective:** Validate gather point usage.

**Steps:**
1. Add `WLS-FLW-007: invalid_gather_placement`
2. Add `WLS-FLW-008: unreachable_gather`
3. Update `flow.lua` validator
4. Add validator tests

**Code location:** `lib/whisker/validators/flow.lua`

**Estimated tokens:** ~4,000

---

### Task 2.4.2: Tunnel Validation (Lua)

**Objective:** Validate tunnel usage.

**Steps:**
1. Add `WLS-FLW-009: tunnel_target_not_found`
2. Add `WLS-FLW-010: missing_tunnel_return`
3. Add `WLS-FLW-011: orphan_tunnel_return`
4. Update validators
5. Add validator tests

**Code location:** `lib/whisker/validators/flow.lua`

**Estimated tokens:** ~5,000

---

### Task 2.4.3: Gather Point Validation (TypeScript)

**Objective:** Add gather validators in TypeScript.

**Steps:**
1. Create `GatherValidator.ts`
2. Implement same error codes as Lua
3. Add to default validator
4. Add tests

**Code location:** `packages/story-validation/src/validators/GatherValidator.ts`

**Estimated tokens:** ~4,000

---

### Task 2.4.4: Tunnel Validation (TypeScript)

**Objective:** Add tunnel validators in TypeScript.

**Steps:**
1. Create `TunnelValidator.ts`
2. Implement same error codes as Lua
3. Add to default validator
4. Add tests

**Code location:** `packages/story-validation/src/validators/TunnelValidator.ts`

**Estimated tokens:** ~5,000

---

### Review Checkpoint 2.4

**Verification:**
- [ ] All new error codes implemented
- [ ] Validators catch invalid usage
- [ ] Parity between Lua and TypeScript
- [ ] Validator tests pass

**Error codes added:**
- WLS-FLW-007: invalid_gather_placement
- WLS-FLW-008: unreachable_gather
- WLS-FLW-009: tunnel_target_not_found
- WLS-FLW-010: missing_tunnel_return
- WLS-FLW-011: orphan_tunnel_return

**Criteria for proceeding:**
- All validators implemented
- Error messages helpful

---

## Phase 2.5: Integration and Documentation

### Task 2.5.1: Corpus Test Execution

**Objective:** Run all gather/tunnel tests.

**Steps:**
1. Run Lua corpus tests
2. Run TypeScript corpus tests
3. Compare results
4. Fix any failures
5. Document coverage

**Estimated tokens:** ~3,000

---

### Task 2.5.2: Update Examples

**Objective:** Add gather/tunnel examples to spec.

**Steps:**
1. Create `examples/advanced/13-gather-points.ws`
2. Create `examples/advanced/14-tunnels.ws`
3. Update example index
4. Add to README

**Estimated tokens:** ~4,000

---

### Task 2.5.3: Update Specification Document

**Objective:** Finalize specification sections.

**Steps:**
1. Review and polish section 5.6 (Gather Points)
2. Review and polish section 5.7 (Tunnels)
3. Add to quick reference
4. Update version notes

**Estimated tokens:** ~3,000

---

### Task 2.5.4: Migration Guide

**Objective:** Help users adopt new features.

**Steps:**
1. Document when to use gather points
2. Document when to use tunnels
3. Provide before/after examples
4. Add to docs/MIGRATION_GUIDE.md

**Estimated tokens:** ~3,000

---

### Review Checkpoint 2.5 (Gap 2 Complete)

**Verification:**
- [ ] All corpus tests pass
- [ ] Examples work correctly
- [ ] Specification complete
- [ ] Migration guide written
- [ ] No regressions

**Final metrics:**
| Metric | Before | After |
|--------|--------|-------|
| Gather points | Not implemented | Complete |
| Tunnels | Not implemented | Complete |
| New error codes | 56 | 61 |
| New examples | 12 | 14 |

**Sign-off requirements:**
- Features complete in both repos
- Documentation updated
- Ready to proceed to Gap 3
