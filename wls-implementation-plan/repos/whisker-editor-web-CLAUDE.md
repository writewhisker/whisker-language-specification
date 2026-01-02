# Whisker Editor Web (TypeScript) - Implementation Context

## Repository

```
~/code/github.com/writewhisker/whisker-editor-web
```

## Overview

TypeScript implementation of WLS including parser, runtime, validators, and web-based editor. Monorepo using pnpm workspaces.

## Directory Structure

```
whisker-editor-web/
├── packages/
│   ├── parser/                 # PEG.js grammar and parser
│   │   ├── src/
│   │   │   ├── whisker.pegjs   # Grammar
│   │   │   └── index.ts
│   │   └── package.json
│   ├── story-models/           # Story data types
│   │   └── src/
│   │       ├── Story.ts
│   │       ├── Passage.ts
│   │       └── types.ts
│   ├── story-validation/       # Validators
│   │   └── src/
│   │       ├── validators/
│   │       ├── error-codes.ts
│   │       └── StoryValidator.ts
│   ├── story-player/           # Runtime
│   │   └── src/
│   │       ├── StoryPlayer.ts
│   │       └── State.ts
│   ├── import/                 # Format importers
│   ├── export/                 # Format exporters
│   ├── scripting/              # Lua/expression evaluation
│   └── editor-base/            # Editor components (Svelte)
├── apps/
│   └── web/                    # Web editor app
└── pnpm-workspace.yaml
```

## Key Patterns

### Parser
```typescript
import { parse } from '@writewhisker/parser';

const story = parse(source);
// Returns Story object or throws ParseError
```

### Validators
```typescript
import { StoryValidator, createDefaultValidator } from '@writewhisker/story-validation';

const validator = createDefaultValidator();
const errors = validator.validate(story);

errors.forEach(err => {
  console.log(`${err.code}: ${err.message}`);
});
```

### Runtime
```typescript
import { StoryPlayer } from '@writewhisker/story-player';

const player = new StoryPlayer(story);
const content = player.getContent();
const choices = player.getChoices();
player.choose(0);
```

## Running Tests

```bash
# All packages
pnpm test

# Specific package
pnpm --filter @writewhisker/story-validation test

# With coverage
pnpm test -- --coverage

# Watch mode
pnpm --filter @writewhisker/parser test -- --watch
```

## Error Code Format

```typescript
// packages/story-validation/src/error-codes/wls-error-codes.ts
export const WLS_ERROR_CODES = {
  'WLS-STR-001': {
    id: 'missing_start_passage',
    severity: 'error',
    message: "Story must have a 'Start' passage",
  },
  // ...
} as const;
```

## Implementation Notes

### Cross-Platform Parity
- Must match Lua behavior exactly
- Use shared test corpus for verification
- Error codes and messages must be identical

### TypeScript Patterns
- Use strict types
- Prefer interfaces over types for objects
- Use const assertions for literals
- Export types separately with `export type`

### Package Dependencies
```
parser
  └── story-models
        ├── story-validation
        └── story-player
              └── scripting
```

## Common Tasks

### Add a Validator
1. Create `packages/story-validation/src/validators/MyValidator.ts`
2. Implement `StoryValidator` interface
3. Register in `validators/index.ts`
4. Create `MyValidator.test.ts`
5. Add corpus tests

### Add Parser Feature
1. Update `packages/parser/src/whisker.pegjs`
2. Add types in `packages/story-models/src/types.ts`
3. Create tests
4. Update runtime if needed

### Add Runtime Feature
1. Update `packages/story-player/src/StoryPlayer.ts`
2. Create tests
3. Verify with corpus

## Build Commands

```bash
# Build all
pnpm build

# Build specific package
pnpm --filter @writewhisker/parser build

# Type check
pnpm typecheck

# Lint
pnpm lint
```

## Phase-Specific Notes

### Phase 1: Validation
Update `packages/story-validation/`:
- Add `src/error-codes/wls-error-codes.ts`
- Implement new validators
- Update existing validators with WLS codes

### Phase 2: Flow Control
Update:
- `packages/parser/src/whisker.pegjs` - New syntax
- `packages/story-player/src/StoryPlayer.ts` - Call stack
- `packages/story-models/src/types.ts` - New AST nodes

### Phase 3: Tooling
Create:
- `packages/import/` - Format importers
- `packages/export/` - Format exporters
- CLI commands in editor-base

### Phase 5: Documentation
Generate with TypeDoc:
```bash
pnpm typedoc
```

### Phase 6: WLS 2.0
Major updates:
- Thread scheduler
- LIST operators
- Timed content
- External functions
- Audio API
