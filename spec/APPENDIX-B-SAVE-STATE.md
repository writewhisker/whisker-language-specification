# Appendix B: Save State Schema

This appendix defines the standard JSON format for WLS save states, enabling portable saves across implementations.

## B.1 Overview

Save states capture the complete runtime state of a story at a specific moment, allowing:
- Save/load functionality
- Cross-implementation portability
- Debugging and testing
- Analytics and telemetry

## B.2 JSON Schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "WLS Save State",
  "type": "object",
  "required": ["wls_version", "current_passage", "variables"],
  "properties": {
    "wls_version": {
      "type": "string",
      "description": "WLS specification version",
      "pattern": "^\\d+\\.\\d+\\.\\d+$"
    },
    "save_version": {
      "type": "string",
      "description": "Save format version",
      "default": "1"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "description": "ISO 8601 timestamp when save was created"
    },
    "current_passage": {
      "type": "string",
      "description": "Name of the current passage"
    },
    "variables": {
      "type": "object",
      "description": "All story variables (not temporaries)",
      "additionalProperties": true
    },
    "history": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Passage visit history (oldest first)"
    },
    "tunnel_stack": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "passage": { "type": "string" },
          "return_line": { "type": "integer" }
        }
      },
      "description": "Active tunnel return points"
    },
    "alternative_state": {
      "type": "object",
      "description": "Text alternative visit counts",
      "additionalProperties": { "type": "integer" }
    },
    "exhausted_choices": {
      "type": "object",
      "description": "Once-only choices that have been selected",
      "additionalProperties": {
        "type": "array",
        "items": { "type": "integer" }
      }
    },
    "hooks": {
      "type": "object",
      "description": "Hook states",
      "additionalProperties": {
        "type": "object",
        "properties": {
          "content": { "type": "string" },
          "visible": { "type": "boolean" }
        }
      }
    },
    "random_seed": {
      "type": "integer",
      "description": "RNG state for deterministic replay (optional)"
    },
    "custom": {
      "type": "object",
      "description": "Implementation-specific data (optional)"
    }
  }
}
```

## B.3 Example Save State

```json
{
  "wls_version": "1.0.0",
  "save_version": "1",
  "timestamp": "2026-01-17T12:34:56Z",
  "current_passage": "Forest",
  "variables": {
    "gold": 150,
    "playerName": "Hero",
    "hasKey": true,
    "inventory": ["sword", "potion", "map"],
    "stats": {
      "health": 85,
      "maxHealth": 100,
      "level": 3
    }
  },
  "history": [
    "Start",
    "Village",
    "Shop",
    "Village",
    "Forest"
  ],
  "tunnel_stack": [],
  "alternative_state": {
    "OldMan:0": 2,
    "OldMan:1": 1,
    "Forest:greeting": 3
  },
  "exhausted_choices": {
    "Shop": [0, 2],
    "Tavern": [1]
  },
  "hooks": {
    "statusBar": {
      "content": "Health: 85/100 | Gold: 150",
      "visible": true
    },
    "questLog": {
      "content": "Find the hidden temple",
      "visible": true
    }
  },
  "random_seed": 42
}
```

## B.4 Field Specifications

### B.4.1 Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `wls_version` | string | Spec version story targets (e.g., "1.0.0") |
| `current_passage` | string | Passage name where player is located |
| `variables` | object | All story-scoped variables |

### B.4.2 Optional Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `save_version` | string | "1" | Save format version for migration |
| `timestamp` | string | - | ISO 8601 creation time |
| `history` | array | `[]` | Passage visit history |
| `tunnel_stack` | array | `[]` | Active tunnel return points |
| `alternative_state` | object | `{}` | Visit counts per alternative |
| `exhausted_choices` | object | `{}` | Selected once-only choice indices |
| `hooks` | object | `{}` | Modified hook states |
| `random_seed` | integer | - | RNG state for replay |
| `custom` | object | `{}` | Implementation-specific data |

### B.4.3 Variable Serialization

| WLS Type | JSON Type | Example |
|----------|-----------|---------|
| Number | number | `42`, `3.14` |
| String | string | `"hello"` |
| Boolean | boolean | `true`, `false` |
| Array | array | `[1, 2, 3]` |
| Map | object | `{"key": "value"}` |
| List | object | `{"_type": "list", "active": ["happy"], "all": ["happy", "sad"]}` |
| nil | null | `null` |

### B.4.4 Alternative State Keys

Alternative state keys follow the format: `PassageName:index` or `PassageName:name`

- Index-based (unnamed): `"Forest:0"` = first alternative in Forest passage
- Name-based (named): `"Forest:greeting"` = alternative named "greeting"

### B.4.5 Exhausted Choices Keys

Keys are passage names; values are arrays of choice indices (0-based):

```json
{
  "Shop": [0, 2],    // First and third choices exhausted
  "Tavern": [1]      // Second choice exhausted
}
```

## B.5 Save/Load Operations

### B.5.1 Saving

```lua
-- Get save state as JSON string
local saveJson = whisker.save.toJson()

-- Get save state as Lua table
local saveTable = whisker.save.toTable()

-- Save with custom slot name
whisker.save.save("slot1")
```

### B.5.2 Loading

```lua
-- Load from JSON string
whisker.save.fromJson(jsonString)

-- Load from Lua table
whisker.save.fromTable(saveTable)

-- Load from named slot
whisker.save.load("slot1")
```

### B.5.3 Validation

Implementations MUST validate saves before loading:

1. Check `wls_version` compatibility
2. Verify `current_passage` exists
3. Validate variable types match declarations
4. Check for required fields

Invalid saves SHOULD produce error WLS-SAVE-001 with specific failure reason.

## B.6 Migration

When loading a save from a different `save_version`:

1. Check if migration path exists
2. Transform data structure as needed
3. Log migration actions
4. Update `save_version` field

### B.6.1 Version 1 → 2 (Example)

```lua
if save.save_version == "1" then
  -- Migrate alternative_state key format
  for key, value in pairs(save.alternative_state) do
    -- Old: "PassageName:0" → New: "PassageName::0"
    local newKey = key:gsub(":", "::")
    save.alternative_state[newKey] = value
  end
  save.save_version = "2"
end
```

## B.7 Implementation Requirements

1. Implementations MUST support JSON save format
2. Implementations MUST validate saves before loading
3. Implementations MUST NOT corrupt saves on error
4. Implementations SHOULD support save compression
5. Implementations MAY add custom fields in `custom` object
6. Implementations MUST preserve unknown fields when re-saving

## B.8 Security Considerations

1. **Input validation**: Sanitize all loaded values
2. **Size limits**: Reject saves exceeding reasonable size (recommend 1MB)
3. **Injection prevention**: Don't evaluate save content as code
4. **Integrity**: Consider checksums for save validation
