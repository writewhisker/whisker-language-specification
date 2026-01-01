# Unified AST Design for WLS 1.0

**Date:** 2026-01-01

## Overview

This document defines the unified AST structure for both Lua and TypeScript parsers. The TypeScript implementation is the reference; Lua should produce equivalent structures.

## Design Principles

1. **Consistency**: Same node types in both implementations
2. **Location Tracking**: All nodes have source positions
3. **Type Safety**: Clear typing for all node variants
4. **Extensibility**: Easy to add new node types

## Node Categories

### 1. Story Structure Nodes

```
StoryNode
├── metadata: MetadataNode[]
├── variables: VariableDeclarationNode[]
└── passages: PassageNode[]
```

### 2. Passage Nodes

```
PassageNode
├── name: string
├── tags: string[]
├── metadata: PassageMetadataNode[]
└── content: ContentNode[]
```

### 3. Content Nodes

```
ContentNode = TextNode
            | InterpolationNode
            | ExpressionStatementNode
            | DoBlockNode
            | ConditionalNode
            | ChoiceNode
            | AlternativesNode
```

### 4. Expression Nodes

```
ExpressionNode = IdentifierNode
               | VariableNode
               | LiteralNode
               | BinaryExpressionNode
               | UnaryExpressionNode
               | CallExpressionNode
               | MemberExpressionNode
               | AssignmentExpressionNode
```

## Node Definitions

### Base Node

```lua
-- Lua
{
  type = "node_type",
  location = {
    start = { line = 1, column = 1, offset = 0 },
    ["end"] = { line = 1, column = 10, offset = 9 }
  }
}
```

```typescript
// TypeScript
interface BaseNode {
  type: string;
  location: SourceSpan;
}
```

### Story Node

```lua
-- Lua
{
  type = "story",
  metadata = { ... },
  variables = { ... },
  passages = { ... },
  location = { ... }
}
```

### Passage Node

```lua
-- Lua
{
  type = "passage",
  name = "Start",
  tags = { "intro", "important" },
  metadata = { ... },
  content = { ... },
  location = { ... }
}
```

### Text Node

```lua
-- Lua
{
  type = "text",
  value = "Hello, world!",
  location = { ... }
}
```

### Interpolation Node

```lua
-- Lua
{
  type = "interpolation",
  expression = { ... },  -- ExpressionNode
  is_simple = true,      -- $var vs ${expr}
  location = { ... }
}
```

### Conditional Node

```lua
-- Lua
{
  type = "conditional",
  condition = { ... },   -- ExpressionNode
  consequent = { ... },  -- ContentNode[]
  alternatives = { ... }, -- ConditionalBranchNode[]
  alternate = { ... },   -- ContentNode[] or nil
  location = { ... }
}
```

### Choice Node

```lua
-- Lua
{
  type = "choice",
  choice_type = "once",  -- or "sticky"
  condition = { ... },   -- ExpressionNode or nil
  text = { ... },        -- ContentNode[]
  target = "NextPassage",
  action = { ... },      -- ExpressionNode[] or nil
  location = { ... }
}
```

### Alternatives Node

```lua
-- Lua
{
  type = "alternatives",
  mode = "shuffle",  -- "sequence", "cycle", "shuffle", "once"
  options = {
    { ... },  -- ContentNode[]
    { ... },  -- ContentNode[]
  },
  location = { ... }
}
```

### Expression Nodes

```lua
-- Variable
{
  type = "variable",
  name = "gold",
  scope = "story",  -- or "temp"
  location = { ... }
}

-- Literal
{
  type = "literal",
  value_type = "number",  -- "string", "boolean", "nil"
  value = 42,
  location = { ... }
}

-- Binary Expression
{
  type = "binary_expression",
  operator = "+",
  left = { ... },
  right = { ... },
  location = { ... }
}

-- Assignment
{
  type = "assignment_expression",
  operator = "+=",
  target = { ... },
  value = { ... },
  location = { ... }
}
```

## Lua Implementation Notes

### Option 1: Full AST (Recommended for Tooling)

Create a parallel AST structure that mirrors TypeScript, then convert to story data for runtime.

```lua
-- lib/whisker/parser/ast.lua
local AST = {}

function AST.create_node(type, props, location)
  local node = { type = type, location = location }
  for k, v in pairs(props) do
    node[k] = v
  end
  return node
end

function AST.text(value, location)
  return AST.create_node("text", { value = value }, location)
end

-- etc.
```

### Option 2: Story Data with Locations (Pragmatic)

Keep current story data structure but add location tracking.

```lua
{
  success = true,
  story = {
    metadata = { ... },
    passages = {
      ["passage_0"] = {
        name = "Start",
        content = "...",
        location = { start = {...}, ["end"] = {...} },
        choices = { ... }
      }
    }
  },
  errors = { ... }
}
```

## Recommendation

For Gap 1, use **Option 2** (Story Data with Locations):
- Minimal changes to existing code
- Achieves source mapping goal
- Runtime doesn't need full AST

For future gaps (tooling, LSP), consider **Option 1**.

## Migration Path

1. **Phase 1.4**: Add location tracking to current structure
2. **Future**: Create AST layer if needed for tooling
3. **Future**: AST-to-Story-Data conversion function
