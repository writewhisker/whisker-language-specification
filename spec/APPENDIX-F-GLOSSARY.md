# Appendix F: Glossary

**Whisker Language Specification 1.0**

---

| Term | Definition |
|------|------------|
| **Action Block** | Code in `{...}` after choice text that executes when choice is selected |
| **Alternative** | Dynamic text that varies based on visit count or randomization |
| **Author** | A person writing Whisker stories |
| **BOM** | Byte Order Mark - optional UTF-8 prefix (EF BB BF) that is tolerated but stripped |
| **Choice** | A player decision point that navigates to a target passage |
| **Choice Guard** | A condition `{expr}` before choice text that controls visibility |
| **Compound Assignment** | Operators like `+=`, `-=` that combine operation with assignment |
| **Condition** | An expression that evaluates to true or false |
| **Conformance** | Whether an implementation correctly follows the WLS specification |
| **Content** | Narrative text within a passage, rendered to the player |
| **Cycle** | An alternative type (`{&| }`) that loops through options forever |
| **Directive** | A metadata declaration starting with `@` (e.g., `@tags:`, `@onEnter:`) |
| **EBNF** | Extended Backus-Naur Form - notation for specifying grammar |
| **Engine** | Software that executes Whisker stories |
| **Escape Sequence** | Backslash-prefixed codes for special characters (e.g., `\n`, `\$`) |
| **Expression** | A combination of values, variables, and operators that produces a value |
| **Fallback** | A passage specified with `@fallback:` for when no choices are available |
| **History** | The stack of previously visited passages |
| **Hook** | A named text region that can be dynamically modified |
| **IFID** | Interactive Fiction Identifier - a UUID uniquely identifying a story |
| **Implementation** | A software system that parses and executes WLS stories |
| **Inline Conditional** | Short-form conditional `{$cond: yes | no}` for inline text |
| **Interpolation** | Inserting variable or expression values into text using `$var` or `${expr}` |
| **Literal** | A fixed value written directly in code (number, string, boolean) |
| **LSP** | Language Server Protocol - standard for IDE language support |
| **Lua** | The scripting language used for embedded code in `{{ }}` blocks |
| **Navigation** | Moving from one passage to another using `->` or `->->` |
| **NFC** | Unicode Normalization Form C (Canonical Composition) |
| **Once-only Choice** | A choice marked with `+` that disappears after selection |
| **Passage** | A discrete unit of narrative content, marked with `:: Name` |
| **Passage Marker** | The `::` prefix that begins a passage definition |
| **Scope** | The visibility and lifetime of a variable (story or temporary) |
| **Sequence** | An alternative type (`{| }`) that progresses and stops at last option |
| **Shadowing** | When a temp variable uses the same name as a story variable (warning) |
| **Shuffle** | An alternative type (`{~| }`) that randomly selects options |
| **Special Target** | Reserved navigation targets: `END`, `BACK`, `RESTART` |
| **State** | The collection of variables tracking story progress |
| **Sticky Choice** | A choice marked with `*` that remains available after selection |
| **Story** | A complete interactive narrative |
| **Story-scoped** | Variables (prefix `$`) that persist across passages |
| **Tag** | A label attached to passages via `@tags:` for categorization |
| **Temporary** | Variables (prefix `_`) that exist only in current passage |
| **Test Oracle** | Expected output for conformance testing |
| **Truthiness** | How non-boolean values are evaluated in boolean context |
| **Tunnel** | A navigation pattern (`->->`) that returns to the calling passage |
| **UTF-8** | The required character encoding for WLS source files |
| **Visit Count** | The number of times a passage has been entered |
| **WLS** | Whisker Language Specification |

---

**Previous Appendix:** [Migration](APPENDIX-E-MIGRATION.md)
**Next Appendix:** [Save State](APPENDIX-G-SAVE-STATE.md)
