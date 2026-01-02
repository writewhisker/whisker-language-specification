# Phase 5: Documentation (WLS 1.1)

## Objective

Complete comprehensive documentation for WLS including API reference, tutorials, migration guides, and examples.

## Documentation Types

### 1. API Reference
Auto-generated from source code with manual enhancements.

**TypeScript (TypeDoc):**
```bash
pnpm typedoc
```

**Lua (LDoc):**
```bash
ldoc .
```

**Coverage:**
- All public APIs
- All types/interfaces
- All error codes
- All configuration options

### 2. Tutorial Series

**Beginner Track:**
1. Your First Whisker Story
2. Adding Choices
3. Using Variables
4. Conditional Content
5. Linking Passages

**Intermediate Track:**
1. Advanced Flow Control
2. Data Structures (LIST, ARRAY, MAP)
3. Functions and Namespaces
4. Styling Your Story
5. Adding Media

**Advanced Track:**
1. Complex State Management
2. Performance Optimization
3. Custom Themes
4. Plugin Development
5. Publishing and Distribution

### 3. Migration Guides

**From Twine:**
- Harlowe to WLS cheat sheet
- SugarCube to WLS cheat sheet
- Passage structure mapping
- Macro equivalents
- Variable syntax changes

**From Ink:**
- Knot/stitch to passage mapping
- Divert to link conversion
- Variable syntax
- Logic block conversion
- Tunnel/gather equivalents

**From ChoiceScript:**
- Scene to passage mapping
- Choice syntax
- Stat/variable conversion
- Conditional syntax

### 4. Examples Library

**By Category:**
```
examples/
├── basic/
│   ├── hello-world.ws
│   ├── simple-choices.ws
│   └── variables.ws
├── intermediate/
│   ├── branching-story.ws
│   ├── inventory-system.ws
│   └── dialogue-tree.ws
├── advanced/
│   ├── state-machine.ws
│   ├── procedural-content.ws
│   └── complex-game.ws
└── showcase/
    ├── mystery-game/
    ├── visual-novel/
    └── text-adventure/
```

### 5. Reference Cards

Quick reference materials:
- Syntax cheat sheet (printable)
- Error code reference
- Keyboard shortcuts
- CLI command reference

## Implementation Steps

### Step 1: API Documentation

**TypeScript Setup:**
```json
// typedoc.json
{
  "entryPoints": ["packages/*/src/index.ts"],
  "out": "docs/api/typescript",
  "readme": "none",
  "excludePrivate": true
}
```

**Lua Setup:**
```lua
-- config.ld
project = "Whisker Core"
title = "Whisker Core API"
description = "Lua implementation of WLS"
```

### Step 2: Tutorial Structure

Each tutorial includes:
- Learning objectives
- Prerequisites
- Step-by-step instructions
- Code examples (runnable)
- Exercises
- Next steps

**Template:**
```markdown
# Tutorial: [Title]

## What You'll Learn
- Objective 1
- Objective 2

## Prerequisites
- [Previous Tutorial]

## Step 1: [First Step]
[Instructions]

```whisker
[Code Example]
```

## Try It Yourself
[Exercise]

## Next Steps
- [Next Tutorial]
```

### Step 3: Migration Guide Structure

**Template:**
```markdown
# Migrating from [Format] to WLS

## Overview
[Brief comparison]

## Quick Reference

| [Format] | WLS |
|----------|-----|
| `old syntax` | `new syntax` |

## Detailed Conversion

### [Feature 1]
[Explanation with before/after]

### Common Gotchas
[Things that don't convert directly]

## Automated Tools
```bash
whisker import story.format --from=[format]
```
```

### Step 4: Documentation Site

**Structure:**
```
docs/
├── index.md              # Landing page
├── getting-started/
│   ├── installation.md
│   ├── quick-start.md
│   └── editor-setup.md
├── tutorials/
│   ├── beginner/
│   ├── intermediate/
│   └── advanced/
├── reference/
│   ├── syntax.md
│   ├── error-codes.md
│   ├── cli.md
│   └── api/
├── migration/
│   ├── from-twine.md
│   ├── from-ink.md
│   └── from-choicescript.md
├── examples/
│   └── [by category]
└── community/
    ├── contributing.md
    └── resources.md
```

### Step 5: Documentation Tooling

**Site Generator:**
- VitePress or Docusaurus
- Search integration
- Version selector
- Dark mode

**Linting:**
- Markdown linting
- Link checking
- Code example validation

## Key Files

**Documentation:**
- `docs/` (site content)
- `docs/.vitepress/` (configuration)
- `packages/*/README.md` (package docs)

**Examples:**
- `examples/` (runnable examples)
- `phase-1-specification/examples/` (canonical examples)

## Documentation Targets

| Type | Current | Target |
|------|---------|--------|
| API docs | 50% | 100% |
| Tutorials | 3 | 15 |
| Migration guides | 0 | 3 |
| Examples | 20 | 50+ |
| Reference pages | 5 | 20 |
