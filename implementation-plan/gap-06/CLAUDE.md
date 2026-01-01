# Gap 6: Developer Experience

## Context

Add professional development tools: Language Server Protocol (LSP), debugging, and improved error messages.

## Repositories

- **whisker-core**: `/Users/jims/code/github.com/writewhisker/whisker-core`
- **whisker-editor-web**: `/Users/jims/code/github.com/writewhisker/whisker-editor-web`
- **specification**: `/Users/jims/code/github.com/whisker-language-specification-1.0`

## Features to Implement

### Language Server
- Syntax highlighting (TextMate grammar)
- Autocomplete (passages, variables, functions)
- Go-to-definition for passage links
- Find all references
- Hover information
- Real-time diagnostics

### Debugging
- Breakpoints on passages
- Variable inspection
- Step through choices
- Call stack view (for tunnels)

### Error Messages
- Source context with code snippet
- Caret pointing to error location
- Suggested fixes
- Error code documentation links

## New Packages to Create

### whisker-lsp (in whisker-editor-web)
```
packages/whisker-lsp/
├── src/
│   ├── server.ts           # Main LSP server
│   ├── providers/
│   │   ├── diagnostics.ts  # Real-time validation
│   │   ├── completion.ts   # Autocomplete
│   │   ├── navigation.ts   # Go-to-definition
│   │   └── hover.ts        # Hover info
│   └── debug/
│       ├── adapter.ts      # Debug Adapter Protocol
│       ├── breakpoints.ts
│       └── variables.ts
└── syntaxes/
    └── whisker.tmLanguage.json
```

### vscode-whisker (in whisker-editor-web)
```
packages/vscode-whisker/
├── src/
│   ├── extension.ts        # Extension entry
│   └── preview/            # Live preview panel
└── package.json            # VSCode manifest
```

## CLI Tools to Create (whisker-core)

- `bin/whisker-lint` - Standalone linter
- `bin/whisker-fmt` - Code formatter
- `bin/whisker-preview` - Terminal preview

## Commands

```bash
# Run LSP tests
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter whisker-lsp test -- --run

# Test VSCode extension
cd packages/vscode-whisker
code --extensionDevelopmentPath=.
```

## Dependencies

- `vscode-languageserver` - LSP implementation
- `vscode-languageclient` - VSCode client
- `@vscode/debugadapter` - Debug Adapter Protocol

## Error Message Format

```
WLS-SYN-001: Unexpected token at line 5, column 12

  4 | + [Go to shop]
  5 | -> Shop
       ^^
       Expected passage name after '->'

Suggestion: Did you mean '-> Shop' (passage "Shop" exists)?
See: https://wls.spec/errors/WLS-SYN-001
```

## Success Criteria

- LSP provides real-time feedback in VSCode
- Autocomplete suggests valid completions
- Navigation jumps to passage definitions
- Debugger can pause and inspect state
- Error messages are clear and actionable
- CLI tools work standalone
