# IDE Integration Guide

This guide explains how to set up IDE integration for WLS development.

## VSCode Extension

### Installation

The Whisker VSCode extension provides full IDE support:

1. Open VSCode Extensions (Ctrl+Shift+X)
2. Search for "Whisker Language"
3. Click Install

### Features

- **Syntax Highlighting**: Full WLS syntax highlighting
- **IntelliSense**: Autocomplete for passages, variables, functions
- **Diagnostics**: Real-time error and warning display
- **Go to Definition**: Ctrl+Click on passage names
- **Find References**: Find all uses of a passage or variable
- **Hover Information**: View passage previews and variable info
- **Code Folding**: Collapse passages and blocks
- **Outline View**: Navigate passages in the sidebar

### Configuration

```json
{
  "whisker.validation.enabled": true,
  "whisker.validation.rules": ["all"],
  "whisker.preview.theme": "dark",
  "whisker.preview.autoOpen": false,
  "whisker.debug.showVariables": true
}
```

## Language Server Protocol

The Whisker Language Server can be used with any LSP-compatible editor.

### Starting the Server

```bash
# Via stdio (default)
whisker-lsp

# With debug logging
whisker-lsp --log-level=debug

# Via TCP
whisker-lsp --transport=tcp:9999
```

### Capabilities

| Capability | Support | Description |
|------------|---------|-------------|
| textDocumentSync | Full | Document synchronization |
| completionProvider | Yes | Autocomplete |
| hoverProvider | Yes | Hover information |
| definitionProvider | Yes | Go to definition |
| referencesProvider | Yes | Find all references |
| documentSymbolProvider | Yes | Document outline |
| diagnosticProvider | Yes | Real-time validation |

### Sublime Text

1. Install the LSP package
2. Add configuration:

```json
{
  "clients": {
    "whisker": {
      "command": ["whisker-lsp"],
      "selector": "source.whisker",
      "syntaxes": ["Packages/Whisker/Whisker.sublime-syntax"]
    }
  }
}
```

### Vim/Neovim

Using coc.nvim:

```json
{
  "languageserver": {
    "whisker": {
      "command": "whisker-lsp",
      "filetypes": ["whisker"],
      "rootPatterns": [".git", "story.ws"]
    }
  }
}
```

Using native LSP (Neovim 0.5+):

```lua
require('lspconfig').whisker.setup{
  cmd = { "whisker-lsp" },
  filetypes = { "whisker" },
  root_dir = require('lspconfig').util.root_pattern(".git", "story.ws"),
}
```

### Emacs

Using lsp-mode:

```elisp
(require 'lsp-mode)

(add-to-list 'lsp-language-id-configuration '(whisker-mode . "whisker"))

(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection "whisker-lsp")
  :major-modes '(whisker-mode)
  :server-id 'whisker-lsp))
```

## TextMate Grammar

A TextMate grammar is available for syntax highlighting:

`packages/whisker-lsp/syntaxes/whisker.tmLanguage.json`

### Scopes

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

## CLI Tools

### whisker-lint

Validate WLS files from the command line:

```bash
# Basic usage
whisker-lint story.ws

# Multiple files
whisker-lint *.ws

# JSON output for CI
whisker-lint --format=json story.ws

# SARIF format for GitHub Actions
whisker-lint --format=sarif story.ws > report.sarif

# Only show errors
whisker-lint --severity=errors story.ws
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | No errors |
| 1 | Errors found |
| 2 | Invalid arguments |

## CI/CD Integration

### GitHub Actions

```yaml
name: Lint

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Install whisker-lint
        run: npm install -g @writewhisker/cli-lint

      - name: Run linter
        run: whisker-lint --format=sarif story.ws > results.sarif

      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: results.sarif
```

### GitLab CI

```yaml
lint:
  image: node:20
  script:
    - npm install -g @writewhisker/cli-lint
    - whisker-lint story.ws
  only:
    - merge_requests
```

## Troubleshooting

### Language Server Not Starting

1. Check the server is installed: `which whisker-lsp`
2. Check logs: `whisker-lsp --log-level=debug`
3. Verify file associations in your editor

### Syntax Highlighting Not Working

1. Ensure file has `.ws` or `.whisker` extension
2. Reload window in VSCode (Ctrl+Shift+P > Reload Window)
3. Check the language mode in the status bar

### Completions Not Appearing

1. Wait for document to be parsed (watch diagnostics)
2. Check trigger characters: `$`, `->`, `[`
3. Ensure cursor is in correct context

## Support

- Report issues: https://github.com/writewhisker/whisker-editor-web/issues
- Documentation: https://wls.whisker.dev
