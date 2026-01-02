# Phase 2: Flow Control Verification

## Pre-Implementation Checks

- [ ] Read existing flow control in `spec/02-FLOW-CONTROL.md`
- [ ] Review parser grammar in `packages/parser/src/whisker.pegjs`
- [ ] Check runtime in `packages/story-player/src/StoryPlayer.ts`
- [ ] Review Lua parser in `lib/whisker/parser/ws_parser.lua`

## Implementation Verification

### Specification
- [ ] Gather point syntax documented
- [ ] Tunnel syntax documented
- [ ] Inline conditional syntax documented
- [ ] Once-only block syntax documented
- [ ] Examples provided for each feature

### Parser Verification

**TypeScript:**
```bash
cd ~/code/github.com/writewhisker/whisker-editor-web

# Test gather point parsing
echo ':: Start
+ [A] Text A
+ [B] Text B
-
After gather.' | pnpm --filter @writewhisker/parser test:parse

# Test tunnel parsing
echo ':: Start
-> Sub ->
After.' | pnpm --filter @writewhisker/parser test:parse
```

**Lua:**
```bash
cd ~/code/github.com/writewhisker/whisker-core

# Test parsing
busted spec/parser/flow_control_spec.lua
```

### Runtime Verification

**Tunnel Call Stack:**
```bash
# TypeScript
pnpm --filter @writewhisker/story-player test -- --grep "tunnel"

# Lua
busted spec/runtime/tunnel_spec.lua
```

**Test Cases:**
- [ ] Simple tunnel call and return
- [ ] Nested tunnel calls (3 levels)
- [ ] Tunnel with content
- [ ] Tunnel return from choice

**Gather Point Execution:**
- [ ] Single-level gather
- [ ] Nested gathers (2 levels)
- [ ] Gather after all choices
- [ ] Gather with trailing content

**Inline Conditionals:**
- [ ] Simple true/false
- [ ] Nested conditionals
- [ ] In choice text
- [ ] In passage content

**Once-Only:**
- [ ] First visit shows text
- [ ] Second visit hides text
- [ ] Multiple once blocks
- [ ] Once in different passages

## Cross-Platform Parity

### Parser Output Comparison
```bash
# Parse same input in both platforms
INPUT=':: Start
+ [A]
  Answer A
+ [B]
  Answer B
-
After gather
+ [Continue] -> End'

# TypeScript
echo "$INPUT" | node packages/parser/bin/parse.js > /tmp/ts-ast.json

# Lua
echo "$INPUT" | lua -e "require('whisker.parser').parse_stdin()" > /tmp/lua-ast.json

# Compare structure
diff /tmp/ts-ast.json /tmp/lua-ast.json
```

### Runtime Behavior Comparison
For each test story:
- [ ] Same passage sequence
- [ ] Same variable states
- [ ] Same choice availability
- [ ] Same text output

## Acceptance Criteria

1. **Gather Points**
   - [ ] Parser recognizes `-` as gather
   - [ ] Nested gathers work
   - [ ] Runtime collects all paths
   - [ ] Content after gather executes

2. **Tunnels**
   - [ ] Parser recognizes `-> X ->`
   - [ ] Parser recognizes `->->`
   - [ ] Runtime maintains call stack
   - [ ] Return continues correctly
   - [ ] Nested tunnels work (3+ levels)

3. **Inline Conditionals**
   - [ ] Parser recognizes `{cond ? a | b}`
   - [ ] Works in content
   - [ ] Works in choices
   - [ ] Nesting works

4. **Once-Only**
   - [ ] Parser recognizes `{once}...{/once}`
   - [ ] Runtime tracks seen blocks
   - [ ] Works across visits
   - [ ] Persists in save state

5. **Cross-Platform**
   - [ ] TypeScript tests pass
   - [ ] Lua tests pass
   - [ ] Corpus tests pass
   - [ ] Identical behavior verified

## Test Corpus Additions

Required test files in `test-corpus/flow-control/`:
- [ ] `gather-simple.yaml`
- [ ] `gather-nested.yaml`
- [ ] `gather-complex.yaml`
- [ ] `tunnel-simple.yaml`
- [ ] `tunnel-nested.yaml`
- [ ] `tunnel-with-content.yaml`
- [ ] `inline-conditional.yaml`
- [ ] `once-only.yaml`
- [ ] `combined-features.yaml`

## Edge Cases

- [ ] Empty gather (just `-`)
- [ ] Gather with no preceding choices
- [ ] Tunnel to nonexistent passage (error)
- [ ] Return without tunnel call (error)
- [ ] Deeply nested tunnels (5+ levels)
- [ ] Inline conditional with complex expression
- [ ] Once block spanning multiple lines
- [ ] Once block in choice
