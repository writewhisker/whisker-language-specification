# Appendix I: TextMate Grammar

**Whisker Language Specification 1.0**

---

This appendix provides a complete TextMate grammar for Whisker syntax highlighting.

## I.1 Grammar Definition

The following JSON defines the TextMate grammar for `.ws` files:

```json
{
  "name": "Whisker",
  "scopeName": "source.whisker",
  "fileTypes": ["ws"],
  "patterns": [
    { "include": "#comment" },
    { "include": "#passage" },
    { "include": "#directive" },
    { "include": "#choice" },
    { "include": "#navigation" },
    { "include": "#conditional" },
    { "include": "#alternative" },
    { "include": "#variable" },
    { "include": "#lua-block" },
    { "include": "#string" }
  ],
  "repository": {
    "comment": {
      "patterns": [
        {
          "name": "comment.line.double-slash.whisker",
          "match": "//.*$"
        },
        {
          "name": "comment.block.whisker",
          "begin": "/\\*",
          "end": "\\*/"
        }
      ]
    },
    "passage": {
      "name": "meta.passage.whisker",
      "match": "^(::)\\s*([A-Za-z_][A-Za-z0-9_]*)",
      "captures": {
        "1": { "name": "punctuation.definition.passage.whisker" },
        "2": { "name": "entity.name.passage.whisker" }
      }
    },
    "directive": {
      "name": "meta.directive.whisker",
      "match": "^(@[a-z]+):\\s*(.*)$",
      "captures": {
        "1": { "name": "keyword.control.directive.whisker" },
        "2": { "name": "string.unquoted.directive-value.whisker" }
      }
    },
    "choice": {
      "patterns": [
        {
          "name": "meta.choice.once.whisker",
          "match": "^(\\+)\\s*(\\{[^}]*\\})?\\s*(\\[[^\\]]*\\])\\s*(\\{[^}]*\\})?\\s*(->)\\s*([A-Za-z_][A-Za-z0-9_]*|END|BACK|RESTART)",
          "captures": {
            "1": { "name": "keyword.operator.choice.once.whisker" },
            "2": { "name": "meta.condition.whisker" },
            "3": { "name": "string.quoted.choice-text.whisker" },
            "4": { "name": "meta.action.whisker" },
            "5": { "name": "keyword.operator.navigation.whisker" },
            "6": { "name": "entity.name.passage.target.whisker" }
          }
        },
        {
          "name": "meta.choice.sticky.whisker",
          "match": "^(\\*)\\s*(\\{[^}]*\\})?\\s*(\\[[^\\]]*\\])\\s*(\\{[^}]*\\})?\\s*(->)\\s*([A-Za-z_][A-Za-z0-9_]*|END|BACK|RESTART)",
          "captures": {
            "1": { "name": "keyword.operator.choice.sticky.whisker" },
            "2": { "name": "meta.condition.whisker" },
            "3": { "name": "string.quoted.choice-text.whisker" },
            "4": { "name": "meta.action.whisker" },
            "5": { "name": "keyword.operator.navigation.whisker" },
            "6": { "name": "entity.name.passage.target.whisker" }
          }
        }
      ]
    },
    "navigation": {
      "patterns": [
        {
          "name": "meta.navigation.tunnel.whisker",
          "match": "(->->)\\s*([A-Za-z_][A-Za-z0-9_]*)?",
          "captures": {
            "1": { "name": "keyword.operator.tunnel.whisker" },
            "2": { "name": "entity.name.passage.target.whisker" }
          }
        },
        {
          "name": "meta.navigation.goto.whisker",
          "match": "(->)\\s*([A-Za-z_][A-Za-z0-9_]*|END|BACK|RESTART)",
          "captures": {
            "1": { "name": "keyword.operator.navigation.whisker" },
            "2": { "name": "entity.name.passage.target.whisker" }
          }
        }
      ]
    },
    "conditional": {
      "patterns": [
        {
          "name": "keyword.control.conditional.whisker",
          "match": "\\{(/|else|elif\\s+[^}]+)\\}"
        },
        {
          "name": "meta.conditional.block.whisker",
          "begin": "\\{(?=\\$|_|not\\s|true|false)",
          "end": "\\}",
          "beginCaptures": {
            "0": { "name": "punctuation.definition.conditional.begin.whisker" }
          },
          "endCaptures": {
            "0": { "name": "punctuation.definition.conditional.end.whisker" }
          },
          "patterns": [
            { "include": "#expression" }
          ]
        }
      ]
    },
    "alternative": {
      "patterns": [
        {
          "name": "meta.alternative.sequence.whisker",
          "begin": "\\{\\|",
          "end": "\\}",
          "beginCaptures": {
            "0": { "name": "punctuation.definition.alternative.begin.whisker" }
          },
          "endCaptures": {
            "0": { "name": "punctuation.definition.alternative.end.whisker" }
          }
        },
        {
          "name": "meta.alternative.cycle.whisker",
          "begin": "\\{&\\|",
          "end": "\\}",
          "beginCaptures": {
            "0": { "name": "punctuation.definition.alternative.cycle.whisker" }
          },
          "endCaptures": {
            "0": { "name": "punctuation.definition.alternative.end.whisker" }
          }
        },
        {
          "name": "meta.alternative.shuffle.whisker",
          "begin": "\\{~\\|",
          "end": "\\}",
          "beginCaptures": {
            "0": { "name": "punctuation.definition.alternative.shuffle.whisker" }
          },
          "endCaptures": {
            "0": { "name": "punctuation.definition.alternative.end.whisker" }
          }
        },
        {
          "name": "meta.alternative.once.whisker",
          "begin": "\\{!\\|",
          "end": "\\}",
          "beginCaptures": {
            "0": { "name": "punctuation.definition.alternative.once.whisker" }
          },
          "endCaptures": {
            "0": { "name": "punctuation.definition.alternative.end.whisker" }
          }
        }
      ]
    },
    "variable": {
      "patterns": [
        {
          "name": "variable.other.story.whisker",
          "match": "\\$[A-Za-z_][A-Za-z0-9_]*"
        },
        {
          "name": "variable.other.temp.whisker",
          "match": "_[A-Za-z_][A-Za-z0-9_]*"
        },
        {
          "name": "meta.interpolation.whisker",
          "begin": "\\$\\{",
          "end": "\\}",
          "beginCaptures": {
            "0": { "name": "punctuation.definition.interpolation.begin.whisker" }
          },
          "endCaptures": {
            "0": { "name": "punctuation.definition.interpolation.end.whisker" }
          },
          "patterns": [
            { "include": "#expression" }
          ]
        }
      ]
    },
    "lua-block": {
      "patterns": [
        {
          "name": "meta.embedded.lua.whisker",
          "begin": "\\{\\{",
          "end": "\\}\\}",
          "beginCaptures": {
            "0": { "name": "punctuation.definition.lua.begin.whisker" }
          },
          "endCaptures": {
            "0": { "name": "punctuation.definition.lua.end.whisker" }
          },
          "contentName": "source.lua"
        }
      ]
    },
    "string": {
      "name": "string.quoted.double.whisker",
      "begin": "\"",
      "end": "\"",
      "beginCaptures": {
        "0": { "name": "punctuation.definition.string.begin.whisker" }
      },
      "endCaptures": {
        "0": { "name": "punctuation.definition.string.end.whisker" }
      },
      "patterns": [
        {
          "name": "constant.character.escape.whisker",
          "match": "\\\\."
        }
      ]
    },
    "expression": {
      "patterns": [
        { "include": "#variable" },
        { "include": "#string" },
        {
          "name": "constant.numeric.whisker",
          "match": "-?\\d+(\\.\\d+)?"
        },
        {
          "name": "constant.language.boolean.whisker",
          "match": "\\b(true|false)\\b"
        },
        {
          "name": "keyword.operator.logical.whisker",
          "match": "\\b(and|or|not)\\b"
        },
        {
          "name": "keyword.operator.comparison.whisker",
          "match": "(==|~=|!=|<=|>=|<|>)"
        },
        {
          "name": "keyword.operator.arithmetic.whisker",
          "match": "(\\+|-|\\*|/|%)"
        },
        {
          "name": "keyword.operator.assignment.whisker",
          "match": "(\\+=|-=|\\*=|/=|=)"
        },
        {
          "name": "keyword.operator.string.whisker",
          "match": "\\.\\."
        }
      ]
    }
  }
}
```

## I.2 Scope Mapping

| Scope | Color Theme Mapping | Description |
|-------|---------------------|-------------|
| `comment.*` | Comment | Line and block comments |
| `entity.name.passage` | Entity Name | Passage names |
| `keyword.control.*` | Keyword | Directives, conditionals |
| `keyword.operator.*` | Operator | Navigation, choice markers |
| `variable.other.story` | Variable | Story-scoped variables |
| `variable.other.temp` | Variable (dimmed) | Temporary variables |
| `string.quoted.*` | String | String literals, choice text |
| `constant.numeric` | Number | Numeric literals |
| `constant.language.boolean` | Constant | true/false |
| `source.lua` | Embedded Lua | Lua code blocks |

## I.3 VS Code Extension

For VS Code, create `package.json`:

```json
{
  "name": "whisker-language",
  "displayName": "Whisker Language",
  "description": "Syntax highlighting for Whisker interactive fiction",
  "version": "1.0.0",
  "engines": { "vscode": "^1.60.0" },
  "categories": ["Programming Languages"],
  "contributes": {
    "languages": [{
      "id": "whisker",
      "aliases": ["Whisker", "whisker"],
      "extensions": [".ws"],
      "configuration": "./language-configuration.json"
    }],
    "grammars": [{
      "language": "whisker",
      "scopeName": "source.whisker",
      "path": "./syntaxes/whisker.tmLanguage.json"
    }]
  }
}
```

## I.4 Language Configuration

Create `language-configuration.json`:

```json
{
  "comments": {
    "lineComment": "//",
    "blockComment": ["/*", "*/"]
  },
  "brackets": [
    ["{", "}"],
    ["[", "]"],
    ["(", ")"]
  ],
  "autoClosingPairs": [
    { "open": "{", "close": "}" },
    { "open": "[", "close": "]" },
    { "open": "(", "close": ")" },
    { "open": "\"", "close": "\"" },
    { "open": "{{", "close": "}}" }
  ],
  "surroundingPairs": [
    ["{", "}"],
    ["[", "]"],
    ["(", ")"],
    ["\"", "\""]
  ],
  "folding": {
    "markers": {
      "start": "^\\s*::\\s*\\w+",
      "end": "^\\s*::\\s*\\w+"
    }
  },
  "indentationRules": {
    "increaseIndentPattern": "^\\s*\\{[^/].*$",
    "decreaseIndentPattern": "^\\s*\\{/\\}\\s*$"
  }
}
```

## I.5 Sublime Text

For Sublime Text, save the grammar as `Whisker.sublime-syntax`:

```yaml
%YAML 1.2
---
name: Whisker
file_extensions: [ws]
scope: source.whisker

contexts:
  main:
    - include: comments
    - include: passages
    - include: directives
    - include: choices
    - include: navigation
    - include: conditionals
    - include: alternatives
    - include: variables
    - include: lua-blocks
    - include: strings

  comments:
    - match: '//'
      scope: punctuation.definition.comment.whisker
      push:
        - meta_scope: comment.line.whisker
        - match: $
          pop: true
    - match: '/\*'
      scope: punctuation.definition.comment.begin.whisker
      push:
        - meta_scope: comment.block.whisker
        - match: '\*/'
          scope: punctuation.definition.comment.end.whisker
          pop: true

  passages:
    - match: '^(::)\s*([A-Za-z_][A-Za-z0-9_]*)'
      captures:
        1: punctuation.definition.passage.whisker
        2: entity.name.passage.whisker

  directives:
    - match: '^(@[a-z]+):\s*(.*)$'
      captures:
        1: keyword.control.directive.whisker
        2: string.unquoted.directive-value.whisker

  choices:
    - match: '^(\+|\*)\s*'
      captures:
        1: keyword.operator.choice.whisker

  navigation:
    - match: '(->->)\s*([A-Za-z_][A-Za-z0-9_]*)?'
      captures:
        1: keyword.operator.tunnel.whisker
        2: entity.name.passage.target.whisker
    - match: '(->)\s*([A-Za-z_][A-Za-z0-9_]*|END|BACK|RESTART)'
      captures:
        1: keyword.operator.navigation.whisker
        2: entity.name.passage.target.whisker

  conditionals:
    - match: '\{(else|elif\s+[^}]+|/)\}'
      scope: keyword.control.conditional.whisker

  alternatives:
    - match: '\{[&~!]?\|'
      scope: punctuation.definition.alternative.whisker

  variables:
    - match: '\$[A-Za-z_][A-Za-z0-9_]*'
      scope: variable.other.story.whisker
    - match: '_[A-Za-z_][A-Za-z0-9_]*'
      scope: variable.other.temp.whisker

  lua-blocks:
    - match: '\{\{'
      scope: punctuation.definition.lua.begin.whisker
      push:
        - meta_scope: meta.embedded.lua.whisker
        - match: '\}\}'
          scope: punctuation.definition.lua.end.whisker
          pop: true

  strings:
    - match: '"'
      scope: punctuation.definition.string.begin.whisker
      push:
        - meta_scope: string.quoted.double.whisker
        - match: '\\.'
          scope: constant.character.escape.whisker
        - match: '"'
          scope: punctuation.definition.string.end.whisker
          pop: true
```

---

**Previous Appendix:** [Quick Reference](APPENDIX-H-QUICK-REF.md)
