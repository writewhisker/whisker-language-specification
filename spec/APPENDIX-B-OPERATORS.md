# Appendix B: Operators

**Whisker Language Specification 1.0**

---

## B.1 Operator Precedence

From highest to lowest precedence:

| Level | Operators | Associativity | Description |
|-------|-----------|---------------|-------------|
| 1 | `not`, `-` (unary) | Right | Logical NOT, negation |
| 2 | `*`, `/`, `%` | Left | Multiplication, division, modulo |
| 3 | `+`, `-` | Left | Addition, subtraction |
| 4 | `..` | Right | String concatenation |
| 5 | `<`, `>`, `<=`, `>=` | Left | Comparison |
| 6 | `==`, `~=` | Left | Equality |
| 7 | `and` | Left | Logical AND |
| 8 | `or` | Left | Logical OR |

## B.2 Arithmetic Operators

| Operator | Operation | Example | Result |
|----------|-----------|---------|--------|
| `+` | Addition | `5 + 3` | `8` |
| `-` | Subtraction | `10 - 4` | `6` |
| `*` | Multiplication | `6 * 7` | `42` |
| `/` | Division | `15 / 4` | `3.75` |
| `%` | Modulo | `17 % 5` | `2` |
| `-` (unary) | Negation | `-5` | `-5` |

## B.3 Comparison Operators

| Operator | Operation | Example | Result |
|----------|-----------|---------|--------|
| `==` | Equal | `5 == 5` | `true` |
| `~=` | Not equal | `5 ~= 3` | `true` |
| `<` | Less than | `3 < 5` | `true` |
| `>` | Greater than | `5 > 3` | `true` |
| `<=` | Less or equal | `5 <= 5` | `true` |
| `>=` | Greater or equal | `5 >= 3` | `true` |

## B.4 Logical Operators

| Operator | Operation | Example | Result |
|----------|-----------|---------|--------|
| `and` | Logical AND | `true and false` | `false` |
| `or` | Logical OR | `true or false` | `true` |
| `not` | Logical NOT | `not true` | `false` |

## B.5 String Operators

| Operator | Operation | Example | Result |
|----------|-----------|---------|--------|
| `..` | Concatenation | `"Hello" .. " World"` | `"Hello World"` |

## B.6 Assignment Operators

| Operator | Operation | Example | Equivalent |
|----------|-----------|---------|------------|
| `=` | Assignment | `$x = 5` | - |
| `+=` | Add-assign | `$x += 3` | `$x = $x + 3` |
| `-=` | Subtract-assign | `$x -= 2` | `$x = $x - 2` |

---

**Previous Appendix:** [Keywords](APPENDIX-A-KEYWORDS.md)
**Next Appendix:** [Escape Sequences](APPENDIX-C-ESCAPE-SEQUENCES.md)
