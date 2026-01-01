# WLS Source Map Format

**Date:** 2026-01-01

## Overview

This document specifies the source map format for WLS parsers. Source maps enable:

1. Error reporting with accurate locations
2. Debugging with source-level stepping
3. Editor integration for navigation

## Design Goals

1. **Lightweight**: Minimal overhead for parsing
2. **Compatible**: Follow v3 source map conventions where applicable
3. **Embedded**: Store in AST nodes, not separate file
4. **Queryable**: Efficient lookup by position

## Location Structure

### SourceLocation

A single point in source code:

```typescript
interface SourceLocation {
  line: number;    // 1-based line number
  column: number;  // 0-based column (character offset in line)
  offset: number;  // 0-based byte offset from start
}
```

```lua
-- Lua
{
  line = 1,    -- 1-based
  column = 0,  -- 0-based
  offset = 0   -- 0-based byte offset
}
```

### SourceSpan

A range in source code:

```typescript
interface SourceSpan {
  start: SourceLocation;
  end: SourceLocation;
  source?: string;  // Optional source file path
}
```

```lua
-- Lua
{
  start = { line = 1, column = 0, offset = 0 },
  ["end"] = { line = 1, column = 10, offset = 10 },
  source = "story.ws"  -- optional
}
```

## Usage in Nodes

Every AST node or data structure should include location:

```lua
-- Example: Passage with location
{
  id = "passage_0_Start",
  name = "Start",
  content = "Hello!",
  location = {
    start = { line = 1, column = 0, offset = 0 },
    ["end"] = { line = 3, column = 6, offset = 25 }
  },
  choices = {
    {
      text = "Continue",
      target = "Next",
      location = {
        start = { line = 2, column = 0, offset = 8 },
        ["end"] = { line = 2, column = 22, offset = 30 }
      }
    }
  }
}
```

## Tracking in Lexer

The lexer must track position as it tokenizes:

```lua
-- In ws_lexer.lua
local Lexer = {
  input = "",
  pos = 1,        -- Current byte position (1-based for Lua)
  line = 1,       -- Current line (1-based)
  column = 0,     -- Current column (0-based)
}

function Lexer:advance()
  local char = self.input:sub(self.pos, self.pos)
  self.pos = self.pos + 1
  self.column = self.column + 1
  if char == "\n" then
    self.line = self.line + 1
    self.column = 0
  end
  return char
end

function Lexer:get_location()
  return {
    line = self.line,
    column = self.column,
    offset = self.pos - 1  -- Convert to 0-based
  }
end
```

## Token Location

Each token should have location:

```lua
{
  type = "TEXT",
  value = "Hello",
  location = {
    start = { line = 1, column = 3, offset = 3 },
    ["end"] = { line = 1, column = 8, offset = 8 }
  }
}
```

## Error Location

Errors include location for precise reporting:

```lua
{
  message = "Unexpected token",
  location = {
    start = { line = 5, column = 12, offset = 78 },
    ["end"] = { line = 5, column = 15, offset = 81 }
  },
  suggestion = "Did you mean '-> Target'?"
}
```

## Source Map API

### Position Lookup

```lua
-- Find node at position
function find_node_at(story, line, column)
  for _, passage in pairs(story.passages) do
    if contains_position(passage.location, line, column) then
      -- Check choices
      for _, choice in ipairs(passage.choices) do
        if contains_position(choice.location, line, column) then
          return choice, "choice"
        end
      end
      return passage, "passage"
    end
  end
  return nil
end

function contains_position(location, line, column)
  if line < location.start.line or line > location["end"].line then
    return false
  end
  if line == location.start.line and column < location.start.column then
    return false
  end
  if line == location["end"].line and column > location["end"].column then
    return false
  end
  return true
end
```

### Get Source Context

```lua
-- Extract source lines around location
function get_source_context(source, location, context_lines)
  context_lines = context_lines or 2
  local lines = {}
  local start_line = math.max(1, location.start.line - context_lines)
  local end_line = location.start.line + context_lines

  local line_num = 1
  for line in source:gmatch("[^\n]*") do
    if line_num >= start_line and line_num <= end_line then
      table.insert(lines, {
        number = line_num,
        content = line,
        is_error = line_num == location.start.line
      })
    end
    line_num = line_num + 1
    if line_num > end_line then break end
  end

  return lines
end
```

## Implementation Plan

### Phase 1: Lexer Updates

1. Add position tracking to lexer state
2. Include location in all tokens
3. Update token structure

### Phase 2: Parser Updates

1. Capture start position before parsing
2. Capture end position after parsing
3. Create location span for each node

### Phase 3: Error Integration

1. Include location in all errors
2. Add source context extraction
3. Format errors with line display

### Phase 4: Runtime Integration

1. Store source in parsed story
2. Map runtime errors to source
3. Expose location API

## Example Output

```lua
-- Parsing ":: Start\nHello $name!\n+ [Go] -> Next"

{
  success = true,
  story = {
    passages = {
      ["passage_0_Start"] = {
        name = "Start",
        location = {
          start = { line = 1, column = 0, offset = 0 },
          ["end"] = { line = 3, column = 15, offset = 35 }
        },
        content = "Hello $name!",
        content_location = {
          start = { line = 2, column = 0, offset = 9 },
          ["end"] = { line = 2, column = 12, offset = 21 }
        },
        choices = {
          {
            text = "Go",
            target = "Next",
            location = {
              start = { line = 3, column = 0, offset = 22 },
              ["end"] = { line = 3, column = 15, offset = 37 }
            }
          }
        }
      }
    }
  }
}
```
