# Gap 6: Developer Experience

## Problem Statement

WLS 1.0 lacks modern developer tooling:

1. **LSP Support** - No language server protocol implementation
2. **Live Preview** - Only in whisker-editor-web, not standalone
3. **Debugging** - No step-through execution or breakpoints
4. **Error Messages** - Inconsistent, sometimes cryptic

Professional authoring requires IDE integration and debugging.

## Goals

1. Implement WLS Language Server (LSP)
2. Create standalone preview/test tool
3. Add debugging support with breakpoints
4. Improve error message quality and consistency
5. Enable IDE integration (VSCode, etc.)

## Features Overview

### Language Server Protocol
- Syntax highlighting (TextMate grammar)
- Autocomplete for passages, variables, functions
- Go-to-definition for passage links
- Find all references
- Hover information
- Diagnostics (real-time validation)

### Debugging
- Breakpoints on passages
- Variable inspection
- Step through choices
- Call stack view (for tunnels)
- Watch expressions

### Error Messages
- Clear, actionable messages
- Source location with context
- Suggested fixes
- Error codes with documentation links

## Affected Files

### New Package: whisker-lsp
- `packages/whisker-lsp/` (new package in whisker-editor-web)
- `bin/whisker-lsp` (CLI binary)

### whisker-core
- `bin/whisker-debug` (new)
- `lib/whisker/debug/` (new)
- `lib/whisker/lsp/` (optional Lua LSP)

### whisker-editor-web
- `packages/parser/src/` (error improvements)
- `packages/story-validation/src/` (diagnostic formatting)
- `packages/whisker-lsp/` (new)

---

## Phase 6.1: Error Message Improvements

### Task 6.1.1: Define Error Message Format

**Objective:** Standardize error message structure.

**Steps:**
1. Define error message template
2. Include source context (code snippet)
3. Add caret pointing to error location
4. Include error code and documentation link
5. Add suggestion field

**Format:**
```
WLS-SYN-001: Unexpected token at line 5, column 12

  4 | + [Go to shop]
  5 | -> Shop
       ^^
       Expected passage name after '->'

Suggestion: Did you mean '-> Shop' (passage "Shop" exists)?
See: https://wls.spec/errors/WLS-SYN-001
```

**Estimated tokens:** ~3,000

---

### Task 6.1.2: Improve Lua Parser Errors

**Objective:** Enhance error messages in Lua parser.

**Steps:**
1. Add source context extraction
2. Implement caret generation
3. Add suggestion generation
4. Format errors consistently
5. Add error formatting tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~5,000

---

### Task 6.1.3: Improve TypeScript Parser Errors

**Objective:** Enhance error messages in TypeScript.

**Steps:**
1. Add source context extraction
2. Implement caret generation
3. Add suggestion generation
4. Match Lua error format
5. Add error formatting tests

**Code location:** `packages/parser/src/parser.ts`

**Estimated tokens:** ~5,000

---

### Task 6.1.4: Error Documentation

**Objective:** Document all error codes.

**Steps:**
1. Create error code reference
2. Document each error with examples
3. Provide fix suggestions
4. Add common mistake patterns
5. Create searchable index

**Deliverables:**
- `docs/ERROR_CODES.md`
- Error code index

**Estimated tokens:** ~4,000

---

### Review Checkpoint 6.1

**Verification:**
- [ ] Error messages consistent between platforms
- [ ] Source context shown
- [ ] Suggestions provided
- [ ] Documentation complete
- [ ] Tests pass

---

## Phase 6.2: Language Server Implementation

### Task 6.2.1: LSP Package Setup

**Objective:** Create whisker-lsp package.

**Steps:**
1. Create `packages/whisker-lsp/` structure
2. Set up vscode-languageserver dependencies
3. Create basic server skeleton
4. Add TypeScript configuration
5. Add build scripts

**Code location:** `packages/whisker-lsp/`

**Estimated tokens:** ~4,000

---

### Task 6.2.2: TextMate Grammar

**Objective:** Create syntax highlighting grammar.

**Steps:**
1. Create `whisker.tmLanguage.json`
2. Define token patterns for WLS
3. Handle passage headers
4. Handle choices and links
5. Handle code blocks and expressions

**Code location:** `packages/whisker-lsp/syntaxes/`

**Estimated tokens:** ~4,000

---

### Task 6.2.3: Document Sync and Parsing

**Objective:** Implement document management.

**Steps:**
1. Handle `textDocument/didOpen`
2. Handle `textDocument/didChange`
3. Implement incremental parsing
4. Cache parse results
5. Add document management tests

**Code location:** `packages/whisker-lsp/src/server.ts`

**Estimated tokens:** ~5,000

---

### Task 6.2.4: Diagnostics Provider

**Objective:** Provide real-time error feedback.

**Steps:**
1. Run validators on document change
2. Convert validation issues to LSP diagnostics
3. Include severity mapping
4. Add code actions for fixable issues
5. Add diagnostic tests

**Code location:** `packages/whisker-lsp/src/providers/diagnostics.ts`

**Estimated tokens:** ~5,000

---

### Task 6.2.5: Completion Provider

**Objective:** Implement autocomplete.

**Steps:**
1. Complete passage names after `->`
2. Complete variable names after `$`
3. Complete function names
4. Complete keywords
5. Add completion tests

**Code location:** `packages/whisker-lsp/src/providers/completion.ts`

**Estimated tokens:** ~6,000

---

### Task 6.2.6: Definition and References

**Objective:** Navigate between passages.

**Steps:**
1. Implement `textDocument/definition`
2. Implement `textDocument/references`
3. Handle cross-file navigation
4. Handle namespace resolution
5. Add navigation tests

**Code location:** `packages/whisker-lsp/src/providers/navigation.ts`

**Estimated tokens:** ~5,000

---

### Task 6.2.7: Hover Provider

**Objective:** Show information on hover.

**Steps:**
1. Show passage preview on link hover
2. Show variable type and value
3. Show function signature
4. Show error explanation
5. Add hover tests

**Code location:** `packages/whisker-lsp/src/providers/hover.ts`

**Estimated tokens:** ~4,000

---

### Review Checkpoint 6.2

**Verification:**
- [ ] LSP server starts and connects
- [ ] Syntax highlighting works
- [ ] Diagnostics appear in real-time
- [ ] Autocomplete works
- [ ] Navigation works
- [ ] Hover shows information

**Test command:**
```bash
cd whisker-editor-web && pnpm --filter whisker-lsp test
```

---

## Phase 6.3: VSCode Extension

### Task 6.3.1: Extension Package Setup

**Objective:** Create VSCode extension wrapper.

**Steps:**
1. Create `packages/vscode-whisker/`
2. Configure package.json with VSCode manifest
3. Set up extension entry point
4. Configure language contribution
5. Add extension icon and metadata

**Code location:** `packages/vscode-whisker/`

**Estimated tokens:** ~4,000

---

### Task 6.3.2: Extension Client

**Objective:** Connect to language server.

**Steps:**
1. Implement extension activation
2. Start language server process
3. Create language client
4. Handle server lifecycle
5. Add client configuration

**Code location:** `packages/vscode-whisker/src/extension.ts`

**Estimated tokens:** ~4,000

---

### Task 6.3.3: Preview Panel

**Objective:** Add live preview in VSCode.

**Steps:**
1. Create webview panel
2. Integrate story player
3. Sync with document changes
4. Handle choice selection
5. Add preview tests

**Code location:** `packages/vscode-whisker/src/preview/`

**Estimated tokens:** ~6,000

---

### Task 6.3.4: Extension Configuration

**Objective:** Add user settings.

**Steps:**
1. Add validation settings
2. Add preview settings
3. Add theme settings
4. Add debug settings
5. Document settings

**Code location:** `packages/vscode-whisker/package.json`

**Estimated tokens:** ~3,000

---

### Review Checkpoint 6.3

**Verification:**
- [ ] Extension installs in VSCode
- [ ] Language features work
- [ ] Preview panel works
- [ ] Settings apply
- [ ] Extension stable

---

## Phase 6.4: Debugging Support

### Task 6.4.1: Debug Adapter Protocol

**Objective:** Implement DAP for debugging.

**Steps:**
1. Create debug adapter skeleton
2. Implement launch/attach requests
3. Handle breakpoint events
4. Implement step/continue/pause
5. Add adapter tests

**Code location:** `packages/whisker-lsp/src/debug/`

**Estimated tokens:** ~7,000

---

### Task 6.4.2: Breakpoint Management

**Objective:** Handle breakpoints in story.

**Steps:**
1. Support passage breakpoints
2. Support choice breakpoints
3. Support conditional breakpoints
4. Persist breakpoints
5. Add breakpoint tests

**Code location:** `packages/whisker-lsp/src/debug/breakpoints.ts`

**Estimated tokens:** ~5,000

---

### Task 6.4.3: Variable Inspector

**Objective:** Inspect variables during debug.

**Steps:**
1. Implement variables request
2. Show story variables
3. Show temp variables
4. Show computed values
5. Add inspector tests

**Code location:** `packages/whisker-lsp/src/debug/variables.ts`

**Estimated tokens:** ~4,000

---

### Task 6.4.4: Call Stack View

**Objective:** Show tunnel call stack.

**Steps:**
1. Implement stack trace request
2. Show passage navigation history
3. Show tunnel call frames
4. Handle stack navigation
5. Add stack tests

**Code location:** `packages/whisker-lsp/src/debug/callstack.ts`

**Estimated tokens:** ~4,000

---

### Task 6.4.5: Debug UI in VSCode

**Objective:** Integrate debug adapter with VSCode.

**Steps:**
1. Configure debug contribution
2. Create launch configurations
3. Add debug toolbar integration
4. Handle debug events
5. Add UI tests

**Code location:** `packages/vscode-whisker/`

**Estimated tokens:** ~5,000

---

### Review Checkpoint 6.4

**Verification:**
- [ ] Breakpoints can be set
- [ ] Execution pauses at breakpoints
- [ ] Variables can be inspected
- [ ] Step commands work
- [ ] Call stack visible

---

## Phase 6.5: CLI Tools and Integration

### Task 6.5.1: Standalone Preview Tool

**Objective:** Create CLI preview/test tool.

**Steps:**
1. Create `bin/whisker-preview`
2. Implement terminal-based preview
3. Add choice selection via keyboard
4. Add variable display
5. Add preview tests

**Code location:** `whisker-core/bin/whisker-preview`

**Estimated tokens:** ~5,000

---

### Task 6.5.2: Lint Command

**Objective:** Create standalone linter.

**Steps:**
1. Create `bin/whisker-lint`
2. Implement validation runner
3. Add output formatters (text, JSON, SARIF)
4. Add CI-friendly exit codes
5. Add lint tests

**Code location:** `whisker-core/bin/whisker-lint`

**Estimated tokens:** ~4,000

---

### Task 6.5.3: Format Command

**Objective:** Create code formatter.

**Steps:**
1. Create `bin/whisker-fmt`
2. Implement pretty-printer
3. Handle indentation
4. Handle line length
5. Add format tests

**Code location:** `whisker-core/bin/whisker-fmt`

**Estimated tokens:** ~5,000

---

### Task 6.5.4: Documentation

**Objective:** Document all tools.

**Steps:**
1. Document LSP setup for IDEs
2. Document VSCode extension
3. Document CLI tools
4. Create getting started guide
5. Add troubleshooting section

**Deliverables:**
- `docs/IDE_INTEGRATION.md`
- `docs/CLI_TOOLS.md`

**Estimated tokens:** ~4,000

---

### Review Checkpoint 6.5 (Gap 6 Complete)

**Verification:**
- [ ] LSP fully functional
- [ ] VSCode extension works
- [ ] Debugging works
- [ ] CLI tools work
- [ ] Documentation complete

**Final metrics:**
| Metric | Before | After |
|--------|--------|-------|
| IDE integration | None | Full LSP |
| Debugging | None | Full DAP |
| CLI tools | Basic | Complete suite |
| Error messages | Inconsistent | Standardized |

**Deliverables:**
- `packages/whisker-lsp/` - Language server
- `packages/vscode-whisker/` - VSCode extension
- `bin/whisker-preview` - Terminal preview
- `bin/whisker-lint` - Standalone linter
- `bin/whisker-fmt` - Code formatter

**Sign-off requirements:**
- Professional tooling available
- IDE integration documented
- Ready for Gap 7
