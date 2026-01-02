# Whisker Core (Lua) - Implementation Context

## Repository

```
~/code/github.com/writewhisker/whisker-core
```

## Overview

Lua reference implementation of WLS. Designed for embedding in games and applications using Love2D, Defold, or standalone Lua.

## Directory Structure

```
whisker-core/
├── lib/whisker/
│   ├── parser/
│   │   ├── ws_parser.lua      # Main parser
│   │   ├── lexer.lua          # Tokenizer
│   │   └── ast.lua            # AST types
│   ├── runtime/
│   │   ├── player.lua         # Story player
│   │   ├── state.lua          # Runtime state
│   │   └── evaluator.lua      # Expression evaluation
│   ├── validators/            # (WLS 1.0 addition)
│   │   ├── init.lua
│   │   └── *.lua
│   └── init.lua               # Main module
├── spec/                      # Tests (busted)
│   ├── parser/
│   ├── runtime/
│   └── validators/
└── bin/
    └── whisker                # CLI
```

## Key Patterns

### Parser
```lua
local ws_parser = require("whisker.parser.ws_parser")

local ast, err = ws_parser.parse(source)
if err then
  print("Parse error:", err.message)
end
```

### Runtime
```lua
local player = require("whisker.runtime.player")

local state = player.new(story)
local content = state:get_content()
local choices = state:get_choices()
state:choose(1)
```

### Validators
```lua
local validators = require("whisker.validators")

local errors = validators.validate(story)
for _, err in ipairs(errors) do
  print(err.code, err.message)
end
```

## Running Tests

```bash
# All tests
busted

# Specific file
busted spec/parser/ws_parser_spec.lua

# With coverage
busted --coverage
```

## Error Code Format

```lua
-- lib/whisker/validators/error_codes.lua
local ERROR_CODES = {
  ["WLS-STR-001"] = {
    id = "missing_start_passage",
    severity = "error",
    message = "Story must have a 'Start' passage"
  },
  -- ...
}
```

## Implementation Notes

### Cross-Platform Parity
- Must match TypeScript behavior exactly
- Use shared test corpus for verification
- Error codes and messages must be identical

### Lua Idioms
- Use `local` for all variables
- Return module tables
- Use metatables sparingly
- Prefer explicit nil checks

### Memory Management
- Avoid creating tables in hot paths
- Reuse tables where possible
- Watch for circular references

## Common Tasks

### Add a Validator
1. Create `lib/whisker/validators/my_validator.lua`
2. Add to `lib/whisker/validators/init.lua`
3. Create `spec/validators/my_validator_spec.lua`
4. Add corpus tests

### Add Parser Feature
1. Update `lib/whisker/parser/ws_parser.lua`
2. Add AST type in `lib/whisker/parser/ast.lua`
3. Create tests in `spec/parser/`
4. Update runtime if needed

### Add Runtime Feature
1. Update `lib/whisker/runtime/player.lua` or `state.lua`
2. Create tests in `spec/runtime/`
3. Verify with corpus tests

## Dependencies

- Lua 5.1+ or LuaJIT
- busted (testing)
- luacov (coverage)

## Phase-Specific Notes

### Phase 1: Validation
Create `lib/whisker/validators/` with:
- `init.lua` - Main entry point
- `error_codes.lua` - All WLS error codes
- Category files (structural.lua, links.lua, etc.)

### Phase 2: Flow Control
Update:
- Parser for gather/tunnel syntax
- Runtime for call stack
- State for once-only tracking

### Phase 3: Tooling
Create:
- `lib/whisker/import/` - Format importers
- `lib/whisker/export/` - Format exporters

### Phase 6: WLS 2.0
Major updates:
- Thread scheduler in runtime
- LIST state machine operators
- Timed content system
- External function binding
