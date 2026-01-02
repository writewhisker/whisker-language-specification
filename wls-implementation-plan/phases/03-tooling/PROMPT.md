# Phase 3: Tooling (WLS 1.1)

## Objective

Build comprehensive import/export and publishing infrastructure for professional IF authoring workflow.

## Features

### 1. Twine Import
**Priority: P1 | Complexity: High**

Import stories from Twine (Harlowe and SugarCube formats).

**Supported:**
- Twine 2 archive format (.html)
- Harlowe 3.x syntax
- SugarCube 2.x syntax
- Passage metadata (tags, position)
- Variables and macros

**Conversion Examples:**

Harlowe:
```harlowe
(set: $gold to 100)
(if: $gold > 50)[You're rich!]
(link: "Continue")[(goto: "Next")]
```
Becomes:
```whisker
{do $gold = 100}
{$gold > 50}
You're rich!
{/}
+ [Continue] -> Next
```

SugarCube:
```sugarcube
<<set $gold to 100>>
<<if $gold > 50>>You're rich!<</if>>
[[Continue|Next]]
```
Becomes same WLS.

### 2. Ink Import
**Priority: P2 | Complexity: High**

Import stories from Ink format.

**Supported:**
- Knots and stitches -> Passages
- Choices and gathers
- Variables and logic
- Tunnels and threads (partial)

### 3. ChoiceScript Import
**Priority: P3 | Complexity: Medium**

Import stories from ChoiceScript format.

**Supported:**
- Scenes -> Passages
- `*choice` -> Choices
- Variables and stats
- `*if/*else` -> Conditionals

### 4. Static HTML Export
**Priority: P1 | Complexity: Medium**

Export as standalone HTML file.

**Features:**
- Single HTML file with embedded story
- Bundled player runtime
- Custom CSS themes
- No server required

### 5. PWA Export
**Priority: P2 | Complexity: Medium**

Export as installable Progressive Web App.

**Features:**
- Service worker for offline
- App manifest
- Icon generation
- Update mechanism

### 6. ePub Export
**Priority: P3 | Complexity: High**

Export as ePub ebook with interactive elements.

**Features:**
- ePub 3 format
- XHTML content
- Limited interactivity
- Fallback for non-IF readers

### 7. Publishing Integration
**Priority: P2 | Complexity: Medium**

Publish to IF platforms.

**Platforms:**
- IFDB (Interactive Fiction Database)
- itch.io
- Custom hosting

### 8. Build Pipeline
**Priority: P1 | Complexity: High**

CLI build system for stories.

**Features:**
- Watch mode
- Multiple output formats
- Asset bundling
- Minification

### 9. VCS Integration
**Priority: P3 | Complexity: High**

Git-friendly story management.

**Features:**
- Semantic diff
- Merge conflict resolution
- Story-aware blame

## Implementation Steps

### Step 1: Import Framework
Create extensible import architecture:

```typescript
// packages/import/src/types.ts
interface Importer {
  name: string;
  extensions: string[];
  detect(content: string): boolean;
  import(content: string): Story;
}
```

### Step 2: Twine Import
```
packages/import/src/formats/
├── TwineImporter.ts
├── HarloweConverter.ts
├── SugarCubeConverter.ts
└── TwineArchiveParser.ts
```

### Step 3: Export Framework
```typescript
// packages/export/src/types.ts
interface Exporter {
  name: string;
  extension: string;
  export(story: Story, options: ExportOptions): string | Buffer;
}
```

### Step 4: HTML Export
```
packages/export/src/formats/
├── HTMLExporter.ts
├── PlayerBundle.ts
└── themes/
    ├── default.css
    └── dark.css
```

### Step 5: CLI Tools
```
packages/cli/src/commands/
├── import.ts
├── export.ts
├── build.ts
├── publish.ts
└── watch.ts
```

## Key Files

**TypeScript:**
- `packages/import/` (new package)
- `packages/export/` (new package)
- `packages/cli/src/commands/`

**Lua:**
- `lib/whisker/import/`
- `lib/whisker/export/`

**Tests:**
- `phase-4-validation/test-corpus/import/`
- `phase-4-validation/test-corpus/export/`

## CLI Commands

```bash
# Import
whisker import story.html --from=twine
whisker import story.ink --from=ink
whisker import startup.txt --from=choicescript

# Export
whisker export story.ws --to=html
whisker export story.ws --to=pwa --icons=icons/
whisker export story.ws --to=epub

# Build
whisker build --watch
whisker build --minify --output=dist/

# Publish
whisker publish --platform=ifdb
whisker publish --platform=itch
```
