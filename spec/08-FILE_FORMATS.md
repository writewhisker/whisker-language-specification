# Chapter 8: File Formats

**Whisker Language Specification 1.0**

---

## 8.1 Overview

WLS defines two file formats for representing stories:

| Format | Extension | Purpose |
|--------|-----------|---------|
| Text | `.ws` | Human authoring and editing |
| JSON | `.json` | Machine processing and interchange |

Both formats represent the same underlying data and MUST be convertible without loss.

### 8.1.1 Format Comparison

| Feature | Text (.ws) | JSON |
|---------|------------|------|
| Human readable | Excellent | Good |
| Machine parsing | Moderate | Excellent |
| Version control | Excellent | Good |
| Editor support | Custom parsers | Standard JSON |
| File size | Smaller | Larger |

## 8.2 Text Format (.ws)

### 8.2.1 File Structure

A `.ws` file has this structure:

```
┌─────────────────────────────┐
│ Story Header (optional)     │
│   @title, @author, etc.     │
├─────────────────────────────┤
│ Variable Declarations       │
│   @vars block (optional)    │
├─────────────────────────────┤
│ Passages                    │
│   :: PassageName            │
│   Content...                │
│   Choices...                │
│                             │
│   :: AnotherPassage         │
│   Content...                │
└─────────────────────────────┘
```

### 8.2.2 Encoding

| Property | Requirement |
|----------|-------------|
| Character encoding | UTF-8 |
| BOM | Optional (SHOULD NOT include) |
| Line endings | LF (`\n`) or CRLF (`\r\n`) |
| Trailing newline | SHOULD include |

### 8.2.3 Story Header

The story header contains metadata directives:

```whisker
@title: The Enchanted Forest
@author: Jane Writer
@version: 1.0.0
@ifid: 550e8400-e29b-41d4-a716-446655440000
@start: Prologue
```

**Header Directives:**

| Directive | Type | Required | Description |
|-----------|------|----------|-------------|
| `@title:` | string | SHOULD | Story title |
| `@author:` | string | SHOULD | Author name |
| `@version:` | string | MAY | Story version (semver) |
| `@ifid:` | string | SHOULD | Interactive Fiction ID (UUID) |
| `@start:` | string | MAY | Start passage ID |
| `@description:` | string | MAY | Brief description |
| `@created:` | string | MAY | ISO 8601 timestamp |
| `@modified:` | string | MAY | ISO 8601 timestamp |

**Rules:**
- Header MUST appear before any passages
- Each directive on its own line
- Colon followed by space, then value
- Values extend to end of line
- Unknown directives SHOULD be preserved

### 8.2.4 Variable Declarations

Pre-declare variables with initial values:

```whisker
@vars
  gold: 100
  playerName: "Adventurer"
  hasKey: false
  health: 100.0
```

**Syntax:**

```
@vars
  varName: value
  varName: value
  ...
```

**Rules:**
- Indentation required (2 spaces recommended)
- One variable per line
- Colon separates name from value
- Values follow literal syntax (Chapter 3)
- Block ends at next directive or passage

**Value Types:**

| Type | Syntax | Example |
|------|--------|---------|
| Number | digits, optional decimal | `100`, `3.14` |
| String | double-quoted | `"Hello"` |
| Boolean | `true` or `false` | `true` |

### 8.2.5 Passage Declaration

Passages begin with the `::` marker:

```whisker
:: PassageName
Passage content here.
```

**With metadata:**

```whisker
:: PassageName
@tags: tag1, tag2, tag3
@color: #ff5500
@position: 100, 200
@notes: Author notes here
@onEnter: whisker.state.set("visited", true)
@onExit: whisker.print("leaving")

Passage content starts after blank line or directives.
```

**Passage Directives:**

| Directive | Type | Description |
|-----------|------|-------------|
| `@tags:` | string[] | Comma-separated tags |
| `@color:` | string | Hex color for editor |
| `@position:` | number[] | Editor position (x, y) |
| `@notes:` | string | Author notes (not rendered) |
| `@onEnter:` | string | Lua script on entry |
| `@onExit:` | string | Lua script on exit |
| `@fallback:` | string | Fallback passage ID |

### 8.2.6 Passage Content

Content follows the passage declaration:

```whisker
:: Garden
The garden is peaceful.

$visits += 1

{ $visits == 1 }
  You've never been here before.
{else}
  You recognize this place.
{/}

+ [Smell the flowers] -> Flowers
+ [Leave] -> Exit
```

**Content Elements:**

| Element | Description |
|---------|-------------|
| Plain text | Narrative prose |
| Blank lines | Paragraph breaks |
| Variable assignment | `$var = value` |
| Conditionals | `{ cond }...{/}` |
| Alternatives | `{\| a \| b }` |
| Choices | `+ [text] -> target` |
| Comments | `//` or `/* */` |
| Embedded Lua | `{{ code }}` |

### 8.2.7 Comments

```whisker
// Single-line comment

/* Multi-line
   comment */

$gold = 100  // Inline comment
```

Comments are stripped during parsing and not preserved in JSON output.

### 8.2.8 Complete Example

```whisker
@title: The Lost Key
@author: Example Author
@version: 1.0.0
@ifid: 123e4567-e89b-12d3-a456-426614174000
@start: Start

@vars
  gold: 50
  hasKey: false
  playerName: "Traveler"

:: Start
@tags: beginning
@color: #3498db

Welcome, $playerName!

You find yourself at the entrance to a mysterious dungeon.
Your purse contains $gold gold coins.

+ [Enter the dungeon] -> DungeonEntrance
+ [Search the area] -> SearchArea

:: SearchArea
You search the surrounding area carefully.

{ whisker.visited("SearchArea") == 1 }
  {~| Under a rock | Behind a bush | In the grass }, you find something!
  $gold += 10
  You found 10 gold coins!
{else}
  You've already searched here. Nothing new to find.
{/}

+ [Enter the dungeon] -> DungeonEntrance
+ [Keep searching] -> SearchArea

:: DungeonEntrance
@tags: dungeon, main

The dungeon entrance looms before you.

{ $hasKey }
  The iron gate stands open.
  + [Proceed inside] -> DungeonInner
{else}
  A locked iron gate blocks your path.
  + { $gold >= 25 } [Bribe the guard ($25)] { $gold -= 25; $hasKey = true } -> DungeonEntrance
  + [Look for another way] -> SearchArea
{/}

+ [Leave this place] -> END

:: DungeonInner
@onEnter: whisker.state.set("dungeonVisits", (whisker.state.get("dungeonVisits") or 0) + 1)

You enter the dungeon depths.

{| First time here... spooky! | Back again. | You know this place well now. }

The adventure continues...

+ [Explore deeper] -> END
```

## 8.3 JSON Format

### 8.3.1 Schema Overview

JSON format version: **2.1**
Schema file: `wls.schema.json`

```json
{
  "format": "whisker",
  "version": "2.1",
  "wls": "1.0",
  "metadata": { ... },
  "settings": { ... },
  "variables": { ... },
  "passages": [ ... ],
  "assets": [ ... ]
}
```

### 8.3.2 Root Object

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `format` | string | Yes | Must be `"whisker"` |
| `version` | string | Yes | Format version (e.g., `"2.1"`) |
| `wls` | string | Yes | WLS version (e.g., `"1.0"`) |
| `metadata` | object | Yes | Story metadata |
| `settings` | object | No | Story settings |
| `variables` | object | No | Initial variables |
| `passages` | array | Yes | Passage objects |
| `assets` | array | No | Asset references |

### 8.3.3 Metadata Object

```json
{
  "metadata": {
    "title": "The Lost Key",
    "author": "Example Author",
    "version": "1.0.0",
    "ifid": "123e4567-e89b-12d3-a456-426614174000",
    "description": "A short adventure",
    "created": "2025-12-29T10:00:00Z",
    "modified": "2025-12-29T15:30:00Z",
    "start": "Start"
  }
}
```

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `title` | string | SHOULD | Story title |
| `author` | string | SHOULD | Author name |
| `version` | string | MAY | Story version |
| `ifid` | string | SHOULD | UUID identifier |
| `description` | string | MAY | Brief description |
| `created` | string | MAY | ISO 8601 timestamp |
| `modified` | string | MAY | ISO 8601 timestamp |
| `start` | string | MAY | Start passage ID |

### 8.3.4 Settings Object

```json
{
  "settings": {
    "debug": false,
    "historyLimit": 100,
    "autoSave": true
  }
}
```

Settings are implementation-defined. Common settings:

| Setting | Type | Description |
|---------|------|-------------|
| `debug` | boolean | Enable debug mode |
| `historyLimit` | number | Max history entries |
| `autoSave` | boolean | Enable auto-save |

### 8.3.5 Variables Object

```json
{
  "variables": {
    "gold": {
      "type": "number",
      "value": 50
    },
    "playerName": {
      "type": "string",
      "value": "Traveler"
    },
    "hasKey": {
      "type": "boolean",
      "value": false
    }
  }
}
```

**Variable Definition:**

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `type` | string | Yes | `"number"`, `"string"`, or `"boolean"` |
| `value` | any | Yes | Initial value |
| `description` | string | No | Documentation |

### 8.3.6 Passage Object

```json
{
  "passages": [
    {
      "id": "Start",
      "content": "Welcome, $playerName!\n\nYou find yourself at the entrance.",
      "tags": ["beginning"],
      "metadata": {
        "color": "#3498db",
        "position": [100, 200],
        "notes": "Opening scene"
      },
      "scripts": {
        "onEnter": null,
        "onExit": null
      },
      "choices": [
        {
          "type": "once",
          "condition": null,
          "text": "Enter the dungeon",
          "action": null,
          "target": "DungeonEntrance"
        }
      ]
    }
  ]
}
```

**Passage Properties:**

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | string | Yes | Unique identifier |
| `content` | string | Yes | Passage content |
| `tags` | string[] | No | Passage tags |
| `metadata` | object | No | Editor metadata |
| `scripts` | object | No | Lifecycle scripts |
| `choices` | array | No | Choice objects |

**Metadata Object:**

| Property | Type | Description |
|----------|------|-------------|
| `color` | string | Hex color |
| `position` | number[] | [x, y] coordinates |
| `notes` | string | Author notes |

**Scripts Object:**

| Property | Type | Description |
|----------|------|-------------|
| `onEnter` | string \| null | Entry script |
| `onExit` | string \| null | Exit script |

### 8.3.7 Choice Object

```json
{
  "type": "once",
  "condition": "$gold >= 25",
  "text": "Bribe the guard ($25)",
  "action": "$gold -= 25; $hasKey = true",
  "target": "DungeonEntrance"
}
```

**Choice Properties:**

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `type` | string | Yes | `"once"` or `"sticky"` |
| `condition` | string \| null | No | Visibility condition |
| `text` | string | Yes | Display text |
| `action` | string \| null | No | Selection action |
| `target` | string | Yes | Target passage ID |

### 8.3.8 Asset Object

```json
{
  "assets": [
    {
      "id": "forest-bg",
      "type": "image",
      "path": "assets/images/forest.png",
      "mimeType": "image/png"
    },
    {
      "id": "ambient-music",
      "type": "audio",
      "path": "assets/audio/ambient.mp3",
      "mimeType": "audio/mpeg"
    }
  ]
}
```

**Asset Properties:**

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | string | Yes | Unique identifier |
| `type` | string | Yes | `"image"`, `"audio"`, `"video"` |
| `path` | string | Yes | Relative file path |
| `mimeType` | string | No | MIME type |
| `metadata` | object | No | Additional metadata |

### 8.3.9 Complete JSON Example

```json
{
  "format": "whisker",
  "version": "2.1",
  "wls": "1.0",
  "metadata": {
    "title": "The Lost Key",
    "author": "Example Author",
    "version": "1.0.0",
    "ifid": "123e4567-e89b-12d3-a456-426614174000",
    "description": "A short dungeon adventure",
    "created": "2025-12-29T10:00:00Z",
    "modified": "2025-12-29T15:30:00Z",
    "start": "Start"
  },
  "settings": {
    "debug": false
  },
  "variables": {
    "gold": {
      "type": "number",
      "value": 50
    },
    "hasKey": {
      "type": "boolean",
      "value": false
    },
    "playerName": {
      "type": "string",
      "value": "Traveler"
    }
  },
  "passages": [
    {
      "id": "Start",
      "content": "Welcome, $playerName!\n\nYou find yourself at the entrance to a mysterious dungeon.\nYour purse contains $gold gold coins.",
      "tags": ["beginning"],
      "metadata": {
        "color": "#3498db",
        "position": [100, 100]
      },
      "scripts": {
        "onEnter": null,
        "onExit": null
      },
      "choices": [
        {
          "type": "once",
          "condition": null,
          "text": "Enter the dungeon",
          "action": null,
          "target": "DungeonEntrance"
        },
        {
          "type": "once",
          "condition": null,
          "text": "Search the area",
          "action": null,
          "target": "SearchArea"
        }
      ]
    },
    {
      "id": "SearchArea",
      "content": "You search the surrounding area carefully.\n\n{ whisker.visited(\"SearchArea\") == 1 }\n  {~| Under a rock | Behind a bush | In the grass }, you find something!\n  $gold += 10\n  You found 10 gold coins!\n{else}\n  You've already searched here. Nothing new to find.\n{/}",
      "tags": [],
      "metadata": {
        "position": [300, 100]
      },
      "scripts": {
        "onEnter": null,
        "onExit": null
      },
      "choices": [
        {
          "type": "once",
          "condition": null,
          "text": "Enter the dungeon",
          "action": null,
          "target": "DungeonEntrance"
        },
        {
          "type": "sticky",
          "condition": null,
          "text": "Keep searching",
          "action": null,
          "target": "SearchArea"
        }
      ]
    },
    {
      "id": "DungeonEntrance",
      "content": "The dungeon entrance looms before you.\n\n{ $hasKey }\n  The iron gate stands open.\n{else}\n  A locked iron gate blocks your path.\n{/}",
      "tags": ["dungeon", "main"],
      "metadata": {
        "position": [200, 300]
      },
      "scripts": {
        "onEnter": null,
        "onExit": null
      },
      "choices": [
        {
          "type": "once",
          "condition": "$hasKey",
          "text": "Proceed inside",
          "action": null,
          "target": "DungeonInner"
        },
        {
          "type": "once",
          "condition": "$gold >= 25 and not $hasKey",
          "text": "Bribe the guard ($25)",
          "action": "$gold -= 25; $hasKey = true",
          "target": "DungeonEntrance"
        },
        {
          "type": "once",
          "condition": "not $hasKey",
          "text": "Look for another way",
          "action": null,
          "target": "SearchArea"
        },
        {
          "type": "once",
          "condition": null,
          "text": "Leave this place",
          "action": null,
          "target": "END"
        }
      ]
    },
    {
      "id": "DungeonInner",
      "content": "You enter the dungeon depths.\n\n{| First time here... spooky! | Back again. | You know this place well now. }\n\nThe adventure continues...",
      "tags": ["dungeon"],
      "metadata": {
        "position": [200, 500]
      },
      "scripts": {
        "onEnter": "whisker.state.set(\"dungeonVisits\", (whisker.state.get(\"dungeonVisits\") or 0) + 1)",
        "onExit": null
      },
      "choices": [
        {
          "type": "once",
          "condition": null,
          "text": "Explore deeper",
          "action": null,
          "target": "END"
        }
      ]
    }
  ],
  "assets": []
}
```

## 8.4 Format Conversion

### 8.4.1 Text to JSON

Converting `.ws` to JSON:

1. Parse story header into `metadata`
2. Parse `@vars` block into `variables`
3. Parse each passage:
   - Extract ID from `:: Name`
   - Extract directives into `metadata` and `scripts`
   - Keep content as raw string
   - Parse choices into choice objects
4. Validate all passage references

### 8.4.2 JSON to Text

Converting JSON to `.ws`:

1. Write header directives from `metadata`
2. Write `@vars` block from `variables`
3. Write each passage:
   - Write `:: id`
   - Write directives from `metadata` and `scripts`
   - Write content string
   - (Choices are embedded in content)

### 8.4.3 Lossless Conversion

Conversion MUST be lossless for:

| Element | Preserved |
|---------|-----------|
| Metadata | All standard fields |
| Variables | Type and value |
| Passage content | Exact string |
| Choices | All properties |
| Tags | Order and values |

MAY be lost in conversion:

| Element | Notes |
|---------|-------|
| Comments | Stripped in text → JSON |
| Whitespace | Normalized |
| Unknown directives | Implementation-dependent |

## 8.5 MIME Types and Extensions

### 8.5.1 File Extensions

| Format | Extension | Notes |
|--------|-----------|-------|
| Text | `.ws` | Primary extension |
| Text | `.whisker` | Alternative (not recommended) |
| JSON | `.json` | Standard JSON |
| JSON | `.wsjson` | Optional specific extension |

### 8.5.2 MIME Types

| Format | MIME Type |
|--------|-----------|
| Text | `text/x-whisker` |
| JSON | `application/json` |

## 8.6 Validation

### 8.6.1 Required Validation

Implementations MUST validate:

| Check | Description |
|-------|-------------|
| Format identifier | `format` equals `"whisker"` |
| Version compatibility | `wls` version is supported |
| Passage references | All targets exist |
| Variable types | Values match declared types |
| Unique IDs | No duplicate passage IDs |
| Start passage | Start passage exists |

### 8.6.2 Validation Errors

```json
{
  "valid": false,
  "errors": [
    {
      "type": "INVALID_REFERENCE",
      "message": "Choice target 'NonExistent' does not exist",
      "location": {
        "passage": "Start",
        "choice": 0
      }
    }
  ]
}
```

### 8.6.3 Schema Validation

JSON files SHOULD validate against `wls.schema.json`:

```bash
# Example validation command
ajv validate -s wls.schema.json -d story.json
```

## 8.7 Versioning

### 8.7.1 Format Version

The `version` field tracks JSON format changes:

| Version | Changes |
|---------|---------|
| 1.0 | Initial format |
| 2.0 | Added WLS compliance fields |
| 2.1 | Added asset support |

### 8.7.2 WLS Version

The `wls` field indicates language specification version:

| Version | Description |
|---------|-------------|
| 1.0 | This specification |

### 8.7.3 Compatibility

Implementations SHOULD:

1. Support current and previous format versions
2. Warn on unknown format versions
3. Reject incompatible WLS versions
4. Upgrade older formats when possible

## 8.8 Implementation Notes

### 8.8.1 Parsing Recommendations

**Text Format:**

1. Use line-by-line parsing for headers
2. Use state machine for passage boundaries
3. Preserve content strings exactly
4. Parse choices with regex or parser combinator

**JSON Format:**

1. Use standard JSON parser
2. Validate against schema
3. Build passage index for lookups

### 8.8.2 Serialization

When writing JSON:

- Use 2-space indentation for readability
- Sort object keys consistently
- Escape special characters properly
- Use `null` for absent optional values

### 8.8.3 Performance

For large stories:

- Lazy-load passage content
- Index passages by ID
- Cache parsed structures
- Stream large files

---

**Previous Chapter:** [Lua API](07-LUA_API.md)
**Next Chapter:** [Examples](09-EXAMPLES.md)
