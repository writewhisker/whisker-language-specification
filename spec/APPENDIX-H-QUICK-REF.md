# Appendix H: Quick Reference (Cheat Sheet)

**Whisker Language Specification 1.0**

---

## Syntax at a Glance

| Construct | Syntax | Example |
|-----------|--------|---------|
| Passage | `:: Name` | `:: Kitchen` |
| Navigation | `-> Target` | `-> Kitchen` |
| Tunnel | `->-> Target` | `->-> Stats` |
| Choice (once) | `* [text] -> Target` | `* [Open door] -> Room` |
| Choice (sticky) | `+ [text] -> Target` | `+ [Look around] -> Here` |
| Variable read | `$name` or `{$name}` | `Hello $name` |
| Variable set | `{$name = value}` | `{$gold = 100}` |
| Condition | `{expr}...{/}` | `{$gold > 50}Rich!{/}` |
| Alternative | `{| a | b | c }` | `{| red | blue | green }` |
| Inline Lua | `{{ code }}` | `{{ math.random(1,6) }}` |
| Comment | `// text` | `// This is a comment` |

## Operators

| Category | Operators |
|----------|-----------|
| Arithmetic | `+`, `-`, `*`, `/`, `%` |
| Comparison | `==`, `~=` (or `!=`), `<`, `>`, `<=`, `>=` |
| Logical | `and`, `or`, `not` |
| String | `..` (concatenation) |
| Assignment | `=`, `+=`, `-=`, `*=`, `/=` |
| Collection | `#` (length), `?` (contains) |

## Types

| Type | Example | Notes |
|------|---------|-------|
| Number | `42`, `3.14`, `-5` | IEEE 754 double |
| String | `"hello"`, `"line\n"` | UTF-8 |
| Boolean | `true`, `false` | |
| List | `LIST items = a, b, c` | Enumerated set |
| Array | `[1, 2, 3]` | Ordered, 0-indexed |
| Map | `{key: "value"}` | Key-value pairs |

## Built-in Functions

| Function | Description |
|----------|-------------|
| `whisker.state.get(name)` | Get variable value |
| `whisker.state.set(name, value)` | Set variable value |
| `whisker.passage.go(name)` | Navigate to passage |
| `whisker.passage.visits(name)` | Get visit count |
| `whisker.random.int(min, max)` | Random integer |
| `whisker.output(text)` | Output text |

## Alternatives

| Type | Syntax | Behavior |
|------|--------|----------|
| Sequence | `{| a | b | c }` | In order, sticks on last |
| Cycle | `{&| a | b | c }` | Loops forever |
| Shuffle | `{~| a | b | c }` | Random, no immediate repeat |
| Once | `{!| a | b | c }` | Each once, then empty |

## Escape Sequences

| Sequence | Result |
|----------|--------|
| `\\` | `\` |
| `\$` | `$` |
| `\{` | `{` |
| `\}` | `}` |
| `\[` | `[` |
| `\]` | `]` |
| `\n` | newline |
| `\t` | tab |
| `\"` | `"` |

## Directives

| Directive | Purpose | Example |
|-----------|---------|---------|
| `@tags:` | Passage tags | `@tags: combat, boss` |
| `@on-enter:` | Entry hook | `@on-enter: {$visits += 1}` |
| `@on-exit:` | Exit hook | `@on-exit: {$left = true}` |
| `@priority:` | Choice priority | `@priority: 10` |

## Common Patterns

**Conditional Text:**
```whisker
{$gold >= 100}
  You're rich!
{else}
  You're poor.
{/}
```

**Inline Conditional:**
```whisker
You have {$gold >= 100: plenty of | only a little } gold.
```

**Visit-based Text:**
```whisker
{| First time here. | Back again. | You know this place well. }
```

**Guarded Choice:**
```whisker
* {$hasKey} [Unlock door] -> NextRoom
* [Try to force it] -> ForceDoor
+ [Leave] -> Hallway
```

**Tunnel (Return):**
```whisker
:: Main
+ [Check stats] ->-> Stats
+ [Continue] -> NextScene

:: Stats
Health: $health
->->  // Returns to Main
```

## Error Code Prefixes

| Prefix | Category |
|--------|----------|
| `WLS-SYN-` | Syntax errors |
| `WLS-TYP-` | Type errors |
| `WLS-NAV-` | Navigation errors |
| `WLS-VAR-` | Variable errors |
| `WLS-FLW-` | Control flow errors |
| `WLS-LUA-` | Lua integration errors |

---

**Previous Appendix:** [Save State](APPENDIX-G-SAVE-STATE.md)
**Next Appendix:** [TextMate Grammar](APPENDIX-I-TEXTMATE-GRAMMAR.md)

**Full Specification:** See chapters 1-15 for complete details.
