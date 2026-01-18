# Appendix A: Keywords

**Whisker Language Specification 1.0**

---

## A.1 Reserved Keywords

These words are reserved and cannot be used as identifiers:

| Keyword | Category | Description |
|---------|----------|-------------|
| `and` | Logical | Logical AND operator |
| `or` | Logical | Logical OR operator |
| `not` | Logical | Logical NOT operator |
| `true` | Literal | Boolean true value |
| `false` | Literal | Boolean false value |
| `else` | Control | Else clause in conditionals |
| `elif` | Control | Else-if clause in conditionals |
| `END` | Navigation | Special target: end story |
| `BACK` | Navigation | Special target: go back |
| `RESTART` | Navigation | Special target: restart story |

## A.2 Contextual Keywords

These words have special meaning in specific contexts but may be used as identifiers:

| Keyword | Context | Description |
|---------|---------|-------------|
| `whisker` | Lua | API namespace |

## A.3 Directive Keywords

Used in story and passage headers:

| Directive | Context | Description |
|-----------|---------|-------------|
| `@title` | Story | Story title |
| `@author` | Story | Author name |
| `@version` | Story | Story version |
| `@ifid` | Story | Interactive Fiction ID |
| `@start` | Story | Start passage |
| `@description` | Story | Story description |
| `@created` | Story | Creation date |
| `@modified` | Story | Modification date |
| `@vars` | Story | Variable declarations block |
| `@tags` | Passage | Passage tags |
| `@color` | Passage | Editor color |
| `@position` | Passage | Editor position |
| `@notes` | Passage | Author notes |
| `@onEnter` | Passage | Entry script |
| `@onExit` | Passage | Exit script |
| `@fallback` | Passage | Fallback passage |

---

**Next Appendix:** [Operators](APPENDIX-B-OPERATORS.md)
