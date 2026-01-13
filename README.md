# Whisker Language Specification (WLS)

The official specification for the Whisker interactive fiction language.

## Repository Structure

```
whisker-language-specification/
├── spec/               # Formal specification documents (14 chapters)
│   ├── 01-INTRODUCTION.md
│   ├── 02-CORE_CONCEPTS.md
│   ├── 03-SYNTAX.md
│   ├── 04-VARIABLES.md
│   ├── 05-CONTROL_FLOW.md
│   ├── 06-CHOICES.md
│   ├── 07-LUA_API.md
│   ├── 08-FILE_FORMATS.md
│   ├── 09-EXAMPLES.md
│   ├── 10-BEST_PRACTICES.md
│   ├── 11-VALIDATION.md
│   ├── 12-MODULES.md
│   ├── 13-PRESENTATION.md
│   ├── 14-DEVELOPER-EXPERIENCE.md
│   ├── APPENDICES.md
│   └── APPENDIX-A-ERROR-CODES.md
│
├── examples/           # Canonical WLS examples
│   ├── beginner/       # Start here - simple stories
│   ├── intermediate/   # Core features
│   └── advanced/       # Complex games and API demos
│
├── test-corpus/        # Conformance test cases (22 categories)
│   ├── validation/     # Semantic validation tests
│   ├── syntax/         # Parser tests
│   └── ...             # See test-corpus/README.md for full list
│
├── tools/              # Testing and validation tools
│   ├── validation-corpus-runner.ts
│   ├── validation-corpus-runner.lua
│   └── ...
│
├── docs/               # Implementation documentation
│   ├── MIGRATION_GUIDE.md
│   ├── CROSS_PLATFORM_VALIDATION.md
│   └── ...
│
├── shared/             # Shared resources
│   └── schemas/
│       └── wls.schema.json
│
├── GRAMMAR.ebnf        # Formal EBNF grammar (411 lines)
├── HOOKS.md            # Hooks system documentation
└── WLS_OVERVIEW.md     # Specification overview
```

## Implementations

Two official implementations conform to this specification:

| Implementation | Language | Repository |
|----------------|----------|------------|
| whisker-core | Lua | [writewhisker/whisker-core](https://github.com/writewhisker/whisker-core) |
| whisker-editor-web | TypeScript | [writewhisker/whisker-editor-web](https://github.com/writewhisker/whisker-editor-web) |

Both implementations pass the unified test corpus with 100% parity.

## Quick Start

### Reading the Specification

Start with `spec/01-INTRODUCTION.md` for an overview, then explore:
- `spec/03-SYNTAX.md` - Text format syntax
- `spec/06-CHOICES.md` - Interactive choices
- `spec/07-LUA_API.md` - Scripting API

### Running Examples

Examples are organized by difficulty in `examples/`:

```bash
# Beginner stories
examples/beginner/01-first-story.ws

# Intermediate features
examples/intermediate/03-conditionals-demo.ws

# Advanced games
examples/advanced/06-complete-game.ws
```

### Running Conformance Tests

```bash
# TypeScript test runner
cd tools && npm install && npm test

# Lua test runner
cd tools && lua validation-corpus-runner.lua
```

## File Format

WLS stories use the `.ws` extension and are UTF-8 encoded plain text.

```whisker
@title: My Story
@start: Beginning

@vars
  gold: 100
  hasKey: false

:: Beginning
You find yourself at a crossroads.

+ [Go north] -> North
+ {$hasKey} [Unlock the gate] -> Secret
```

## Validation Error Codes

The specification defines 56 error codes across 10 categories:

| Category | Prefix | Description |
|----------|--------|-------------|
| Structure | STR | Story structure issues |
| Links | LNK | Navigation and links |
| Variables | VAR | Variable usage |
| Expressions | EXP | Expression syntax |
| Types | TYP | Type checking |
| Flow | FLW | Control flow |
| Quality | QUA | Quality metrics |
| Syntax | SYN | Parse errors |
| Assets | AST | Asset references |
| Metadata | META | Metadata issues |

See `spec/11-VALIDATION.md` for complete error code documentation.

## Contributing

1. Fork the repository
2. Make your changes
3. Ensure tests pass
4. Submit a pull request

## License

See LICENSE file.
