# Chapter 14: Developer Experience

This chapter specifies WLS's developer tooling including error messages, language server protocol, debugging, and CLI tools.

## 14.1 Error Message Format

WLS uses a standardized error message format across all platforms.

### 14.1.1 Error Message Structure

```
{ERROR_CODE}: {BRIEF_DESCRIPTION} at line {LINE}, column {COLUMN}

  {LINE-2} | {source line before}
  {LINE-1} | {source line before}
  {LINE}   | {source line with error}
           {CARET_INDICATOR}
           {EXPLANATION}

Suggestion: {FIX_SUGGESTION}
See: https://wls.whisker.dev/errors/{ERROR_CODE}
```

### 14.1.2 Example Error Messages

**Undefined Passage:**
```
WLS-LNK-001: Choice links to non-existent passage at line 5, column 8

  4 | :: Start
  5 | + [Go to shop] -> Shopp
                        ^^^^^
                        Passage "Shopp" does not exist

Suggestion: Did you mean "Shop"?
See: https://wls.whisker.dev/errors/WLS-LNK-001
```

**Undefined Variable:**
```
WLS-VAR-001: Undefined variable at line 12, column 15

  11 | :: Inventory
  12 | You have ${goldd} gold coins.
                  ^^^^^
                  Variable "$goldd" is not defined

Suggestion: Did you mean "$gold"?
See: https://wls.whisker.dev/errors/WLS-VAR-001
```

**Syntax Error:**
```
WLS-SYN-005: Expected closing brace at line 8, column 1

  6 | {$hasKey}
  7 | You unlock the door.
  8 | + [Enter] -> Room
      ^
      Missing {/} to close conditional block

Suggestion: Add {/} before line 8
See: https://wls.whisker.dev/errors/WLS-SYN-005
```

### 14.1.3 Severity Levels

| Level | Display | Exit Code | Description |
|-------|---------|-----------|-------------|
| error | `error:` | 1 | Must be fixed, prevents execution |
| warning | `warning:` | 0 | Should be fixed, may cause issues |
| info | `info:` | 0 | Informational, best practices |

### 14.1.4 Error Context

Errors should include:
- **Source snippet**: 2-3 lines before the error for context
- **Caret indicator**: Points to the exact location
- **Explanation**: Why this is an error
- **Suggestion**: How to fix it (when determinable)
- **Documentation link**: URL to detailed explanation

## 14.2 Language Server Protocol

WLS provides a Language Server Protocol (LSP) implementation for IDE integration.

### 14.2.1 Supported Capabilities

| Capability | Support | Description |
|------------|---------|-------------|
| `textDocumentSync` | Full | Document synchronization |
| `completionProvider` | Yes | Autocomplete |
| `hoverProvider` | Yes | Hover information |
| `definitionProvider` | Yes | Go to definition |
| `referencesProvider` | Yes | Find all references |
| `documentSymbolProvider` | Yes | Document outline |
| `diagnosticProvider` | Yes | Real-time validation |
| `codeActionProvider` | Yes | Quick fixes |
| `renameProvider` | Yes | Rename symbols |
| `foldingRangeProvider` | Yes | Code folding |

### 14.2.2 Completion Triggers

| Context | Trigger | Completions |
|---------|---------|-------------|
| After `->` | Arrow | Passage names |
| After `$` | Dollar | Story variables |
| After `$_` | Underscore | Temp variables |
| After `.` | Dot | CSS classes, members |
| After `::` | Marker | Namespace::Passage |
| Line start | Any | Keywords, directives |

### 14.2.3 Hover Information

**Passages:**
```
:: PassageName [tags]
─────────────────────
First 3 lines of content...

Choices: 3
Variables used: $gold, $health
Referenced by: Start, Shop
```

**Variables:**
```
$gold (story variable)
─────────────────────
Type: number
Initial value: 100
Used in: 5 passages
Modified in: Shop, Combat
```

**Functions:**
```
FUNCTION greet(name)
─────────────────────
Parameters: name
Returns: formatted greeting
Defined at: line 15
```

### 14.2.4 Diagnostics

Real-time diagnostics include:
- Parse errors
- Validation warnings
- Quality hints
- Performance suggestions

Diagnostics update on:
- Document open
- Document change (debounced 300ms)
- Document save

## 14.3 Debugging Support

WLS supports debugging via the Debug Adapter Protocol (DAP).

### 14.3.1 Breakpoint Types

| Type | Location | Description |
|------|----------|-------------|
| Passage | `:: PassageName` | Break when entering passage |
| Choice | `+ [Text]` | Break when choice is made |
| Conditional | `{condition}` | Break when condition evaluates |
| Variable | `$varname` | Break when variable changes |

### 14.3.2 Debug Commands

| Command | Description |
|---------|-------------|
| Continue | Resume execution |
| Step Over | Execute current passage |
| Step Into | Enter tunnel call |
| Step Out | Return from tunnel |
| Restart | Restart from beginning |
| Pause | Pause execution |

### 14.3.3 Variable Inspection

The debugger provides access to:

**Story Variables:**
```
$gold = 150 (number)
$playerName = "Hero" (string)
$hasKey = true (boolean)
$inventory = ["sword", "shield"] (array)
```

**Temp Variables:**
```
$_count = 3 (number)
$_result = nil
```

**Collections:**
```
LIST moods: [happy, (sad), angry]  # (sad) is active
ARRAY items: [0: "sword", 1: "shield"]
MAP player: {name: "Hero", hp: 100}
```

### 14.3.4 Call Stack

Shows navigation history and tunnel calls:
```
1. Combat::Attack (line 45) <- current
2. Combat::Enter (line 32)
3. Start (line 1)
   └─ [tunnel] Shop (line 15)
```

## 14.4 CLI Tools

WLS includes command-line tools for development workflows.

### 14.4.1 whisker-lint

Validates WLS source files:

```bash
# Validate a single file
whisker-lint story.ws

# Validate with specific rules
whisker-lint --rules=errors,warnings story.ws

# Output formats
whisker-lint --format=text story.ws      # Human-readable (default)
whisker-lint --format=json story.ws      # JSON for tools
whisker-lint --format=sarif story.ws     # SARIF for CI
```

**Exit Codes:**
- 0: No errors
- 1: Errors found
- 2: Invalid arguments

### 14.4.2 whisker-fmt

Formats WLS source files:

```bash
# Format file (write to stdout)
whisker-fmt story.ws

# Format in place
whisker-fmt --write story.ws

# Check formatting (no changes)
whisker-fmt --check story.ws

# Options
whisker-fmt --indent=2 --line-length=80 story.ws
```

**Formatting Rules:**
- Consistent indentation (2 spaces default)
- Blank line between passages
- Aligned choice markers
- Normalized whitespace

### 14.4.3 whisker-preview

Interactive terminal preview:

```bash
# Run story in terminal
whisker-preview story.ws

# With debugging
whisker-preview --debug story.ws

# Show variables
whisker-preview --show-vars story.ws
```

**Commands in Preview:**
- `1-9`: Select choice
- `r`: Restart
- `v`: Show variables
- `h`: Show history
- `q`: Quit

### 14.4.4 whisker-lsp

Language server for IDE integration:

```bash
# Start language server (stdio)
whisker-lsp

# With logging
whisker-lsp --log-level=debug

# Specify transport
whisker-lsp --transport=stdio      # Default
whisker-lsp --transport=tcp:9999   # TCP on port
```

## 14.5 IDE Integration

### 14.5.1 VSCode Extension

The `vscode-whisker` extension provides:
- Syntax highlighting
- IntelliSense (autocomplete)
- Error diagnostics
- Go to definition
- Preview panel
- Debugging

**Configuration:**
```json
{
  "whisker.validation.enabled": true,
  "whisker.validation.rules": ["all"],
  "whisker.preview.theme": "dark",
  "whisker.preview.autoOpen": false,
  "whisker.debug.showVariables": true
}
```

### 14.5.2 TextMate Grammar

WLS uses a TextMate grammar for syntax highlighting:

| Scope | Applies To |
|-------|------------|
| `keyword.control.whisker` | if, else, elif, do |
| `keyword.other.whisker` | LIST, ARRAY, MAP, etc. |
| `entity.name.passage.whisker` | Passage names |
| `variable.story.whisker` | $variables |
| `variable.temp.whisker` | $_variables |
| `string.quoted.whisker` | "strings" |
| `comment.line.whisker` | -- comments |
| `markup.choice.whisker` | + choices |
| `entity.name.function.whisker` | Function names |

### 14.5.3 Semantic Token Types

WLS implementations SHOULD support LSP semantic tokens for rich syntax highlighting.

**Token Types:**

| Token Type | LSP Type | Description |
|------------|----------|-------------|
| `passage` | `class` | Passage names |
| `variable` | `variable` | Story and temp variables |
| `function` | `function` | User-defined functions |
| `hook` | `property` | Hook names |
| `keyword` | `keyword` | Language keywords |
| `operator` | `operator` | Operators |
| `string` | `string` | String literals |
| `number` | `number` | Numeric literals |
| `comment` | `comment` | Comments |
| `directive` | `decorator` | @ directives |
| `namespace` | `namespace` | Namespace names |
| `parameter` | `parameter` | Function parameters |
| `label` | `label` | Gather labels |

**Token Modifiers:**

| Modifier | Description | Applies To |
|----------|-------------|------------|
| `declaration` | Definition site | passage, variable, function, hook |
| `reference` | Usage site | passage, variable, function, hook |
| `modification` | Write access | variable |
| `defaultLibrary` | Built-in API | function (whisker.*) |
| `story` | Story-scoped | variable ($) |
| `temporary` | Passage-scoped | variable (_) |

**Example Tokenization:**

```whisker
:: Shop
$gold = 100
+ {$gold >= 50} [Buy sword] { $gold -= 50 } -> Armory
```

| Text | Type | Modifiers |
|------|------|-----------|
| `Shop` | passage | declaration |
| `gold` | variable | declaration, story |
| `100` | number | - |
| `gold` | variable | reference, story |
| `50` | number | - |
| `gold` | variable | modification, story |
| `Armory` | passage | reference |

**Implementation Notes:**

1. Semantic tokens require AST, not just lexer
2. Cache aggressively for performance
3. Provide tokens even for invalid code
4. Target < 50ms for full document tokenization

### 14.5.4 Other IDEs

The LSP enables integration with:
- **Sublime Text**: Via LSP package
- **Vim/Neovim**: Via coc.nvim or native LSP
- **Emacs**: Via lsp-mode
- **JetBrains**: Via LSP plugin

## 14.6 Error Codes Reference

### 14.6.1 Developer Experience Codes

| Code | Name | Severity | Description |
|------|------|----------|-------------|
| WLS-DEV-001 | lsp_connection_failed | error | Failed to connect to language server |
| WLS-DEV-002 | debug_adapter_error | error | Debug adapter protocol error |
| WLS-DEV-003 | format_parse_error | error | Cannot format: file has parse errors |
| WLS-DEV-004 | preview_runtime_error | warning | Error during story preview |

### 14.6.2 All Error Codes by Category

See Appendix A for complete error code reference.

## 14.7 Best Practices

### 14.7.1 Error Handling

- Always include source context in errors
- Provide actionable suggestions when possible
- Use consistent error codes across platforms
- Link to documentation for complex errors

### 14.7.2 IDE Integration

- Start LSP server on project open
- Cache parse results for performance
- Debounce validation on typing
- Provide code actions for common fixes

### 14.7.3 Debugging

- Set breakpoints on key passages
- Use watch expressions for complex conditions
- Check call stack when in tunnels
- Inspect variables before choices

## 14.8 Incremental Parsing

For responsive IDE experiences, implementations SHOULD support incremental parsing.

### 14.8.1 Synchronization Points

Safe reparse boundaries:

| Boundary | Token | Description |
|----------|-------|-------------|
| Passage start | `::` | Full passage boundary |
| Block end | `{/}` | Conditional block end |
| Choice | `+`, `*` | Choice line start |
| Namespace | `END NAMESPACE` | Namespace boundary |
| Function | `END` | Function boundary |

### 14.8.2 Error Recovery Strategies

| Strategy | When | Recovery |
|----------|------|----------|
| Panic mode | Unclosed block | Skip to next `::` |
| Insertion | Missing `{/}` | Insert virtual close |
| Deletion | Extra `}` | Skip token |
| Synchronization | Lost context | Find next passage |

### 14.8.3 Performance Targets

| Metric | Target | Description |
|--------|--------|-------------|
| Keystroke response | < 16ms | Re-tokenize visible lines |
| Full diagnostics | < 100ms | Complete validation |
| Symbol lookup | < 10ms | Go-to-definition |
| Completion | < 50ms | Autocomplete list |

### 14.8.4 Caching Strategies

1. **Token cache**: Store tokens per line, invalidate on edit
2. **AST cache**: Store passage ASTs, reparse affected passages only
3. **Symbol cache**: Maintain symbol table, update incrementally
4. **Diagnostic cache**: Store per-passage, revalidate changed passages

### 14.8.5 Example Update Flow

```
User types character
  → Invalidate affected line tokens
  → Re-tokenize edited line (< 1ms)
  → Schedule async reparse of affected passage (debounce 100ms)
  → Update visible diagnostics immediately
  → Full validation in background
```

## 14.9 Cross-Platform Lua

### 14.9.1 Lua Version

WLS targets Lua 5.4 semantics. Implementations on platforms without native Lua MUST provide equivalent behavior.

### 14.9.2 Platform Variations

| Platform | Lua Implementation | Notes |
|----------|-------------------|-------|
| Desktop | Native Lua 5.4 | Reference implementation |
| Web | Fengari / WASM | Verify number handling |
| Mobile | LuaJIT / Native | May have JIT differences |
| Embedded | eLua / custom | Memory-constrained |

### 14.9.3 Portability Requirements

Implementations MUST:

1. Support IEEE 754 doubles for numbers
2. Handle UTF-8 strings correctly
3. Provide consistent math.random behavior (seedable)
4. Implement all required whisker.* APIs identically

### 14.9.4 Testing Cross-Platform

The WLS test corpus includes platform validation tests:

```yaml
# test-corpus/cross-platform/number-handling.yaml
- input: "{{ 0.1 + 0.2 }}"
  expected: "0.30000000000000004"  # IEEE 754 behavior

# test-corpus/cross-platform/string-utf8.yaml
- input: "{{ string.len('日本語') }}"
  expected: "9"  # Byte length, not character count
```
