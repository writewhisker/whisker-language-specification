# Whisker Language Specification - Consolidated for Evaluation

**Source**: https://github.com/writewhisker/whisker-language-spec
**Generated**: $(date)
**Git Commit**: $(git rev-parse --short HEAD)
**Iteration**: 002 (Post Iteration-001 Revisions)

---

# Summary of Iteration 001 Changes

The following revisions were implemented in iteration 001:
- Grammar expanded with gather points, tunnels, modules, collections, hooks
- Version policy added (Section 1.10)
- Named alternatives added (Section 5.4.8)
- Hooks API documented (Section 7.7)
- Semantic tokens documented (Section 14.5.3)
- Incremental parsing guidance (Section 14.8)
- Cross-platform Lua guidance (Section 14.9)
- Save state schema (Appendix B)
- Test corpus expanded with 46 new tests

---

# Formal Grammar

(* ========================================================================== *)
(* Whisker Language Specification 1.0 - Formal Grammar (Revised)              *)
(* ========================================================================== *)
(* Revision: Phase 1 - Iteration 001                                          *)
(* Date: 2026-01-17                                                           *)
(* Changes: REV-001 through REV-004, REV-011                                  *)
(*   - Added gather points (Section 16)                                       *)
(*   - Added tunnels (Section 17)                                             *)
(*   - Added module system (Section 18)                                       *)
(*   - Added collection types (Section 19)                                    *)
(*   - Added hooks (Section 20)                                               *)
(*   - Integrated string concatenation into expressions                       *)
(* ========================================================================== *)
(* This grammar uses Extended Backus-Naur Form (EBNF) notation.               *)
(*                                                                            *)
(* Notation:                                                                  *)
(*   =       definition                                                       *)
(*   ,       concatenation                                                    *)
(*   |       alternation                                                      *)
(*   [ ]     optional (zero or one)                                           *)
(*   { }     repetition (zero or more)                                        *)
(*   ( )     grouping                                                         *)
(*   " "     terminal string                                                  *)
(*   ' '     terminal string (alternative)                                    *)
(*   (* *)   comment                                                          *)
(*   -       exception                                                        *)
(*   ;       end of production                                                *)
(* ========================================================================== *)


(* ========================================================================== *)
(* 1. STORY STRUCTURE                                                         *)
(* ========================================================================== *)

story = { include_directive } ,
        [ story_header ] ,
        [ vars_block ] ,
        { story_element } ;

story_element = passage
              | namespace_block
              | function_def
              | list_declaration ;

story_header = { header_directive } ;

header_directive = "@" , header_key , ":" , header_value , newline ;

header_key = "title" | "author" | "version" | "ifid" | "start"
           | "description" | "created" | "modified" ;

header_value = { any_char - newline } ;

vars_block = "@vars" , newline , { var_declaration } ;

var_declaration = whitespace , identifier , ":" , var_value , newline ;

var_value = literal
          | array_literal
          | map_literal ;


(* ========================================================================== *)
(* 2. PASSAGES                                                                *)
(* ========================================================================== *)

passage = passage_header , [ passage_directives ] , passage_body ;

passage_header = "::" , whitespace , passage_name , newline ;

passage_name = identifier ;

passage_directives = { passage_directive } ;

passage_directive = "@" , directive_key , ":" , directive_value , newline ;

directive_key = "tags" | "color" | "position" | "notes"
              | "onEnter" | "onExit" | "fallback" ;

directive_value = { any_char - newline } ;

passage_body = { passage_element } , [ choice_gather_block ] ;

passage_element = content_line
                | variable_statement
                | conditional_block
                | tunnel_return
                | comment
                | blank_line ;

content_line = { content_element } , newline ;

content_element = plain_text
                | variable_interpolation
                | expression_interpolation
                | inline_conditional
                | text_alternative
                | inline_tunnel_call
                | hook_definition
                | embedded_lua ;


(* ========================================================================== *)
(* 3. VARIABLES                                                               *)
(* ========================================================================== *)

variable_statement = variable_assignment , newline ;

variable_assignment = variable_ref , assignment_operator , expression ;

variable_ref = story_variable | temp_variable ;

story_variable = "$" , identifier ;

temp_variable = "_" , identifier ;

assignment_operator = "=" | "+=" | "-=" ;


(* ========================================================================== *)
(* 4. INTERPOLATION                                                           *)
(* ========================================================================== *)

variable_interpolation = story_variable | temp_variable ;

expression_interpolation = "${" , expression , "}" ;

embedded_lua = "{{" , lua_code , "}}" ;

lua_code = { any_char - "}}" } ;


(* ========================================================================== *)
(* 5. EXPRESSIONS                                                             *)
(* ========================================================================== *)

expression = or_expression ;

or_expression = and_expression , { "or" , and_expression } ;

and_expression = equality_expression , { "and" , equality_expression } ;

equality_expression = contains_expression ,
                      { ( "==" | "~=" ) , contains_expression } ;

contains_expression = comparison_expression ,
                      [ "?" , comparison_expression ] ;

comparison_expression = additive_expression ,
                        [ ( "<" | ">" | "<=" | ">=" ) , additive_expression ] ;

additive_expression = multiplicative_expression ,
                      { ( "+" | "-" | ".." ) , multiplicative_expression } ;

multiplicative_expression = unary_expression ,
                            { ( "*" | "/" | "%" ) , unary_expression } ;

unary_expression = [ "not" | "-" | "#" ] , postfix_expression ;

postfix_expression = primary_expression , { postfix_operator } ;

postfix_operator = index_access | member_access ;

index_access = "[" , expression , "]" ;

member_access = "." , identifier ;

primary_expression = literal
                   | variable_ref
                   | function_call
                   | array_literal
                   | map_literal
                   | "(" , expression , ")" ;

function_call = qualified_name , "(" , [ argument_list ] , ")" ;

qualified_name = identifier , { "." , identifier } ;

argument_list = expression , { "," , expression } ;


(* ========================================================================== *)
(* 6. CONDITIONALS                                                            *)
(* ========================================================================== *)

conditional_block = condition_open ,
                    block_content ,
                    { elif_clause } ,
                    [ else_clause ] ,
                    condition_close ;

condition_open = "{" , whitespace , expression , whitespace , "}" , newline ;

elif_clause = "{elif" , whitespace , expression , whitespace , "}" , newline ,
              block_content ;

else_clause = "{else}" , newline , block_content ;

condition_close = "{/}" , newline ;

block_content = { passage_element } ;

inline_conditional = "{" , expression , ":" , inline_true , "|" , inline_false , "}" ;

inline_true = { inline_content } ;

inline_false = { inline_content } ;

inline_content = plain_text
               | variable_interpolation
               | expression_interpolation ;


(* ========================================================================== *)
(* 7. TEXT ALTERNATIVES                                                       *)
(* ========================================================================== *)

text_alternative = sequence_alternative
                 | cycle_alternative
                 | shuffle_alternative
                 | once_alternative ;

sequence_alternative = "{|" , [ alternative_name ] , alternative_options , "}" ;

cycle_alternative = "{&|" , [ alternative_name ] , alternative_options , "}" ;

shuffle_alternative = "{~|" , [ alternative_name ] , alternative_options , "}" ;

once_alternative = "{!|" , [ alternative_name ] , alternative_options , "}" ;

alternative_name = "name=" , identifier , whitespace ;

alternative_options = alternative_option , { "|" , alternative_option } ;

alternative_option = { alternative_content } ;

alternative_content = plain_text
                    | variable_interpolation
                    | expression_interpolation ;


(* ========================================================================== *)
(* 8. CHOICES                                                                 *)
(* ========================================================================== *)

choice_gather_block = { choice_or_gather } ;

choice_or_gather = choice | gather_block ;

choice = choice_marker ,
         [ choice_condition ] ,
         choice_text ,
         [ choice_action ] ,
         choice_target ,
         newline ;

choice_marker = once_marker | sticky_marker ;

once_marker = "+" , { "+" } ;

sticky_marker = "*" , { "*" } ;

choice_condition = "{" , whitespace , expression , whitespace , "}" ;

choice_text = "[" , { choice_text_content } , "]" ;

choice_text_content = ( any_char - ( "[" | "]" ) )
                    | variable_interpolation
                    | expression_interpolation
                    | text_alternative
                    | escaped_bracket ;

escaped_bracket = "\[" | "\]" ;

choice_action = "{" , action_statements , "}" ;

action_statements = action_statement , { ";" , action_statement } ;

action_statement = variable_assignment
                 | hook_operation
                 | lua_expression ;

lua_expression = lua_code ;

choice_target = simple_target | tunnel_call ;

simple_target = "->" , whitespace , target_name ;

target_name = qualified_passage_name | special_target ;

qualified_passage_name = [ identifier , "::" ] , passage_name ;

special_target = "END" | "BACK" | "RESTART" ;


(* ========================================================================== *)
(* 9. COMMENTS                                                                *)
(* ========================================================================== *)

comment = single_line_comment | multi_line_comment ;

single_line_comment = "//" , { any_char - newline } , newline ;

multi_line_comment = "/*" , { any_char - "*/" } , "*/" ;

inline_comment = "//" , { any_char - newline } ;


(* ========================================================================== *)
(* 10. LITERALS                                                               *)
(* ========================================================================== *)

literal = number_literal | string_literal | boolean_literal ;

number_literal = [ "-" ] , digits , [ "." , digits ] ;

digits = digit , { digit } ;

string_literal = '"' , { string_char } , '"' ;

string_char = ( any_char - ( '"' | "\" | newline ) ) | escape_sequence ;

escape_sequence = "\\" | '\"' | "\n" | "\t" | "\r" | "\$" | "\{" | "\}" | "\|" | "\[" | "\]" ;

boolean_literal = "true" | "false" ;


(* ========================================================================== *)
(* 11. IDENTIFIERS                                                            *)
(* ========================================================================== *)

identifier = identifier_start , { identifier_char } ;

identifier_start = letter | "_" ;

identifier_char = letter | digit | "_" ;

letter = "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j"
       | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t"
       | "u" | "v" | "w" | "x" | "y" | "z"
       | "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J"
       | "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T"
       | "U" | "V" | "W" | "X" | "Y" | "Z" ;

digit = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;


(* ========================================================================== *)
(* 12. WHITESPACE AND FORMATTING                                              *)
(* ========================================================================== *)

whitespace = { ws_char } ;

required_whitespace = ws_char , { ws_char } ;

ws_char = " " | "\t" ;

newline = "\n" | "\r\n" ;

blank_line = { ws_char } , newline ;


(* ========================================================================== *)
(* 13. KEYWORDS                                                               *)
(* ========================================================================== *)

(* Reserved keywords - cannot be used as identifiers *)

keyword = "and" | "or" | "not"
        | "true" | "false"
        | "else" | "elif"
        | "END" | "BACK" | "RESTART"
        | "INCLUDE" | "FUNCTION" | "NAMESPACE"
        | "LIST" | "ARRAY" | "MAP"
        | "IF" | "THEN" | "ELSEIF" | "ELSE" | "RETURN" ;


(* ========================================================================== *)
(* 14. OPERATORS                                                              *)
(* ========================================================================== *)

(* Operators by precedence (highest to lowest):                               *)
(*   1. not, - (unary), # (length)                                            *)
(*   2. *, /, %                                                               *)
(*   3. +, -, ..                                                              *)
(*   4. <, >, <=, >=                                                          *)
(*   5. ? (contains)                                                          *)
(*   6. ==, ~=                                                                *)
(*   7. and                                                                   *)
(*   8. or                                                                    *)

comparison_operator = "<" | ">" | "<=" | ">=" ;

equality_operator = "==" | "~=" ;

additive_operator = "+" | "-" | ".." ;

multiplicative_operator = "*" | "/" | "%" ;

logical_operator = "and" | "or" ;

unary_operator = "not" | "-" | "#" ;

contains_operator = "?" ;


(* ========================================================================== *)
(* 15. SPECIAL CONSTRUCTS                                                     *)
(* ========================================================================== *)

(* Plain text is any character sequence not starting a special construct *)

plain_text = { plain_char } ;

plain_char = any_char - ( "$" | "{" | "}" | "[" | "]" | "\" | "|" | "<" | newline ) ;

(* Any character in the input *)

any_char = ? any Unicode character ? ;


(* ========================================================================== *)
(* 16. GATHER POINTS                                                          *)
(* ========================================================================== *)

(* Gather points reconverge flow from multiple choice branches.               *)
(* Gather depth must match the choice nesting level being gathered.           *)

gather_block = gather_marker , [ gather_label ] , gather_content ;

gather_marker = "-" , { "-" } ;
(* Marker count = depth: "-" = depth 1, "- -" = depth 2, etc. *)

gather_label = "(" , identifier , ")" ;

gather_content = { passage_element } , [ choice_gather_block ] ;


(* ========================================================================== *)
(* 17. TUNNELS                                                                *)
(* ========================================================================== *)

(* Tunnels are passage subroutine calls with automatic return.                *)

tunnel_call = "->" , whitespace , passage_name , whitespace , "->" ;

tunnel_return = "<-" , newline ;

inline_tunnel_call = tunnel_call ;


(* ========================================================================== *)
(* 18. MODULE SYSTEM                                                          *)
(* ========================================================================== *)

(* --- 18.1 Include Directive --- *)

include_directive = "INCLUDE" , required_whitespace , string_literal , newline ;


(* --- 18.2 Function Definition --- *)

function_def = "FUNCTION" , required_whitespace , identifier ,
               "(" , [ param_list ] , ")" , newline ,
               function_body ,
               "END" , newline ;

param_list = identifier , { "," , whitespace , identifier } ;

function_body = { function_statement } ;

function_statement = function_assignment
                   | function_conditional
                   | function_return
                   | function_call_statement
                   | lua_block_in_function
                   | function_comment
                   | function_blank ;

function_assignment = whitespace , identifier , whitespace , "=" ,
                      whitespace , function_expression , newline ;

function_conditional = whitespace , "IF" , required_whitespace , function_expression ,
                       required_whitespace , "THEN" , newline ,
                       function_body ,
                       { function_elseif } ,
                       [ function_else ] ,
                       whitespace , "END" , newline ;

function_elseif = whitespace , "ELSEIF" , required_whitespace , function_expression ,
                  required_whitespace , "THEN" , newline ,
                  function_body ;

function_else = whitespace , "ELSE" , newline , function_body ;

function_return = whitespace , "RETURN" ,
                  [ required_whitespace , function_expression ] , newline ;

function_call_statement = whitespace , function_call , newline ;

lua_block_in_function = whitespace , "{{" , lua_code , "}}" , newline ;

function_comment = whitespace , "--" , { any_char - newline } , newline ;

function_blank = whitespace , newline ;

(* Function expressions *)
function_expression = function_or_expr ;

function_or_expr = function_and_expr , { whitespace , "or" , whitespace , function_and_expr } ;

function_and_expr = function_comparison ,
                    { whitespace , "and" , whitespace , function_comparison } ;

function_comparison = function_additive ,
                      [ whitespace , ( "==" | "~=" | "<" | ">" | "<=" | ">=" ) ,
                        whitespace , function_additive ] ;

function_additive = function_multiplicative ,
                    { whitespace , ( "+" | "-" | ".." ) , whitespace , function_multiplicative } ;

function_multiplicative = function_unary ,
                          { whitespace , ( "*" | "/" | "%" ) , whitespace , function_unary } ;

function_unary = [ ( "not" | "-" | "#" ) , whitespace ] , function_postfix ;

function_postfix = function_primary , { function_postfix_op } ;

function_postfix_op = "[" , function_expression , "]"
                    | "." , identifier ;

function_primary = literal
                 | identifier
                 | function_call
                 | "(" , function_expression , ")" ;


(* --- 18.3 Namespace Definition --- *)

namespace_block = "NAMESPACE" , required_whitespace , identifier , newline ,
                  { namespace_element } ,
                  "END" , required_whitespace , "NAMESPACE" , newline ;

namespace_element = passage
                  | function_def
                  | namespace_block ;


(* ========================================================================== *)
(* 19. COLLECTION TYPES                                                       *)
(* ========================================================================== *)

(* --- 19.1 LIST Type --- *)

list_declaration = "LIST" , required_whitespace , identifier , whitespace , "=" ,
                   whitespace , list_values , newline ;

list_values = list_value , { whitespace , "," , whitespace , list_value } ;

list_value = [ "(" ] , identifier , [ ")" ] ;
(* Parentheses mark initially active values *)


(* --- 19.2 ARRAY Type --- *)

array_literal = "[" , whitespace , [ array_elements ] , whitespace , "]" ;

array_elements = expression , { whitespace , "," , whitespace , expression } ;


(* --- 19.3 MAP Type --- *)

map_literal = "{" , whitespace , [ map_entries ] , whitespace , "}" ;

map_entries = map_entry , { whitespace , "," , whitespace , map_entry } ;

map_entry = map_key , whitespace , ":" , whitespace , expression ;

map_key = identifier | string_literal ;


(* ========================================================================== *)
(* 20. HOOKS                                                                  *)
(* ========================================================================== *)

(* --- 20.1 Hook Definition --- *)

hook_definition = "|" , hook_name , ">" , "[" , hook_content , "]" ;

hook_name = identifier ;

hook_content = { hook_content_element } ;

hook_content_element = hook_plain_char
                     | variable_interpolation
                     | expression_interpolation
                     | escaped_bracket ;

hook_plain_char = any_char - ( "[" | "]" | "$" | "\" ) ;


(* --- 20.2 Hook Operations --- *)

hook_operation = "@" , operation_type , ":" , whitespace , hook_name ,
                 [ whitespace , "{" , operation_content , "}" ] ;

operation_type = "replace" | "append" | "prepend" | "show" | "hide" ;

operation_content = { content_element } ;


(* ========================================================================== *)
(* 21. COMPLETE PRODUCTION SUMMARY                                            *)
(* ========================================================================== *)

(*
  Top-level:
    story -> include* header? vars? (passage | namespace | function | list)*

  Passage:
    passage -> header directives? body
    body -> element* (choice | gather)*

  Content:
    content_element -> text | interpolation | conditional | alternative
                     | tunnel_call | hook

  Expressions:
    expression -> or -> and -> equality -> contains -> comparison
               -> additive -> multiplicative -> unary -> postfix -> primary

  Choices:
    choice -> marker condition? text action? target
    gather -> marker label? content

  Control Flow:
    conditional_block -> { expr } content {elif}* {else}? {/}
    inline_conditional -> {expr: true | false}
    text_alternative -> {[prefix]| opt1 | opt2 | ... }
    tunnel_call -> -> passage ->
    tunnel_return -> <-

  Modules:
    include -> INCLUDE "path"
    function -> FUNCTION name(params) body END
    namespace -> NAMESPACE name elements END NAMESPACE

  Collections:
    list -> LIST name = values
    array -> [ elements ]
    map -> { key: value, ... }

  Hooks:
    definition -> |name>[content]
    operation -> @op: name { content }
*)


(* ========================================================================== *)
(* END OF GRAMMAR                                                             *)
(* ========================================================================== *)

---


# Chapter 1: Introduction

**Whisker Language Specification 1.0**
**Version:** 1.0.0
**Date:** December 29, 2025
**Status:** Draft

---

## 1.1 Purpose

This document specifies the Whisker Language Specification (WLS) version 1.0, a language for authoring interactive fiction and choice-based narratives. WLS defines the syntax, semantics, and runtime behavior that compliant implementations MUST follow.

The specification serves three audiences:

1. **Authors** writing interactive stories
2. **Implementers** building Whisker-compatible engines
3. **Tool developers** creating editors, validators, and converters

## 1.2 Scope

WLS specifies:

- **Syntax**: The textual representation of Whisker stories
- **Semantics**: The meaning and behavior of language constructs
- **API**: The Lua scripting interface for story logic
- **Formats**: Both text (`.ws`) and JSON representations
- **Compatibility**: Requirements for bi-directional platform compatibility

WLS does NOT specify:

- Presentation or rendering (implementation-specific)
- User interface design
- Network protocols
- Storage mechanisms beyond format definitions

## 1.3 Design Philosophy

WLS follows these core principles:

### 1.3.1 Prose First

Story content should read like prose, not code. Markup is minimal and unobtrusive.

```whisker
:: Garden
The garden is peaceful in the morning light.
You notice a small path leading into the woods.

+ [Follow the path] -> Woods
+ [Stay in the garden] -> GardenLater
```

### 1.3.2 Progressive Complexity

Simple stories require simple syntax. Advanced features are opt-in.

**Simple story:**
```whisker
:: Start
Hello, world!
+ [Continue] -> End

:: End
Goodbye!
```

**Complex story:**
```whisker
:: Start
$playerName = "Adventurer"
$gold = 100

Welcome, $playerName!
{ $gold >= 100 }
  You're quite wealthy.
{/}

+ { $gold >= 50 } [Buy sword] { $gold -= 50 } -> Shop
* [Look around] -> LookAround
```

### 1.3.3 Consistency

Language constructs follow predictable patterns:
- Lua-style operators throughout (`and`, `or`, `not`, `~=`)
- Unified API namespace (`whisker.*`)
- Consistent scoping rules

### 1.3.4 Portability

Stories written for WLS MUST produce identical behavior across all compliant implementations.

## 1.4 Notation Conventions

This specification uses RFC 2119 keywords:

| Keyword | Meaning |
|---------|---------|
| **MUST** | Absolute requirement |
| **MUST NOT** | Absolute prohibition |
| **SHOULD** | Recommended but not required |
| **SHOULD NOT** | Discouraged but not prohibited |
| **MAY** | Optional |

### 1.4.1 Syntax Notation

Grammar is specified in Extended Backus-Naur Form (EBNF):

```ebnf
(* Terminal symbols in quotes *)
passage_marker = "::" ;

(* Non-terminals in lowercase *)
passage = passage_header , content ;

(* Optional: [ ] *)
choice = "+" , [ condition ] , choice_text , "->" , target ;

(* Repetition: { } *)
story = { passage } ;

(* Alternation: | *)
boolean = "true" | "false" ;
```

### 1.4.2 Code Examples

Code examples use the following format:

```whisker
// This is a code example
$variable = 42
```

Expected output or behavior is shown as:

> **Result:** The variable `$variable` is set to `42`.

### 1.4.3 Error Examples

Invalid syntax or error conditions are shown as:

```whisker
// INVALID: Missing target
+ [Choice text]
```

> **Error:** Choice missing navigation target.

## 1.5 Document Structure

The WLS specification is organized as follows:

| Chapter | Title | Content |
|---------|-------|---------|
| 1 | Introduction | This chapter |
| 2 | Core Concepts | Stories, passages, choices, state |
| 3 | Syntax | Complete syntax reference |
| 4 | Variables | Variable system and interpolation |
| 5 | Control Flow | Conditionals and alternatives |
| 6 | Choices | Choice system and navigation |
| 7 | Lua API | Complete API reference |
| 8 | File Formats | Text and JSON formats |
| 9 | Examples | Comprehensive code examples |
| 10 | Best Practices | Usage guidelines |
| A | Grammar | Formal EBNF grammar |
| B | Appendices | Reference tables |

## 1.6 Terminology

| Term | Definition |
|------|------------|
| **Story** | A complete interactive narrative |
| **Passage** | A discrete unit of narrative content |
| **Choice** | A player decision point |
| **Variable** | A named storage location for state |
| **Condition** | An expression that evaluates to true or false |
| **Alternative** | Dynamic text that varies on each encounter |
| **Engine** | Software that executes Whisker stories |
| **Author** | A person writing Whisker stories |

## 1.7 Conformance

### 1.7.1 Implementation Conformance

An implementation is **WLS conformant** if it:

1. Correctly parses all valid WLS syntax
2. Correctly rejects all invalid WLS syntax with appropriate errors
3. Implements all MUST requirements in this specification
4. Implements the complete `whisker.*` API
5. Produces identical output for the WLS test corpus

### 1.7.2 Story Conformance

A story is **WLS conformant** if it:

1. Uses only syntax defined in this specification
2. Uses only API functions defined in this specification
3. Produces consistent behavior across all conformant implementations

### 1.7.3 Output Comparison Rules

"Identical output" for conformance testing means:

| Aspect | Comparison Rule |
|--------|-----------------|
| Rendered text | Byte-for-byte UTF-8 match |
| Whitespace | Significant (preserved) |
| Floating-point | Exact match or ≤1e-10 epsilon |
| Error codes | Exact match |
| Error messages | NOT compared (implementation-specific) |
| Debug output | NOT compared |
| Timing | NOT compared |

#### Test Oracle

Conformance tests specify expected output as UTF-8 strings. Implementations pass if output matches exactly, with floating-point epsilon tolerance.

## 1.8 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.3 | 2026-01-17 | Minor issues: visual diagrams, cheat sheet, escape sequences, identifier limits, array index edge cases, alternative edge cases, comprehensive edge cases, code folding, hover content, stat screen pattern, enhanced turn tracking |
| 1.0.2 | 2026-01-17 | P3 revisions: newline sensitivity, != operator, migration tools, visualization, concurrency, incremental parsing, random seeding, relationship helpers, dialog system, implementation guidance |
| 1.0.1 | 2026-01-17 | P1/P2 revisions: error recovery, numeric limits, Unicode, execution order, common patterns, migration guides, glossary |
| 1.0.0 | 2025-12-29 | Initial release |

### 1.8.1 Compatibility Notes

WLS introduces breaking changes from previous Whisker implementations:

| Change | Migration |
|--------|-----------|
| `&&` → `and` | Replace all occurrences |
| `||` → `or` | Replace all occurrences |
| `!` → `not` | Replace all occurrences |
| `!=` → `~=` | Replace all occurrences |
| `{{var}}` → `$var` | Replace interpolation syntax |
| `game_state.*` → `whisker.state.*` | Update API calls |

A migration tool is provided to automate these changes.

## 1.9 Reference Implementations

Two reference implementations exist for WLS:

| Implementation | Language | Platform |
|----------------|----------|----------|
| whisker-core | Lua | CLI, Desktop, Embedded |
| whisker-editor-web | TypeScript | Web browsers |

Both implementations MUST produce identical behavior for all WLS stories.

## 1.10 Version Policy

The Whisker Language Specification follows semantic versioning (semver).

### 1.10.1 Version Number Format

`MAJOR.MINOR.PATCH` (e.g., 1.0.0, 1.1.0, 2.0.0)

### 1.10.2 Version Categories

| Type | When Incremented | Compatibility |
|------|------------------|---------------|
| **MAJOR** (1.x → 2.x) | Breaking changes to syntax or semantics | Stories MAY require migration |
| **MINOR** (1.0 → 1.1) | New features, additive changes | Fully backwards compatible |
| **PATCH** (1.0.0 → 1.0.1) | Clarifications, typo fixes, test additions | No behavioral changes |

### 1.10.3 Compatibility Guarantees

1. **Forward Compatibility**: Stories written for WLS 1.x will work with all WLS 1.x implementations
2. **Implementation Versioning**: Implementations SHOULD report the WLS version they target
3. **Feature Detection**: Stories MAY use `whisker.version()` to check runtime WLS version

### 1.10.4 Deprecation Policy

Features marked `@deprecated` in one MINOR version MAY be removed in the next MAJOR version. Deprecation warnings MUST be issued for at least one MINOR release before removal.

### 1.10.5 Version API

```lua
whisker.version()
-- Returns: { major = 1, minor = 0, patch = 0, string = "1.0.0" }
```

## 1.11 Acknowledgments

WLS draws inspiration from:

- **Twine** (Harlowe, SugarCube, Chapbook story formats)
- **Ink** (inkle's narrative scripting language)
- **Lua** (scripting language)

---

**Next Chapter:** [Quick Start](01a-QUICK_START.md)

---


# Chapter 1a: Quick Start

**Whisker Language Specification 1.0**

---

Get started with Whisker in 5 minutes. This tutorial creates a simple interactive story.

## Your First Story

Create a file called `hello.ws`:

```whisker
--- story
title: My First Story
author: Your Name
---

=== Start ===
Welcome to your first Whisker story!

What would you like to do?

+ [Look around] -> LookAround
+ [Say hello] -> SayHello

=== LookAround ===
You are in a cozy room with a fireplace.

+ [Return] -> Start

=== SayHello ===
"Hello, world!" you call out.

A friendly voice responds: "Welcome to Whisker!"

+ [Continue] -> End

=== End ===
Thanks for playing!

-> END
```

## Key Concepts

| Element | Syntax | Purpose |
|---------|--------|---------|
| Story header | `--- story ... ---` | Metadata and settings |
| Passage | `=== Name ===` | A scene or location |
| Choice | `+ [text]` | Player option (once-only) |
| Navigation | `-> PassageName` | Go to another passage |
| End | `-> END` | End the story |

## Adding Variables

Track state with variables:

```whisker
--- story
$gold = 100
$hasKey = false
---

=== Shop ===
You have $gold gold.

+ [Buy key (50g)] {$gold >= 50} {$gold -= 50} {$hasKey = true} -> Shop
+ [Leave] -> Street

=== LockedDoor ===
{$hasKey}
  You unlock the door with your key.
  + [Enter] -> SecretRoom
{/}
{not $hasKey}
  The door is locked. You need a key.
  + [Leave] -> Street
{/}
```

## Adding Variety

Use alternatives for dynamic text:

```whisker
=== Forest ===
The forest is {| quiet | peaceful | serene | mysterious }.

You see a {~ bird | squirrel | deer | rabbit } nearby.

This is visit #{visited("Forest") + 1} to the forest.

+ [Explore more] -> Forest
+ [Return home] -> Home
```

## Next Steps

- Read **Chapter 2: Core Concepts** for detailed explanations
- See **Chapter 10: Common Patterns** for ready-to-use recipes
- Explore the **Lua API** (Chapter 7) for advanced scripting

---

**Previous Chapter:** [Introduction](01-INTRODUCTION.md)
**Next Chapter:** [Core Concepts](02-CORE_CONCEPTS.md)

---


# Chapter 2: Core Concepts

**Whisker Language Specification 1.0**

---

## 2.1 Overview

This chapter defines the fundamental concepts that form the foundation of WLS. Understanding these concepts is essential for both authors and implementers.

The core concepts are:

1. **Stories** - Complete interactive narratives
2. **Passages** - Discrete units of content
3. **Choices** - Player decision points
4. **State** - Game variables and tracking
5. **Execution Model** - How stories run
6. **Lifecycle Events** - Hooks for custom behavior

### 2.1.1 Conceptual Diagrams

#### Story Structure

```
┌─────────────────────────────────────────────────────────┐
│                         STORY                           │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐                                        │
│  │  Metadata   │  title, author, version                │
│  └─────────────┘                                        │
│  ┌─────────────┐                                        │
│  │   State     │  $variables, history, visit counts     │
│  └─────────────┘                                        │
│  ┌─────────────────────────────────────────────────┐    │
│  │                    Passages                      │    │
│  │  ┌─────────┐    ┌─────────┐    ┌─────────┐      │    │
│  │  │  Start  │───▶│ Middle  │───▶│   End   │      │    │
│  │  └─────────┘    └─────────┘    └─────────┘      │    │
│  │       │              │                           │    │
│  │       ▼              ▼                           │    │
│  │  ┌─────────┐    ┌─────────┐                      │    │
│  │  │ Branch  │    │ Branch  │                      │    │
│  │  └─────────┘    └─────────┘                      │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

#### Passage Lifecycle

```
┌──────────────────────────────────────────────────────┐
│                  PASSAGE LIFECYCLE                    │
├──────────────────────────────────────────────────────┤
│                                                       │
│   ┌─────────┐     ┌─────────┐     ┌─────────┐        │
│   │ onEnter │ ──▶ │ Render  │ ──▶ │ Choices │        │
│   └─────────┘     └─────────┘     └─────────┘        │
│        │               │               │              │
│        ▼               ▼               ▼              │
│   increment       process         evaluate            │
│   visit count     content         conditions          │
│   init temps      variables       build list          │
│                   alternatives                        │
│                                                       │
│                        │                              │
│                        ▼                              │
│   ┌─────────┐     ┌─────────┐     ┌─────────┐        │
│   │  Await  │ ◀── │ Present │ ◀── │ Display │        │
│   └─────────┘     └─────────┘     └─────────┘        │
│        │                                              │
│        ▼                                              │
│   ┌─────────┐     ┌─────────┐     ┌─────────┐        │
│   │ Action  │ ──▶ │ onExit  │ ──▶ │Navigate │        │
│   └─────────┘     └─────────┘     └─────────┘        │
│                                                       │
└──────────────────────────────────────────────────────┘
```

#### Choice Flow

```
┌─────────────────────────────────────────────────────┐
│                    CHOICE FLOW                       │
├─────────────────────────────────────────────────────┤
│                                                      │
│    Passage Content                                   │
│         │                                            │
│         ▼                                            │
│    ┌─────────────────────────────────────┐          │
│    │           Choice Evaluation          │          │
│    │  ┌─────┐  ┌─────┐  ┌─────┐          │          │
│    │  │ + A │  │ + B │  │ * C │          │          │
│    │  │cond?│  │cond?│  │cond?│          │          │
│    │  └──┬──┘  └──┬──┘  └──┬──┘          │          │
│    │     │        │        │              │          │
│    │  visible? visible? visible?          │          │
│    └─────┼────────┼────────┼─────────────┘          │
│          │        │        │                         │
│          ▼        ▼        ▼                         │
│    ┌─────────────────────────────────────┐          │
│    │         Presented Choices            │          │
│    │    [A]      [B]      [C]             │          │
│    └─────────────────────────────────────┘          │
│                    │                                 │
│            player selects                            │
│                    ▼                                 │
│    ┌─────────────────────────────────────┐          │
│    │  Execute Action → Navigate Target    │          │
│    └─────────────────────────────────────┘          │
│                                                      │
└─────────────────────────────────────────────────────┘
```

#### Variable Scopes

```
┌─────────────────────────────────────────────────────┐
│                  VARIABLE SCOPES                     │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Story Scope ($)                                     │
│  ┌───────────────────────────────────────────────┐  │
│  │  $gold = 100     $health = 75    $name = "Jo" │  │
│  │  ───────────────────────────────────────────  │  │
│  │  Persists across passages, saved to disk      │  │
│  └───────────────────────────────────────────────┘  │
│                                                      │
│  Temp Scope (_)                                      │
│  ┌───────────────────────────────────────────────┐  │
│  │  Passage A          Passage B                  │  │
│  │  ┌─────────────┐    ┌─────────────┐           │  │
│  │  │ _count = 1  │    │ _count = ?  │  (reset)  │  │
│  │  │ _temp = "x" │    │ _temp = ?   │           │  │
│  │  └─────────────┘    └─────────────┘           │  │
│  │  Cleared on passage exit, not saved           │  │
│  └───────────────────────────────────────────────┘  │
│                                                      │
└─────────────────────────────────────────────────────┘
```

## 2.2 Stories

### 2.2.1 Definition

A **story** is the top-level container for an interactive narrative. A story consists of:

- **Metadata** - Title, author, version, and other descriptive information
- **Passages** - The content units that make up the narrative
- **Variables** - Initial state definitions
- **Assets** - Optional media resources (images, audio)
- **Settings** - Configuration options

### 2.2.2 Story Structure

```
Story
├── Metadata
│   ├── title
│   ├── author
│   ├── version
│   ├── ifid (Interactive Fiction ID)
│   └── description
├── Variables (initial definitions)
├── Passages[]
│   ├── Passage 1
│   ├── Passage 2
│   └── ...
├── Assets[] (optional)
└── Settings (optional)
```

### 2.2.3 Story Metadata

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `title` | string | SHOULD | Story title |
| `author` | string | SHOULD | Author name |
| `version` | string | MAY | Story version (semver) |
| `ifid` | string | SHOULD | Unique story identifier (UUID) |
| `description` | string | MAY | Brief story description |
| `created` | datetime | MAY | Creation timestamp |
| `modified` | datetime | MAY | Last modification timestamp |

**Example:**

```whisker
@title: The Enchanted Forest
@author: Jane Author
@version: 1.0.0
@ifid: 12345678-1234-1234-1234-123456789ABC

:: Start
Your adventure begins...
```

### 2.2.4 Start Passage

Every story MUST have a designated start passage. The start passage is determined by:

1. Explicit `@start:` directive in story header
2. First passage in the story (if no directive)
3. A passage named `Start` (case-sensitive)

```whisker
@start: Prologue

:: Prologue
The story begins here, not at "Start".

:: Start
This passage is not the start in this story.
```

## 2.3 Passages

### 2.3.1 Definition

A **passage** is a discrete unit of narrative content. Passages are the building blocks of stories, analogous to pages in a book or scenes in a play.

A passage contains:

- **Identifier** - Unique name within the story
- **Content** - Text, conditionals, and inline elements
- **Choices** - Optional navigation options
- **Metadata** - Tags, color, notes (optional)
- **Scripts** - Lifecycle scripts (optional)

### 2.3.2 Passage Declaration

Passages are declared with the `::` marker followed by a name:

```whisker
:: PassageName
Content goes here.
```

**Naming Rules:**

- MUST start with a letter (a-z, A-Z) or underscore (_)
- MAY contain letters, digits (0-9), and underscores
- MUST NOT contain spaces or special characters
- Case-sensitive (`Start` ≠ `start` ≠ `START`)
- SHOULD be descriptive and readable

**Valid names:**
```
Start
_hidden_passage
Chapter1
my_passage_2
```

**Invalid names:**
```
1stPassage      // Cannot start with digit
My Passage      // Cannot contain spaces
passage-name    // Cannot contain hyphens
```

### 2.3.3 Passage Content

Passage content is everything between the passage declaration and the next passage (or end of file).

Content can include:

| Element | Description |
|---------|-------------|
| Plain text | Narrative prose |
| Variable interpolation | `$variable` or `${expression}` |
| Conditionals | `{ condition }...{/}` blocks |
| Alternatives | `{| a | b | c }` dynamic text |
| Choices | `+ [text] -> target` navigation |
| Comments | `//` or `/* */` |
| Embedded Lua | `{{ code }}` |

**Example:**

```whisker
:: Garden
The garden is beautiful in $timeOfDay light.

{ $hasVisitedBefore }
  You remember this place fondly.
{else}
  Everything here feels new and exciting.
{/}

The fountain makes {~| gentle | soft | peaceful } sounds.

+ [Smell the roses] -> Roses
+ [Sit on the bench] -> Bench
* [Look around] -> GardenLook
```

### 2.3.4 Passage Metadata

Passages MAY have metadata specified with directives:

| Directive | Type | Description |
|-----------|------|-------------|
| `@tags:` | string[] | Comma-separated tags |
| `@color:` | string | Editor display color (hex) |
| `@position:` | number[] | Editor position [x, y] |
| `@notes:` | string | Author notes (not displayed) |

**Example:**

```whisker
:: ImportantScene
@tags: chapter1, dramatic, boss-fight
@color: #ff0000
@notes: This is the climax of chapter 1

The dragon roars!
```

### 2.3.5 Passage Lifecycle Scripts

Passages MAY define scripts that execute at specific points:

| Script | Timing |
|--------|--------|
| `@onEnter:` | Executes when entering the passage |
| `@onExit:` | Executes when leaving the passage |

**Example:**

```whisker
:: TreasureRoom
@onEnter: whisker.state.set("foundTreasure", true)
@onExit: whisker.state.set("gold", whisker.state.get("gold") + 100)

You found the treasure room!
```

## 2.4 Choices

### 2.4.1 Definition

A **choice** represents a decision point where the player selects from available options. Each choice navigates to a target passage.

### 2.4.2 Choice Components

A choice consists of:

| Component | Required | Description |
|-----------|----------|-------------|
| Marker | Yes | `+` (once-only) or `*` (sticky) |
| Condition | No | `{ expression }` visibility condition |
| Text | Yes | `[displayed text]` shown to player |
| Action | No | `{ code }` executed on selection |
| Target | Yes | `-> PassageName` navigation target |

**Syntax:**

```
marker [condition] [text] [action] -> target
```

**Examples:**

```whisker
// Simple choice
+ [Go north] -> NorthRoom

// Sticky choice (repeatable)
* [Look around] -> LookAround

// Conditional choice
+ { $hasKey } [Unlock the door] -> InsideRoom

// Choice with action
+ [Buy sword] { $gold -= 50 } -> Inventory

// Full example
+ { $gold >= 100 } [Purchase armor ($100)] { $gold -= 100 } -> ArmorEquipped
```

### 2.4.3 Once-Only vs Sticky Choices

| Marker | Type | Behavior |
|--------|------|----------|
| `+` | Once-only | Disappears after selection |
| `*` | Sticky | Remains available |

**Example:**

```whisker
:: Shop
Welcome to the shop!

+ [Buy the special sword] -> BuySword    // Gone after purchase
* [Ask about prices] -> AskPrices        // Can ask repeatedly
* [Browse inventory] -> BrowseInventory  // Can browse repeatedly
+ [Leave shop] -> Exit                   // One-time exit
```

### 2.4.4 Choice Visibility

Choices are visible when:

1. No condition specified (always visible)
2. Condition evaluates to `true`
3. For once-only choices: not previously selected in this playthrough

Choices are hidden when:

1. Condition evaluates to `false`
2. For once-only choices: previously selected

### 2.4.5 Fallback Behavior

If all choices become unavailable (hidden or exhausted), the engine SHOULD:

1. Display a message indicating no choices remain
2. Or automatically proceed to a designated fallback passage

Implementations MAY provide configuration for this behavior.

## 2.5 State

### 2.5.1 Definition

**State** refers to the collection of variables that track story progress and player decisions. State persists across passage transitions and can be saved/restored.

### 2.5.2 Variable Types

WLS supports three primitive types:

| Type | Description | Examples |
|------|-------------|----------|
| `number` | Integer or floating-point | `42`, `3.14`, `-10` |
| `string` | Text enclosed in quotes | `"Hello"`, `"Player 1"` |
| `boolean` | True or false | `true`, `false` |

### 2.5.3 Variable Scopes

| Scope | Prefix | Lifetime |
|-------|--------|----------|
| Story | `$` | Entire playthrough |
| Temporary | `_` | Current passage only |

**Example:**

```whisker
:: Calculate
$totalScore = 100        // Persists across passages
_tempBonus = 25          // Cleared when leaving this passage

Final score: ${$totalScore + _tempBonus}
```

### 2.5.4 Initial State

Variables MAY be initialized in the story header:

```whisker
@vars
  gold: 100
  playerName: "Adventurer"
  hasKey: false
```

Or within passages:

```whisker
:: Start
$gold = 100
$playerName = "Adventurer"
$hasKey = false
```

### 2.5.5 State Access

State is accessed via:

1. **Interpolation** in content: `$variable` or `${expression}`
2. **Conditions**: `{ $variable > 10 }`
3. **Lua API**: `whisker.state.get("variable")`

### 2.5.6 Built-in State

The engine automatically tracks:

| Property | Access | Description |
|----------|--------|-------------|
| Visit count | `whisker.visited(passageId)` | Times passage visited |
| Current passage | `whisker.passage.current()` | Current passage object |
| History | `whisker.history.list()` | Navigation history |

## 2.6 Execution Model

### 2.6.1 Story Lifecycle

```
┌─────────────┐
│ Story Load  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Initialize  │ ← Set initial variables
│   State     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Enter Start │ ← Navigate to start passage
│  Passage    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────┐
│         Main Loop                    │
│  ┌─────────────┐                    │
│  │ Display     │                    │
│  │ Passage     │                    │
│  └──────┬──────┘                    │
│         │                           │
│         ▼                           │
│  ┌─────────────┐                    │
│  │ Evaluate    │                    │
│  │ Choices     │                    │
│  └──────┬──────┘                    │
│         │                           │
│         ▼                           │
│  ┌─────────────┐     ┌───────────┐ │
│  │ Wait for    │────►│ Navigate  │ │
│  │ Selection   │     │ to Target │ │
│  └─────────────┘     └─────┬─────┘ │
│         ▲                  │       │
│         └──────────────────┘       │
└─────────────────────────────────────┘
       │
       ▼
┌─────────────┐
│  Story End  │ ← No choices or END reached
└─────────────┘
```

### 2.6.2 Passage Execution

When a passage is entered:

1. **onEnter script** executes (if defined)
2. **Variable assignments** are processed (top to bottom)
3. **Content is rendered**:
   - Variable interpolation performed
   - Conditionals evaluated
   - Alternatives resolved
4. **Choices are evaluated**:
   - Conditions checked
   - Available choices presented
5. **Player selects** a choice
6. **Choice action** executes (if defined)
7. **onExit script** executes (if defined)
8. **Navigation** to target passage

### 2.6.3 Expression Evaluation

Expressions are evaluated left-to-right with operator precedence:

| Precedence | Operators | Associativity |
|------------|-----------|---------------|
| 1 (highest) | `not`, unary `-` | Right |
| 2 | `*`, `/`, `%` | Left |
| 3 | `+`, `-` | Left |
| 4 | `<`, `>`, `<=`, `>=` | Left |
| 5 | `==`, `~=` | Left |
| 6 | `and` | Left |
| 7 (lowest) | `or` | Left |

### 2.6.4 Content Rendering Order

Within a passage, content is rendered in document order:

1. Text lines
2. Conditionals (evaluated, content included or excluded)
3. Alternatives (one option selected)
4. Variable interpolation (values substituted)

**Example execution:**

```whisker
:: Example
$count = 5
The count is $count.           // "The count is 5."
$count += 1
Now it's $count.               // "Now it's 6."
```

## 2.7 Lifecycle Events

### 2.7.1 Story Events

| Event | Timing | Use Case |
|-------|--------|----------|
| Story Start | Before first passage | Initialize global state |
| Story End | After final passage | Cleanup, statistics |

### 2.7.2 Passage Events

| Event | Timing | Use Case |
|-------|--------|----------|
| `onEnter` | Entering passage | Setup, state changes |
| `onExit` | Leaving passage | Cleanup, state saves |

### 2.7.3 Choice Events

| Event | Timing | Use Case |
|-------|--------|----------|
| Choice Action | After selection, before navigation | State modifications |

### 2.7.4 Event Execution Order

When navigating from Passage A to Passage B via a choice:

```
1. Player selects choice in Passage A
2. Choice action executes (if any)
3. Passage A onExit executes (if any)
4. Navigation occurs
5. Passage B onEnter executes (if any)
6. Passage B content renders
```

### 2.7.5 Passage Execution Order

When navigating to a passage, execution proceeds:

1. **Pre-enter**: Increment visit count for passage
2. **History**: Add passage to navigation history
3. **Initialize**: Create empty temp variable scope
4. **onEnter**: Fire `onEnter` hook (if defined)
5. **Render**: Process content top-to-bottom
   - Execute assignments immediately
   - Evaluate conditionals
   - Resolve alternatives
   - Expand hooks
6. **Choices**: Evaluate choice conditions, build list
7. **Present**: Display content and available choices
8. **Await**: Wait for player selection
9. **Action**: Execute selected choice's action block
10. **onExit**: Fire `onExit` hook (if defined)
11. **Cleanup**: Clear temp variables
12. **Navigate**: Go to choice target (return to step 1)

## 2.8 Navigation

### 2.8.1 Navigation Types

| Type | Syntax | Description |
|------|--------|-------------|
| Choice | `-> PassageName` | Player-initiated |
| Direct | `whisker.passage.go(id)` | Script-initiated |
| Back | `whisker.history.back()` | Return to previous |

### 2.8.2 History Tracking

The engine MUST maintain a navigation history:

- Each passage visit is recorded
- History enables back navigation
- History is cleared on story restart

### 2.8.3 Special Navigation Targets

| Target | Behavior |
|--------|----------|
| `-> END` | Ends the story |
| `-> BACK` | Returns to previous passage |
| `-> RESTART` | Restarts the story |

## 2.9 Error Handling

### 2.9.1 Parse Errors

Parse errors MUST:

- Include line and column number
- Describe the error clearly
- Suggest corrections when possible

### 2.9.2 Runtime Errors

Runtime errors SHOULD:

- Not crash the engine
- Display a meaningful message
- Allow recovery when possible

### 2.9.3 Common Errors

| Error | Cause | Resolution |
|-------|-------|------------|
| Undefined passage | Navigation to non-existent passage | Create the passage |
| Undefined variable | Accessing unset variable | Initialize the variable |
| Type error | Invalid operation on type | Check operand types |
| Division by zero | Dividing by zero | Add zero check |

### 2.9.4 Recovery Semantics

For recoverable errors, implementations MUST:

1. **Log the error** with appropriate WLS error code
2. **Use default value** per the error recovery table
3. **Continue execution** from the next statement
4. **Preserve state** - changes before error are kept
5. **Complete passage rendering** normally
6. **Present choices** if rendering completes

#### Recovery Table

| Error Type | Default Value | Continues? |
|------------|---------------|------------|
| Undefined variable | `""` | Yes |
| Type mismatch | Skip operation | Yes |
| Division by zero | `0` | Yes |
| Invalid array index | `nil` | Yes |
| Invalid map key | `nil` | Yes |

#### Non-Recoverable Errors

These errors MUST halt execution:
- WLS-SYN-* (syntax errors)
- WLS-STR-001 (missing start passage)
- WLS-LNK-001 (navigation to non-existent passage)
- WLS-FLW-004 (infinite loop detected)
- WLS-MOD-005 (stack overflow)

---

**Previous Chapter:** [Introduction](01-INTRODUCTION.md)
**Next Chapter:** [Syntax](03-SYNTAX.md)

---


# Chapter 3: Syntax

**Whisker Language Specification 1.0**

---

## 3.1 Overview

This chapter provides a complete reference for WLS syntax. It covers lexical structure, tokens, operators, expressions, statements, and all syntactic constructs.

## 3.2 Lexical Structure

### 3.2.1 Character Set

WLS source files MUST be encoded in UTF-8. All Unicode characters are permitted in:

- String literals
- Comments
- Passage content

Identifiers are restricted to ASCII characters.

#### 3.2.1.1 Unicode Handling

**Encoding:**

- **Required**: UTF-8 without BOM (BOM tolerated, stripped)
- **Rejected**: UTF-16, UTF-32 (error WLS-ENC-001)

**Normalization:**

- Input SHOULD be in NFC (Canonical Composition)
- Implementations MAY normalize to NFC on read
- String comparison uses byte-level equality

**String Length:**

- `#$string` returns **code point count**, not byte count
- Grapheme clusters may span multiple code points

**Identifiers:**

- ASCII only: `[A-Za-z_][A-Za-z0-9_]*`
- Unicode letters NOT permitted in identifiers
- Unicode permitted in string content and comments

**Examples:**

```whisker
$emoji = "🎮🎲"
${#$emoji}         // 2 (code points)
$name = "Café"     // Valid string
// $Café = 1       // INVALID: non-ASCII identifier
```

### 3.2.2 Line Structure

Lines are terminated by:

- Line Feed (LF, `\n`) - Unix
- Carriage Return + Line Feed (CRLF, `\r\n`) - Windows
- Carriage Return (CR, `\r`) - Legacy Mac

Implementations MUST normalize all line endings.

#### 3.2.2.1 Newline Sensitivity

WLS is **newline-sensitive** in specific contexts. This table clarifies where newlines are significant:

| Context | Newline Behavior | Example |
|---------|------------------|---------|
| Passage declaration | REQUIRED after `===` | `=== Name ===\n` |
| Block conditional open | REQUIRED after `}` | `{$x}\n content` |
| Block conditional close | `{/}` on own line | `{/}\n` |
| Choice declaration | REQUIRED after `]` or `->` | `+ [text] -> Target\n` |
| Prose text | Preserved as-is | Line breaks in output |
| Inline conditional | NOT significant | `{$x: a \| b}` |
| Alternatives | NOT significant | `{\| a \| b }` |
| Action blocks | NOT significant | `{$x = 1}` |
| Comments | Terminated by newline | `// comment\n` |

**Consecutive Newlines:**

- Single newline: continues current paragraph
- Double newline (blank line): paragraph break
- Triple+ newlines: treated as double newline

**Newline in Strings:**

```whisker
$text = "Line 1\nLine 2"   // Explicit newline escape
$multi = "Line 1
Line 2"                     // Literal newline (preserved)
```

### 3.2.3 Whitespace

| Character | Name | Code Point |
|-----------|------|------------|
| Space | SPACE | U+0020 |
| Tab | HORIZONTAL TAB | U+0009 |
| LF | LINE FEED | U+000A |
| CR | CARRIAGE RETURN | U+000D |

**Whitespace Significance:**

- **Significant**: Between tokens where required for separation
- **Insignificant**: Within expressions, around operators
- **Preserved**: In passage content and strings

```whisker
// Whitespace is insignificant in expressions
{ $gold>=50 }        // Valid
{ $gold >= 50 }      // Also valid (preferred)
{$gold   >=   50}    // Also valid

// Whitespace is preserved in content
The quick brown fox.    // Spaces preserved
```

### 3.2.4 Indentation

Indentation is **not semantically significant** in WLS. It is used for readability only.

```whisker
// Both are equivalent
{ $hasKey }
The door opens.
{/}

{ $hasKey }
  The door opens.
{/}
```

## 3.3 Comments

### 3.3.1 Single-Line Comments

Single-line comments begin with `//` and extend to the end of the line.

```whisker
// This is a comment
$gold = 100  // Inline comment
```

### 3.3.2 Multi-Line Comments

Multi-line comments begin with `/*` and end with `*/`.

```whisker
/* This is a
   multi-line comment */

$gold = /* inline */ 100
```

### 3.3.3 Comment Rules

- Comments MUST NOT nest
- Comments are stripped during parsing
- Comments MAY appear anywhere except within string literals

```whisker
// INVALID: Nested comments
/* outer /* inner */ still outer */

// VALID: Comment markers in strings
$text = "Use // for comments"
```

## 3.4 Tokens

### 3.4.1 Token Categories

| Category | Examples |
|----------|----------|
| Keywords | `and`, `or`, `not`, `true`, `false` |
| Identifiers | `playerName`, `_temp`, `gold` |
| Literals | `42`, `"hello"`, `true` |
| Operators | `+`, `-`, `==`, `>=` |
| Delimiters | `::`, `+`, `*`, `{`, `}`, `[`, `]` |
| Special | `$`, `_`, `->`, `{/}` |

### 3.4.2 Keywords

The following are reserved keywords:

| Keyword | Usage |
|---------|-------|
| `and` | Logical AND |
| `or` | Logical OR |
| `not` | Logical NOT |
| `true` | Boolean true |
| `false` | Boolean false |
| `else` | Else clause |
| `elif` | Else-if clause |

Keywords are case-sensitive and MUST NOT be used as identifiers.

### 3.4.3 Identifiers

Identifiers name variables and passages.

**Syntax:**
```ebnf
identifier = letter , { letter | digit | "_" } ;
letter = "a"..."z" | "A"..."Z" | "_" ;
digit = "0"..."9" ;
```

**Rules:**
- MUST start with a letter or underscore
- MAY contain letters, digits, and underscores
- Case-sensitive
- No length limit (implementations SHOULD support at least 255 characters)

#### 3.4.3.1 Identifier Limits and Edge Cases

**Length Requirements:**
| Limit | Minimum | Recommended | Notes |
|-------|---------|-------------|-------|
| Identifier length | 255 chars | 1024 chars | Applies to all identifier types |
| Nested scope depth | 16 levels | 64 levels | Function call depth |
| Unique identifiers | 1,000 | 65,536 | Per compilation unit |

**Reserved Identifier Patterns:**

Identifiers matching these patterns have special meaning:
- `_` (single underscore): Discard placeholder, cannot be referenced
- `__*` (double underscore prefix): Reserved for implementation
- `*__` (double underscore suffix): Reserved for implementation

**Edge Cases:**

| Input | Behavior | Error Code |
|-------|----------|------------|
| Empty string `""` | Error | WLS-SYN-020 |
| Whitespace only | Error | WLS-SYN-020 |
| Starts with digit | Error | WLS-SYN-021 |
| Contains hyphen | Error | WLS-SYN-022 |
| Unicode letters | Error (ASCII only) | WLS-SYN-023 |
| Length > limit | Error | WLS-SYN-024 |
| Reserved keyword | Error | WLS-SYN-025 |
| `__reserved__` | Warning (reserved) | WLS-SYN-026 |

**Identifier Shadowing:**

Inner scopes may shadow outer scope identifiers:
```whisker
{let name = "outer"}
{passage inner}
  {let name = "inner"}  // Shadows outer 'name'
  {name}                // Outputs "inner"
{end}
{name}                  // Outputs "outer"
```

Implementations SHOULD emit a warning for shadowed identifiers when enabled.

**Valid:**
```
name
playerName
_private
item1
MAX_VALUE
```

**Invalid:**
```
1stItem      // Starts with digit
my-variable  // Contains hyphen
my variable  // Contains space
```

### 3.4.4 Literals

#### Number Literals

```ebnf
number = integer | float ;
integer = [ "-" ] , digit , { digit } ;
float = [ "-" ] , digit , { digit } , "." , digit , { digit } ;
```

**Examples:**
```whisker
42        // Integer
-17       // Negative integer
3.14159   // Float
-0.5      // Negative float
0         // Zero
```

**Rules:**
- No octal or hexadecimal literals
- No scientific notation (1e10)
- No underscores in numbers (1_000)

#### String Literals

```ebnf
string = '"' , { string_char } , '"' ;
string_char = any_char - '"' - '\' | escape_sequence ;
```

**Examples:**
```whisker
"Hello, world!"
"Line 1\nLine 2"
"She said \"Hello\""
""                    // Empty string
```

**Rules:**
- Enclosed in double quotes only (no single quotes)
- May span multiple lines with escape sequences
- MUST escape internal double quotes

#### Boolean Literals

```ebnf
boolean = "true" | "false" ;
```

**Examples:**
```whisker
$hasKey = true
$isComplete = false
```

## 3.5 Operators

### 3.5.1 Arithmetic Operators

| Operator | Name | Example | Result |
|----------|------|---------|--------|
| `+` | Addition | `5 + 3` | `8` |
| `-` | Subtraction | `5 - 3` | `2` |
| `*` | Multiplication | `5 * 3` | `15` |
| `/` | Division | `5 / 2` | `2.5` |
| `%` | Modulo | `5 % 3` | `2` |
| `-` (unary) | Negation | `-5` | `-5` |

**Division Rules:**
- Division by zero MUST produce an error
- Integer division produces float if not evenly divisible

### 3.5.2 Comparison Operators

| Operator | Name | Example | Result |
|----------|------|---------|--------|
| `==` | Equal | `5 == 5` | `true` |
| `~=` | Not equal | `5 ~= 3` | `true` |
| `!=` | Not equal (alias) | `5 != 3` | `true` |
| `<` | Less than | `3 < 5` | `true` |
| `>` | Greater than | `5 > 3` | `true` |
| `<=` | Less or equal | `3 <= 3` | `true` |
| `>=` | Greater or equal | `5 >= 5` | `true` |

**Operator Aliases:**

| Primary | Alias | Notes |
|---------|-------|-------|
| `~=` | `!=` | Both mean "not equal"; `~=` is Lua-native, `!=` is familiar to C/JS users |

**Comparison Rules:**
- Numbers compared numerically
- Strings compared lexicographically (Unicode code points)
- Booleans: `false < true`
- Mixed types: MUST produce an error (no implicit coercion)

### 3.5.3 Logical Operators

| Operator | Name | Example | Result |
|----------|------|---------|--------|
| `and` | Logical AND | `true and false` | `false` |
| `or` | Logical OR | `true or false` | `true` |
| `not` | Logical NOT | `not true` | `false` |

**Short-Circuit Evaluation:**
- `and`: Returns first falsy operand or last operand
- `or`: Returns first truthy operand or last operand

```whisker
// Short-circuit examples
{ $x > 0 and $y / $x > 1 }   // Safe: $y/$x only evaluated if $x > 0
{ $default or $fallback }     // Returns $default if truthy
```

### 3.5.4 Assignment Operators

| Operator | Name | Example | Equivalent |
|----------|------|---------|------------|
| `=` | Assignment | `$x = 5` | - |
| `+=` | Add-assign | `$x += 5` | `$x = $x + 5` |
| `-=` | Subtract-assign | `$x -= 5` | `$x = $x - 5` |

### 3.5.5 String Operators

| Operator | Name | Example | Result |
|----------|------|---------|--------|
| `..` | Concatenation | `"a" .. "b"` | `"ab"` |

### 3.5.6 Operator Precedence

From highest to lowest:

| Precedence | Operators | Associativity |
|------------|-----------|---------------|
| 1 | `not`, unary `-` | Right |
| 2 | `*`, `/`, `%` | Left |
| 3 | `+`, `-`, `..` | Left |
| 4 | `<`, `>`, `<=`, `>=` | Left |
| 5 | `==`, `~=` | Left |
| 6 | `and` | Left |
| 7 | `or` | Left |

**Examples:**
```whisker
// Precedence examples
not $a and $b       // (not $a) and $b
$a or $b and $c     // $a or ($b and $c)
$a + $b * $c        // $a + ($b * $c)
$a == $b and $c     // ($a == $b) and $c
```

**Parentheses** override precedence:
```whisker
($a or $b) and $c   // Explicit grouping
```

## 3.6 Expressions

### 3.6.1 Expression Types

| Type | Example |
|------|---------|
| Literal | `42`, `"hello"`, `true` |
| Variable | `$gold`, `_temp` |
| Arithmetic | `$gold + 50` |
| Comparison | `$gold >= 100` |
| Logical | `$hasKey and $hasTorch` |
| Grouped | `($a + $b) * $c` |
| Function call | `whisker.random(1, 6)` |

### 3.6.2 Expression Grammar

```ebnf
expression = or_expr ;
or_expr = and_expr , { "or" , and_expr } ;
and_expr = equality_expr , { "and" , equality_expr } ;
equality_expr = comparison_expr , { ( "==" | "~=" ) , comparison_expr } ;
comparison_expr = additive_expr , { ( "<" | ">" | "<=" | ">=" ) , additive_expr } ;
additive_expr = multiplicative_expr , { ( "+" | "-" | ".." ) , multiplicative_expr } ;
multiplicative_expr = unary_expr , { ( "*" | "/" | "%" ) , unary_expr } ;
unary_expr = ( "not" | "-" ) , unary_expr | primary_expr ;
primary_expr = literal | variable | function_call | "(" , expression , ")" ;
```

### 3.6.3 Variable Expressions

```ebnf
variable = "$" , identifier | "_" , identifier ;
```

**Examples:**
```whisker
$playerName      // Story variable
$gold            // Story variable
_tempValue       // Temporary variable
```

### 3.6.4 Function Call Expressions

```ebnf
function_call = namespace , "." , identifier , "(" , [ arguments ] , ")" ;
arguments = expression , { "," , expression } ;
```

**Examples:**
```whisker
whisker.random(1, 10)
whisker.visited("Cave")
whisker.state.get("gold")
```

## 3.7 Statements

### 3.7.1 Assignment Statement

```ebnf
assignment = variable , assign_op , expression ;
assign_op = "=" | "+=" | "-=" ;
```

**Examples:**
```whisker
$gold = 100
$health -= 10
$score += $bonus
_temp = $gold * 2
```

### 3.7.2 Passage Declaration

```ebnf
passage_decl = "::" , identifier , newline , { directive } , content ;
directive = "@" , directive_name , ":" , directive_value , newline ;
```

**Examples:**
```whisker
:: MyPassage
Content here.

:: AnnotatedPassage
@tags: important, chapter1
@color: #ff0000
Content with metadata.
```

### 3.7.3 Choice Statement

```ebnf
choice = choice_marker , [ condition ] , "[" , choice_text , "]" , [ action ] , "->" , identifier ;
choice_marker = "+" | "*" ;
condition = "{" , expression , "}" ;
action = "{" , lua_code , "}" ;
```

**Examples:**
```whisker
+ [Simple choice] -> Target
* [Sticky choice] -> Target
+ { $gold >= 50 } [Buy item] -> Shop
+ [Take gold] { $gold += 100 } -> Next
+ { $hasKey } [Unlock] { $doorOpen = true } -> Inside
```

## 3.8 Conditional Blocks

### 3.8.1 Block Conditional

```ebnf
conditional = "{" , expression , "}" , content , [ else_clause ] , "{/}" ;
else_clause = "{else}" , content | "{elif" , expression , "}" , content , [ else_clause ] ;
```

**Examples:**
```whisker
// Simple if
{ $hasKey }
  You unlock the door.
{/}

// If-else
{ $gold >= 100 }
  You can afford it.
{else}
  You need more gold.
{/}

// If-elif-else
{ $health > 75 }
  You feel great!
{elif $health > 25}
  You're getting tired.
{else}
  You're badly wounded.
{/}
```

### 3.8.2 Inline Conditional

```ebnf
inline_conditional = "{" , expression , ":" , true_content , [ "|" , false_content ] , "}" ;
```

**Examples:**
```whisker
The door is {$hasKey: unlocked | locked}.
You have {$gold} gold {$gold == 1: piece | pieces}.
{$isNight: The moon shines. | The sun is bright.}
```

### 3.8.3 Brace Construct Disambiguation

The `{` character begins several constructs. Parsers distinguish them by lookahead:

| After `{` | Construct | Example |
|-----------|-----------|---------|
| `\|` | Alternative | `{\| a \| b }` |
| `$`/`_` then `:` then non-`:` | Inline conditional | `{$x: yes \| no}` |
| `$`/`_` then `=` | Action block | `{$x = 1}` |
| `@` | Hook operation | `{@show: name}` |
| identifier `:` value | Map literal | `{key: val}` |
| expression `}` newline | Conditional block | `{$flag}` |

#### Parsing Strategy

1. Consume `{`
2. If next is `|`, parse as alternative
3. If next is `@`, parse as hook operation
4. Parse expression/identifier
5. Lookahead for `:`, `=`, `}`, or `|`
6. Dispatch based on lookahead

#### Maximum Lookahead: 3 tokens

## 3.9 Text Alternatives

### 3.9.1 Syntax

```ebnf
alternative = "{" , alt_type , "|" , alt_content , { "|" , alt_content } , "}" ;
alt_type = "" | "&" | "~" | "!" ;
```

### 3.9.2 Alternative Types

| Syntax | Type | Behavior |
|--------|------|----------|
| `{\| a \| b \| c }` | Sequence | Shows a, then b, then c, then stays on c |
| `{&\| a \| b \| c }` | Cycle | Shows a, b, c, a, b, c, ... |
| `{~\| a \| b \| c }` | Shuffle | Random selection each time |
| `{!\| a \| b \| c }` | Once-only | Shows a, then b, then c, then nothing |

**Examples:**
```whisker
// Sequence (stopping)
{| First visit. | Second visit. | You've been here many times. }

// Cycle
The light is {&| red | yellow | green }.

// Shuffle
You see {~| a bird | a squirrel | nothing | a shadow } in the trees.

// Once-only
{!| "Welcome!" | "Nice to see you again." | "Hello." }
```

### 3.9.3 Multi-line Alternatives

```whisker
{|
  | This is the first option
    with multiple lines.
  | This is the second option.
  | And the third.
}
```

## 3.10 Variable Interpolation

### 3.10.1 Simple Interpolation

```ebnf
simple_interpolation = "$" , identifier ;
```

**Example:**
```whisker
Hello, $playerName! You have $gold gold.
```

### 3.10.2 Expression Interpolation

```ebnf
expr_interpolation = "${" , expression , "}" ;
```

**Example:**
```whisker
Double gold: ${$gold * 2}
Random: ${whisker.random(1, 6)}
Total: ${$base + $bonus}
```

### 3.10.3 Interpolation Context

Interpolation is performed in:

- Passage content
- Choice text
- String literals (in Lua blocks)

Interpolation is NOT performed in:

- Comments
- Passage names
- Directive values

## 3.11 Escape Sequences

### 3.11.1 Escape Sequence Table

| Sequence | Result | Description |
|----------|--------|-------------|
| `\\` | `\` | Backslash |
| `\$` | `$` | Dollar sign (prevents interpolation) |
| `\{` | `{` | Open brace |
| `\}` | `}` | Close brace |
| `\[` | `[` | Open bracket |
| `\]` | `]` | Close bracket |
| `\n` | newline | Line feed |
| `\t` | tab | Horizontal tab |
| `\"` | `"` | Double quote (in strings) |

### 3.11.2 Examples

```whisker
// Escaping special characters
The price is \$50.           // Shows: The price is $50.
Use \{ and \} for blocks.    // Shows: Use { and } for blocks.
Path: C:\\Users\\Name        // Shows: Path: C:\Users\Name

// In strings
$message = "She said \"Hello\""
$path = "C:\\Program Files"
```

### 3.11.3 Context-Specific Escaping

| Context | Characters Requiring Escape |
|---------|----------------------------|
| Prose text | `$`, `{`, `}` |
| String literals | `"`, `\`, `$` |
| Choice text | `[`, `]`, `$`, `{` |
| Comments | None (no escaping needed) |

### 3.11.4 Unicode Escapes

```whisker
// Unicode code point (4 hex digits)
$heart = "\u2764"            // ❤

// Extended Unicode (6 hex digits)
$emoji = "\U01F600"          // 😀

// Direct UTF-8 (always allowed)
$direct = "❤😀"              // Same result
```

### 3.11.5 Raw Strings

For content with many special characters, use raw strings:

```whisker
// Raw string (no escape processing)
$regex = r"^\$\d+\.\d{2}$"   // Literal: ^\$\d+\.\d{2}$
$path = r"C:\Users\Name"     // Literal: C:\Users\Name
```

### 3.11.6 Invalid Escapes

| Input | Behavior |
|-------|----------|
| `\x` (unknown) | Error WLS-SYN-004 |
| `\` at end of line | Line continuation |
| `\` at end of file | Error WLS-SYN-004 |

## 3.12 Embedded Lua

### 3.12.1 Inline Lua

```ebnf
inline_lua = "{{" , lua_code , "}}" ;
```

**Example:**
```whisker
$random = {{ math.random(1, 100) }}
$upper = {{ string.upper(whisker.state.get("name")) }}
```

### 3.12.2 Block Lua

```ebnf
block_lua = "{{" , newline , lua_code , newline , "}}" ;
```

**Example:**
```whisker
{{
  local bonus = 0
  if whisker.state.get("level") > 10 then
    bonus = 50
  end
  whisker.state.set("gold", whisker.state.get("gold") + bonus)
}}
```

### 3.12.3 Lua Sandboxing

Embedded Lua runs in a sandboxed environment:

**Available:**
- All standard Lua operators
- `math` library
- `string` library
- `table` library (limited)
- `whisker.*` API

**Not Available:**
- File I/O (`io`)
- Operating system (`os` except `os.time`, `os.date`)
- Debug library
- `load`, `loadfile`, `dofile`
- `require`

## 3.13 Navigation Syntax

### 3.13.1 Choice Navigation

```ebnf
navigation = "->" , target ;
target = identifier | "END" | "BACK" | "RESTART" ;
```

**Examples:**
```whisker
+ [Go north] -> NorthRoom
+ [End game] -> END
+ [Go back] -> BACK
+ [Start over] -> RESTART
```

### 3.13.2 Special Targets

| Target | Behavior |
|--------|----------|
| `END` | Terminates the story |
| `BACK` | Returns to previous passage |
| `RESTART` | Restarts from beginning |

## 3.14 Passage Links

### 3.14.1 Full Link Syntax

```ebnf
link = "[[" , link_text , "->" , target , "]]" ;
```

**Example:**
```whisker
Go to the [[forest->Forest]] or the [[mountain->Mountain]].
```

### 3.14.2 Short Link Syntax

```ebnf
short_link = "[[" , identifier , "]]" ;
```

**Example:**
```whisker
Visit the [[Garden]] or the [[Library]].
// Equivalent to: [[Garden->Garden]] or [[Library->Library]]
```

## 3.15 Story Header

### 3.15.1 Header Syntax

```ebnf
header = { header_directive } ;
header_directive = "@" , directive_name , ":" , directive_value , newline ;
```

### 3.15.2 Header Directives

| Directive | Type | Description |
|-----------|------|-------------|
| `@title:` | string | Story title |
| `@author:` | string | Author name |
| `@version:` | string | Version (semver) |
| `@ifid:` | string | Unique ID (UUID) |
| `@start:` | identifier | Start passage name |

**Example:**
```whisker
@title: The Great Adventure
@author: Jane Doe
@version: 1.0.0
@ifid: 550e8400-e29b-41d4-a716-446655440000
@start: Prologue

:: Prologue
Your journey begins...
```

### 3.15.3 Variable Initialization

```ebnf
vars_section = "@vars" , newline , { var_init } ;
var_init = identifier , ":" , literal , newline ;
```

**Example:**
```whisker
@vars
  gold: 100
  playerName: "Adventurer"
  hasKey: false

:: Start
Welcome, $playerName!
```

## 3.16 Complete Grammar Summary

See [GRAMMAR.ebnf](../GRAMMAR.ebnf) for the complete formal grammar.

### 3.16.1 Top-Level Structure

```ebnf
story = [ header ] , { passage } ;
header = { header_directive } ;
passage = passage_header , { directive } , content ;
content = { content_element } ;
content_element = text | conditional | alternative | choice | assignment | link | embedded_lua ;
```

## 3.17 Comprehensive Edge Cases

This section consolidates edge case behaviors for all major constructs.

### 3.17.1 String Edge Cases

| Scenario | Input | Behavior | Error |
|----------|-------|----------|-------|
| Empty string | `""` | Valid, zero length | - |
| Null character | `"\0"` | Error | WLS-SYN-040 |
| Very long string | 10MB+ | Impl-dependent | WLS-LIM-001 |
| Unclosed string | `"abc` | Error | WLS-SYN-003 |
| Multiline unescaped | `"line1\nline2"` | Valid | - |
| Raw string unclosed | `` `abc `` | Error | WLS-SYN-003 |

### 3.17.2 Number Edge Cases

| Scenario | Input | Behavior | Error |
|----------|-------|----------|-------|
| Leading zeros | `007` | Valid, equals 7 | - |
| Trailing decimal | `42.` | Error | WLS-SYN-041 |
| Leading decimal | `.5` | Error | WLS-SYN-041 |
| Multiple decimals | `1.2.3` | Error | WLS-SYN-041 |
| Hex notation | `0xFF` | Not supported | WLS-SYN-042 |
| Scientific | `1e10` | Not supported | WLS-SYN-042 |
| Infinity | `Infinity` | Via Lua only | - |
| NaN | `NaN` | Via Lua only | - |

### 3.17.3 Conditional Edge Cases

| Scenario | Input | Behavior |
|----------|-------|----------|
| Empty condition | `{}` | Error WLS-SYN-043 |
| Nested 10+ deep | `{{{...}}}` | Valid but perf warning |
| Else without if | `{else}...{/}` | Error WLS-SYN-044 |
| Multiple else | `{else}...{else}` | Error WLS-SYN-045 |
| Unclosed | `{$x}...` | Error WLS-SYN-002 |
| Empty branches | `{$x}{else}{/}` | Valid |

### 3.17.4 Choice Edge Cases

| Scenario | Input | Behavior |
|----------|-------|----------|
| Empty choice text | `* []` | Valid, invisible choice |
| No target | `* [Go]` | Error WLS-NAV-001 |
| Self-target | `* [Again] -> CurrentPassage` | Valid |
| Recursive sticky | `+ [Loop] -> CurrentPassage` | Valid, shows each visit |
| 1000+ choices | Large choice list | Valid, scroll warning |
| Duplicate text | Two `* [Same]` | Valid, both shown |

### 3.17.5 Navigation Edge Cases

| Scenario | Input | Behavior |
|----------|-------|----------|
| Undefined passage | `-> Missing` | Error WLS-NAV-002 |
| Empty passage name | `->` | Error WLS-SYN-046 |
| Circular navigation | `A -> B -> A` | Valid, continues |
| Deep tunnel stack | 100+ tunnels | Impl limit check |
| END from tunnel | `-> END` inside `->->` | Ends story, clears stack |

### 3.17.6 Variable Edge Cases

| Scenario | Input | Behavior |
|----------|-------|----------|
| Undefined read | `{$missing}` | nil (no error) |
| Type coercion | `{$num .. $str}` | Number to string |
| Self-reference | `{$x = $x + 1}` | Valid |
| Circular reference | Object A refs B refs A | Serialization error |
| Reserved name | `{$__internal = 1}` | Warning |

### 3.17.7 Whitespace Edge Cases

| Scenario | Input | Behavior |
|----------|-------|----------|
| Tab vs spaces | Mixed | Warning (style) |
| Trailing whitespace | `line   ` | Trimmed in output |
| Leading whitespace | `   line` | Preserved |
| Blank lines in prose | Multiple `\n\n` | Collapsed to one |
| CRLF mixed with LF | Windows/Unix | Normalized |

### 3.17.8 Comment Edge Cases

| Scenario | Input | Behavior |
|----------|-------|----------|
| Nested `/* */` | `/* /* */ */` | Not nested, first `*/` ends |
| Comment in string | `"/* not a comment */"` | String content |
| Unclosed block | `/* no end` | Error WLS-SYN-047 |
| Empty comment | `//` | Valid |
| Comment at EOF | `// no newline` | Valid |

---

**Previous Chapter:** [Core Concepts](02-CORE_CONCEPTS.md)
**Next Chapter:** [Variables](04-VARIABLES.md)

---


# Chapter 4: Variables

**Whisker Language Specification 1.0**

---

## 4.1 Overview

Variables store and track state throughout a story. WLS provides a simple but powerful variable system with two scopes, three types, and flexible interpolation.

## 4.2 Variable Declaration

### 4.2.1 Implicit Declaration

Variables are implicitly declared on first assignment:

```whisker
:: Start
$gold = 100          // Declares and assigns $gold
$playerName = "Hero" // Declares and assigns $playerName
$hasKey = false      // Declares and assigns $hasKey
```

### 4.2.2 Header Declaration

Variables MAY be pre-declared in the story header with initial values:

```whisker
@vars
  gold: 100
  playerName: "Adventurer"
  hasKey: false
  health: 100.0

:: Start
Welcome, $playerName! You have $gold gold.
```

**Header declaration benefits:**
- Documents all story variables in one place
- Sets default values before story starts
- Enables tooling support (autocomplete, validation)

### 4.2.3 Declaration Rules

| Rule | Description |
|------|-------------|
| First assignment wins | Type is set on first assignment |
| No explicit typing | Types are inferred from values |
| No forward declaration | Variables exist after assignment |
| No hoisting | Variables are not accessible before declaration |

## 4.3 Variable Types

### 4.3.1 Number

Numbers represent numeric values, both integers and floating-point.

```whisker
$gold = 100        // Integer
$health = 75.5     // Float
$temperature = -10 // Negative
$zero = 0          // Zero
```

**Number properties:**

| Property | Value |
|----------|-------|
| Range | ±1.7976931348623157E+308 |
| Precision | 15-17 significant decimal digits |
| Integer range | ±9007199254740991 (2^53 - 1) |

#### 4.3.1.1 Numeric Representation

WLS numbers follow IEEE 754 double-precision floating-point.

**Special Values:**

| Value | Supported | Behavior |
|-------|-----------|----------|
| Infinity | Yes | Result of overflow |
| -Infinity | Yes | Result of negative overflow |
| NaN | Yes | Result of undefined operations |

**Overflow Behavior:**

- Positive overflow → `Infinity`
- Negative overflow → `-Infinity`
- Underflow → `0`

**Examples:**

```whisker
$big = 1e309        // Infinity
$tiny = 1e-400      // 0 (underflow)
$weird = 0 / 0      // NaN
$inf = 1 / 0        // Infinity
```

**Number operations:**

```whisker
$a = 10 + 5      // 15
$b = 10 - 5      // 5
$c = 10 * 5      // 50
$d = 10 / 4      // 2.5
$e = 10 % 3      // 1
$f = -$a         // -15
```

### 4.3.2 String

Strings represent text values.

```whisker
$name = "Alice"
$greeting = "Hello, world!"
$empty = ""
$quoted = "She said \"Hi\""
$multiline = "Line 1\nLine 2"
```

**String properties:**

| Property | Value |
|----------|-------|
| Encoding | UTF-8 |
| Max length | Implementation-defined (at least 65535) |
| Delimiter | Double quotes only |
| Escape sequences | See Section 3.11 |

**String operations:**

```whisker
$full = $first .. " " .. $last   // Concatenation
$len = {{ string.len(whisker.state.get("name")) }}  // Length via Lua
```

### 4.3.3 Boolean

Booleans represent true/false values.

```whisker
$hasKey = true
$isComplete = false
$isAlive = true
```

**Boolean operations:**

```whisker
$result = $a and $b    // Logical AND
$result = $a or $b     // Logical OR
$result = not $a       // Logical NOT
```

### 4.3.4 List

Lists are enumerated sets of named values. They are useful for tracking states, inventory items, and flags.

```whisker
LIST moods = happy, sad, angry, neutral
LIST inventory = (sword), (shield), potion  // parentheses = initially active

{$mood = neutral}       // Set value
{$mood == happy}        // Test value
{$inventory += sword}   // Add to list
{$inventory -= sword}   // Remove from list
{$inventory ? sword}    // Check if contains
```

See Section 4.13 for complete LIST documentation.

### 4.3.5 Array

Arrays are ordered, indexed collections of values.

```whisker
ARRAY items = ["sword", "shield", "potion"]
ARRAY scores = [100, 95, 87, 92]

${$items[0]}            // Access by index (0-based)
${#$items}              // Length
{$items += "bow"}       // Append
{$items[1] = "axe"}     // Replace at index
```

See Section 4.14 for complete ARRAY documentation.

### 4.3.6 Map

Maps are key-value collections for structured data.

```whisker
MAP player = { name: "Hero", health: 100, level: 1 }

${$player.name}         // Dot access
${$player["health"]}    // Bracket access
{$player.level += 1}    // Modify property
{$player.mana = 50}     // Add property
```

See Section 4.15 for complete MAP documentation.

### 4.3.7 Type Summary

| Type | Literals | Default | Falsy Value |
|------|----------|---------|-------------|
| number | `42`, `3.14`, `-10` | `0` | `0` |
| string | `"text"` | `""` | `""` (empty) |
| boolean | `true`, `false` | `false` | `false` |
| list | `LIST name = a, b, c` | empty list | empty list |
| array | `[1, 2, 3]` | `[]` | `[]` (empty) |
| map | `{ key: value }` | `{}` | `{}` (empty) |

## 4.4 Variable Scopes

### 4.4.1 Story Scope (`$`)

Story-scoped variables persist for the entire playthrough.

```whisker
$gold = 100      // Available everywhere
$playerName = "Hero"

:: Shop
You have $gold gold.   // Accessible here

:: Dungeon
$gold -= 10            // Still accessible
```

**Characteristics:**
- Prefix: `$`
- Lifetime: Entire story session
- Saved: Included in save files
- Access: All passages

### 4.4.2 Temporary Scope (`_`)

Temporary variables exist only within the current passage.

```whisker
:: Calculate
_baseValue = 100
_modifier = 1.5
_result = _baseValue * _modifier

The result is $_result.   // "The result is 150"

+ [Continue] -> NextPassage

:: NextPassage
// _baseValue, _modifier, _result are all undefined here
```

**Characteristics:**
- Prefix: `_`
- Lifetime: Current passage only
- Saved: NOT included in save files
- Access: Current passage only
- Cleared: On passage exit

### 4.4.3 Scope Comparison

| Feature | Story (`$`) | Temporary (`_`) |
|---------|-------------|-----------------|
| Prefix | `$` | `_` |
| Lifetime | Entire session | Current passage |
| Persisted | Yes | No |
| Use case | Game state | Calculations |

### 4.4.4 Shadowing

Temporary variables MUST NOT shadow story variables:

```whisker
// INVALID: Cannot shadow
$gold = 100
_gold = 50     // Error: shadows $gold

// VALID: Different names
$gold = 100
_tempGold = 50  // OK: different name
```

## 4.5 Variable Interpolation

### 4.5.1 Simple Interpolation

Use `$` followed by the variable name to interpolate values:

```whisker
$playerName = "Alice"
$gold = 100

Hello, $playerName!           // "Hello, Alice!"
You have $gold gold coins.    // "You have 100 gold coins."
```

**Rules:**
- Variable name extends to first non-identifier character
- Interpolation occurs in passage content and choice text
- Undefined variables produce an error

### 4.5.2 Expression Interpolation

Use `${}` to interpolate complex expressions:

```whisker
$gold = 100
$bonus = 50

Total: ${$gold + $bonus}           // "Total: 150"
Double: ${$gold * 2}               // "Double: 200"
Tax: ${$gold * 0.1}                // "Tax: 10"
Random: ${whisker.random(1, 6)}    // "Random: 3" (varies)
```

**Supported in expressions:**
- Arithmetic operations
- Variable references
- Function calls
- Parenthesized expressions

### 4.5.3 Interpolation Contexts

| Context | Simple (`$var`) | Expression (`${expr}`) |
|---------|-----------------|------------------------|
| Passage content | Yes | Yes |
| Choice text | Yes | Yes |
| Choice conditions | Yes | Yes |
| Lua strings | No* | No* |
| Comments | No | No |
| Passage names | No | No |

*Use `whisker.state.get()` in Lua instead.

### 4.5.4 Preventing Interpolation

Use backslash to escape the dollar sign:

```whisker
The price is \$50.        // "The price is $50."
Variable syntax: \$name   // "Variable syntax: $name"
```

### 4.5.5 Adjacent Interpolation

Multiple interpolations can be adjacent:

```whisker
$first = "John"
$last = "Doe"

Name: $first$last         // "Name: JohnDoe"
Name: $first $last        // "Name: John Doe"
Full: ${$first} ${$last}  // "Full: John Doe"
```

## 4.6 Variable Operations

### 4.6.1 Assignment

```whisker
$gold = 100              // Simple assignment
$name = "Hero"
$active = true
```

### 4.6.2 Compound Assignment

```whisker
$gold += 50              // Add: $gold = $gold + 50
$health -= 10            // Subtract: $health = $health - 10
```

**Compound assignment rules:**
- Variable MUST exist (no implicit creation)
- Types MUST be compatible (numbers only for `+=`, `-=`)

### 4.6.3 Accessing Undefined Variables

Accessing an undefined variable MUST produce an error:

```whisker
:: Start
You have $gold gold.     // Error: $gold is undefined

// Correct approach:
$gold = 0
You have $gold gold.     // OK: "You have 0 gold."
```

### 4.6.4 Variable Deletion

Variables cannot be deleted in WLS. To "clear" a variable, set it to a default value:

```whisker
$gold = 0                // "Clear" to zero
$name = ""               // "Clear" to empty string
$hasKey = false          // "Clear" to false
```

## 4.7 Type Coercion

### 4.7.1 Explicit Coercion

WLS does NOT perform implicit type coercion. Type mismatches produce errors:

```whisker
$num = 42
$str = "hello"

// INVALID: Type mismatch
$result = $num + $str    // Error: cannot add number and string

// VALID: Explicit handling
$result = $num .. ""     // Convert number to string for concatenation
```

### 4.7.2 Coercion Rules

| Operation | Allowed Types | Result Type |
|-----------|---------------|-------------|
| `+`, `-`, `*`, `/`, `%` | number, number | number |
| `..` | string, string | string |
| `==`, `~=` | any, same type | boolean |
| `<`, `>`, `<=`, `>=` | number, number OR string, string | boolean |
| `and`, `or` | any | last evaluated |
| `not` | any | boolean |

### 4.7.3 Truthiness

For boolean contexts (conditions), values are evaluated as:

| Type | Truthy | Falsy |
|------|--------|-------|
| boolean | `true` | `false` |
| number | non-zero | `0` |
| string | non-empty | `""` |

```whisker
$gold = 0
{ $gold }           // False (0 is falsy)
  You have gold.
{/}

$name = ""
{ $name }           // False (empty string is falsy)
  Hello, $name!
{/}
```

## 4.8 Variable Naming Conventions

### 4.8.1 Recommended Conventions

| Convention | Example | Use Case |
|------------|---------|----------|
| camelCase | `$playerName` | General variables |
| UPPER_CASE | `$MAX_HEALTH` | Constants (by convention) |
| prefixed | `$inv_sword` | Categorized variables |
| boolean prefix | `$hasKey`, `$isAlive` | Boolean flags |

### 4.8.2 Reserved Prefixes

| Prefix | Reserved For |
|--------|--------------|
| `whisker_` | Engine internal use |
| `_` (single) | Temporary variables |
| `__` (double) | Implementation internal |

### 4.8.3 Examples

```whisker
// Good naming
$playerName = "Hero"
$currentHealth = 100
$maxHealth = 100
$hasKey = true
$isGameOver = false
$inv_sword = true
$inv_shield = true

// Avoid
$x = 100             // Not descriptive
$temp = "value"      // Use _temp for temporaries
$PlayerName = "Hero" // Inconsistent casing
```

## 4.9 Built-in Variables

### 4.9.1 Engine-Provided State

The engine provides read-only access to certain state via API:

| Access | Description |
|--------|-------------|
| `whisker.visited(id)` | Visit count for passage |
| `whisker.passage.current()` | Current passage object |
| `whisker.history.count()` | History length |

These are NOT variables but function calls.

### 4.9.2 No Magic Variables

WLS does not define any magic or automatic variables. All state tracking is explicit:

```whisker
// Track visits manually if needed
$caveVisits = 0

:: Cave
$caveVisits += 1
{ $caveVisits == 1 }
  First time in the cave!
{/}

// Or use the API
{ whisker.visited("Cave") == 1 }
  First time in the cave!
{/}
```

## 4.10 Variable Persistence

### 4.10.1 Session Persistence

Story variables (`$`) persist for the duration of a play session:

- Maintained across passage transitions
- Maintained during history navigation (back)
- Reset on story restart

### 4.10.2 Save/Load Persistence

When a story is saved:

| Variable Type | Saved |
|---------------|-------|
| Story (`$`) | Yes |
| Temporary (`_`) | No |

### 4.10.3 Initial State on Load

When a save is loaded:

1. Story variables are restored to saved values
2. Temporary variables are undefined
3. Current passage is restored
4. History is restored

## 4.11 Error Conditions

### 4.11.1 Variable Errors

| Error | Cause | Example |
|-------|-------|---------|
| Undefined variable | Access before assignment | `$gold` before `$gold = 100` |
| Type mismatch | Operation on incompatible types | `$num + $str` |
| Invalid name | Name doesn't follow rules | `$1stPlace` |
| Shadowing | Temp shadows story var | `_gold` when `$gold` exists |

### 4.11.2 Error Messages

Implementations SHOULD provide helpful error messages:

```
Error at line 5, column 10:
  Undefined variable: $gold

  Hint: Did you mean to initialize this variable first?

  $gold = 0  // Add this before using $gold
```

## 4.12 Implementation Notes

### 4.12.1 Storage Requirements

Implementations MUST:
- Store variable names (strings)
- Store variable values (typed)
- Track variable scope (story vs temp)
- Support at least 1000 variables per story

### 4.12.2 Performance Considerations

Implementations SHOULD:
- Use hash tables for O(1) variable lookup
- Avoid unnecessary copying of string values
- Clear temporary variables efficiently on passage exit

### 4.12.3 API Access

Variables are accessible via the Lua API:

```lua
-- Get value
local gold = whisker.state.get("gold")

-- Set value
whisker.state.set("gold", 100)

-- Check existence
if whisker.state.has("gold") then
  -- ...
end

-- Get all variables
local all = whisker.state.all()
```

## 4.13 Lists (Enumerated Sets)

### 4.13.1 Overview

Lists are enumerated sets of named values, inspired by Ink's LIST type. They are ideal for tracking states, inventory items, character traits, and other categorical data.

### 4.13.2 Declaration Syntax

```whisker
LIST listName = value1, value2, value3
LIST listName = (active1), (active2), inactive1  // parentheses = initially active
```

**Rules:**
- List values are identifiers (no quotes needed)
- Values in parentheses are initially active (in the set)
- Values without parentheses are defined but not initially active
- List names follow variable naming rules

### 4.13.3 List Operations

| Operation | Syntax | Description |
|-----------|--------|-------------|
| Add | `{$list += value}` | Add value to set |
| Remove | `{$list -= value}` | Remove value from set |
| Toggle | `{$list ~= value}` | Toggle value in/out of set |
| Contains | `{$list ? value}` | Check if value is in set |
| Set single | `{$list = value}` | Clear list and set single value |
| Clear | `{$list = ()}` | Remove all values |

### 4.13.4 List Comparisons

```whisker
{$mood == happy}         // True if only 'happy' is active
{$mood ? happy}          // True if 'happy' is among active values
{$inventory ? sword}     // True if sword is in inventory
{#$inventory == 0}       // True if inventory is empty
{#$inventory > 2}        // True if more than 2 items
```

### 4.13.5 List Examples

```whisker
// Define moods with 'neutral' initially active
LIST moods = happy, sad, angry, (neutral)

:: Start
Your mood is $moods.

+ [Feel happy] {$moods = happy}
+ [Feel sad] {$moods = sad}
+ [Mixed feelings] {$moods += happy; $moods += sad}

- Continue with your mood: $moods.

// Inventory example
LIST inventory = sword, shield, potion, key

:: Shop
{$inventory += sword}
You bought a sword!

{ $inventory ? sword }
  You already have a sword.
{/}
```

### 4.13.6 List Serialization

Lists are serialized as arrays of active value names:

```json
{
  "moods": ["happy", "neutral"],
  "inventory": ["sword", "shield"]
}
```

## 4.14 Arrays

### 4.14.1 Overview

Arrays are ordered, indexed collections of values. They support mixed types and provide efficient access by index.

### 4.14.2 Declaration Syntax

```whisker
ARRAY arrayName = [value1, value2, value3]
ARRAY empty = []
ARRAY mixed = [1, "two", true, 3.14]
```

**Rules:**
- Array literals use square brackets `[]`
- Elements are comma-separated
- Elements can be any type (number, string, boolean, or nested collections)
- Indices are 0-based

### 4.14.3 Array Access

```whisker
${$items[0]}              // First element (0-based)
${$items[#$items - 1]}    // Last element
${$items[-1]}             // Also last element (negative indexing)
```

**Negative indexing:**
- `[-1]` = last element
- `[-2]` = second-to-last
- `[-n]` = nth element from end

#### 4.14.3.1 Index Edge Cases

| Scenario | Index | Array Length | Result | Notes |
|----------|-------|--------------|--------|-------|
| Valid positive | `[0]` | 3 | First element | 0-based indexing |
| Valid positive | `[2]` | 3 | Third element | Last valid index |
| Out of bounds | `[3]` | 3 | nil | No error, returns nil |
| Valid negative | `[-1]` | 3 | Third element | Same as `[2]` |
| Valid negative | `[-3]` | 3 | First element | Same as `[0]` |
| Out of bounds negative | `[-4]` | 3 | nil | Exceeds array start |
| Empty array | `[0]` | 0 | nil | All indices invalid |
| Non-integer | `[1.5]` | 3 | Error | WLS-TYP-007 |
| Non-numeric | `["key"]` | 3 | Error | WLS-TYP-007, use map for string keys |

**Negative Index Calculation:**

```
effective_index = array_length + negative_index
// [-1] on array of length 3: 3 + (-1) = 2 (last element)
// [-3] on array of length 3: 3 + (-3) = 0 (first element)
// [-4] on array of length 3: 3 + (-4) = -1 (out of bounds)
```

**Assignment to Out-of-Bounds Index:**

```whisker
ARRAY items = [1, 2, 3]
{$items[10] = "x"}  // Error: WLS-TYP-007 (cannot assign to gap)
{$items[-1] = "x"}  // Valid: sets last element to "x"
{$items[-5] = "x"}  // Error: WLS-TYP-007 (negative overflow)
```

Implementations MUST NOT auto-expand arrays with nil/null gaps. Use explicit append operations for growth.

### 4.14.4 Array Operations

| Operation | Syntax | Description |
|-----------|--------|-------------|
| Append | `{$arr += value}` | Add to end |
| Prepend | `{$arr = [value] .. $arr}` | Add to beginning |
| Set index | `{$arr[i] = value}` | Set element at index |
| Length | `${#$arr}` | Get array length |
| Pop | `{_last = whisker.array.pop($arr)}` | Remove and return last |
| Shift | `{_first = whisker.array.shift($arr)}` | Remove and return first |
| Slice | `{_sub = whisker.array.slice($arr, 1, 3)}` | Get subarray |

### 4.14.5 Array Iteration

Arrays can be iterated in conditions:

```whisker
ARRAY scores = [100, 95, 87, 92]

{ whisker.array.contains($scores, 100) }
  Perfect score achieved!
{/}

// Display all scores
{| $scores[0] | $scores[1] | $scores[2] | $scores[3] |}
```

### 4.14.6 Array Examples

```whisker
ARRAY inventory = []

:: Shop
+ [Buy sword] {$inventory += "sword"} -> Bought
+ [Buy shield] {$inventory += "shield"} -> Bought
+ [Check inventory] -> CheckInventory

:: Bought
Item added! You now have ${#$inventory} items.
-> Shop

:: CheckInventory
Your inventory:
{ #$inventory == 0 }
  Empty!
{else}
  ${#$inventory} items: $inventory
{/}
-> Shop
```

### 4.14.7 Array Serialization

Arrays are serialized as JSON arrays:

```json
{
  "inventory": ["sword", "shield", "potion"],
  "scores": [100, 95, 87]
}
```

## 4.15 Maps

### 4.15.1 Overview

Maps are key-value collections for structured data. They are ideal for representing complex objects like player stats, NPC data, or game configuration.

### 4.15.2 Declaration Syntax

```whisker
MAP mapName = { key1: value1, key2: value2 }
MAP empty = {}
MAP player = {
  name: "Hero",
  health: 100,
  level: 1,
  inventory: ["sword", "shield"]
}
```

**Rules:**
- Map literals use curly braces `{}`
- Keys are identifiers or quoted strings
- Values can be any type
- Trailing commas are allowed

### 4.15.3 Map Access

```whisker
${$player.name}           // Dot notation
${$player["name"]}        // Bracket notation
${$player.stats.strength} // Nested access
```

**Access rules:**
- Dot notation for identifier keys
- Bracket notation for dynamic keys or non-identifier keys
- Accessing undefined keys returns nil

### 4.15.4 Map Operations

| Operation | Syntax | Description |
|-----------|--------|-------------|
| Set property | `{$map.key = value}` | Set or add property |
| Delete | `{$map.key = nil}` | Remove property |
| Has key | `{$map.key ~= nil}` | Check if key exists |
| Get keys | `${whisker.map.keys($map)}` | Get array of keys |
| Get values | `${whisker.map.values($map)}` | Get array of values |
| Merge | `{$map = whisker.map.merge($map1, $map2)}` | Combine maps |

### 4.15.5 Nested Maps

```whisker
MAP game = {
  player: {
    name: "Hero",
    stats: {
      health: 100,
      mana: 50
    }
  },
  settings: {
    difficulty: "normal"
  }
}

:: Start
Welcome, ${$game.player.name}!
Health: ${$game.player.stats.health}
Difficulty: ${$game.settings.difficulty}

+ [Take damage] {$game.player.stats.health -= 10}
  You now have ${$game.player.stats.health} health.
```

### 4.15.6 Map Examples

```whisker
MAP player = {
  name: "Adventurer",
  class: "warrior",
  level: 1,
  gold: 100,
  skills: ["slash", "block"]
}

:: CharacterSheet
# ${$player.name}
Class: ${$player.class}
Level: ${$player.level}
Gold: ${$player.gold}

+ [Level up] {$player.level += 1; $player.gold -= 50}
  { $player.gold >= 50 }
    Leveled up to ${$player.level}!
  {else}
    Not enough gold!
  {/}
+ [Learn skill] {$player.skills += "power_strike"}
  Learned Power Strike!
```

### 4.15.7 Map Serialization

Maps are serialized as JSON objects:

```json
{
  "player": {
    "name": "Hero",
    "health": 100,
    "level": 1,
    "inventory": ["sword", "shield"]
  }
}
```

## 4.16 Collection Error Codes

| Code | Name | Description |
|------|------|-------------|
| WLS-TYP-006 | invalid_list_operation | Operation not valid for list type |
| WLS-TYP-007 | array_index_invalid | Array index out of bounds or invalid |
| WLS-TYP-008 | map_key_invalid | Map key is not a string or identifier |
| WLS-TYP-009 | collection_type_mismatch | Expected collection, got scalar |
| WLS-TYP-010 | nested_access_on_scalar | Attempted nested access on non-collection |

---

**Previous Chapter:** [Syntax](03-SYNTAX.md)
**Next Chapter:** [Control Flow](05-CONTROL_FLOW.md)

---


# Chapter 5: Control Flow

**Whisker Language Specification 1.0**

---

## 5.1 Overview

Control flow determines which content is displayed based on conditions and story state. WLS provides conditional blocks, inline conditionals, and text alternatives for dynamic content generation.

Control flow mechanisms:

| Mechanism | Purpose | Syntax |
|-----------|---------|--------|
| Block conditionals | Show/hide content blocks | `{ cond }...{/}` |
| Inline conditionals | Vary text inline | `{cond: a \| b}` |
| Text alternatives | Dynamic text variations | `{\| a \| b}` |

## 5.2 Block Conditionals

### 5.2.1 Basic Syntax

Block conditionals show or hide content based on a condition:

```whisker
{ condition }
  Content shown when condition is true.
{/}
```

**Components:**

| Component | Description |
|-----------|-------------|
| `{ condition }` | Opening with expression |
| Content | Lines to display if true |
| `{/}` | Closing marker |

**Example:**

```whisker
:: Inventory
{ $hasKey }
  You have a rusty key in your pocket.
{/}

{ $gold >= 100 }
  Your coin purse is quite heavy.
{/}
```

### 5.2.2 Else Clauses

Use `{else}` to provide alternative content when the condition is false:

```whisker
{ condition }
  Content when true.
{else}
  Content when false.
{/}
```

**Example:**

```whisker
:: DoorCheck
{ $hasKey }
  You unlock the door and step through.
{else}
  The door is locked. You need a key.
{/}
```

### 5.2.3 Elif Clauses

Use `{elif condition}` for multiple condition branches:

```whisker
{ condition1 }
  First option.
{elif condition2}
  Second option.
{elif condition3}
  Third option.
{else}
  Default option.
{/}
```

**Evaluation Rules:**

1. Conditions are evaluated top-to-bottom
2. First true condition's content is displayed
3. Remaining conditions are NOT evaluated
4. `{else}` executes only if all conditions are false
5. `{else}` is optional

**Example:**

```whisker
:: HealthCheck
{ $health > 75 }
  You feel strong and ready for anything.
{elif $health > 50}
  You're in decent shape, but could be better.
{elif $health > 25}
  Your wounds slow you down considerably.
{else}
  You can barely stand. Death feels near.
{/}
```

### 5.2.4 Nested Conditionals

Conditionals can nest to any depth:

```whisker
{ $inCave }
  The cave is dark and damp.

  { $hasTorch }
    Your torch illuminates strange markings on the wall.

    { $canReadAncient }
      The text warns of a guardian below.
    {else}
      The symbols mean nothing to you.
    {/}
  {else}
    You can barely see your hand in front of your face.
  {/}
{/}
```

**Nesting Rules:**

| Rule | Description |
|------|-------------|
| Depth | No limit on nesting depth |
| Matching | Each `{/}` closes nearest open block |
| Indentation | Aesthetic only, not semantic |
| Scope | Variables accessible at any depth |

### 5.2.5 Condition Expressions

Conditions use Whisker expressions (see Chapter 3):

```whisker
// Comparison operators
{ $gold >= 100 }
{ $name == "Hero" }
{ $level ~= 1 }

// Logical operators
{ $hasKey and $hasTorch }
{ $gold >= 50 or $hasDiscount }
{ not $isLocked }

// Complex expressions
{ ($gold >= 50 and $hasPermit) or $isVIP }
{ whisker.visited("Cave") > 0 }

// Truthiness (implicit boolean conversion)
{ $gold }           // True if non-zero
{ $playerName }     // True if non-empty string
{ $hasKey }         // True if true
```

### 5.2.6 Whitespace Handling

Whitespace within conditional blocks follows these rules:

| Context | Behavior |
|---------|----------|
| Leading whitespace | Preserved (for indentation) |
| Trailing whitespace | Trimmed from each line |
| Blank lines | Preserved within content |
| Around markers | Flexible |

**Example:**

```whisker
{ $verbose }
  This text preserves its leading spaces.

  Blank lines are kept.
{/}
```

**Output (when true):**
```
  This text preserves its leading spaces.

  Blank lines are kept.
```

### 5.2.7 Empty Blocks

Empty conditional blocks are valid but have no effect:

```whisker
{ $condition }
{/}

// Equivalent to no output when true
```

## 5.3 Inline Conditionals

### 5.3.1 Basic Syntax

Inline conditionals vary text within a line:

```whisker
The door is {$hasKey: unlocked | locked}.
```

**Syntax:**

```
{condition: trueText | falseText}
```

**Components:**

| Component | Required | Description |
|-----------|----------|-------------|
| `condition` | Yes | Expression to evaluate |
| `:` | Yes | Separator after condition |
| `trueText` | Yes | Text when condition is true |
| `\|` | Yes | Separator between options |
| `falseText` | Yes | Text when condition is false |

### 5.3.2 Examples

```whisker
// Simple boolean
You {$hasKey: have | need} a key.

// Comparison
You have {$gold >= 100: enough | insufficient} gold.

// Pluralization
You have $gold gold {$gold == 1: piece | pieces}.

// Complex condition
The guard {$gold >= 50 or $hasPass: waves you through | blocks your path}.

// Variable interpolation inside
You see {$isDay: the bright sun | $moonPhase}.
```

### 5.3.3 Restrictions

Inline conditionals have limitations compared to block conditionals:

| Feature | Block | Inline |
|---------|-------|--------|
| Nesting | Yes | No |
| Multi-line content | Yes | No |
| Multiple elif | Yes | No |
| Variable assignment | Yes | No |

**Invalid (nesting):**

```whisker
// INVALID: Cannot nest inline conditionals
{$a: {$b: x | y} | z}
```

**Use block form instead:**

```whisker
// VALID: Use block for complex logic
{ $a }
  { $b }
    x
  {else}
    y
  {/}
{else}
  z
{/}
```

### 5.3.4 Escaping in Inline Conditionals

Use backslash to include literal characters:

```whisker
// Literal pipe
{$choice: Option A \| more | Option B}

// Literal colon
{$time: 12\:00 PM | midnight}

// Literal braces
{$show: \{braces\} | none}
```

## 5.4 Text Alternatives

### 5.4.1 Overview

Text alternatives provide dynamic text that changes based on visit count or randomization. They are essential for creating variety in repeated content.

| Type | Prefix | Behavior |
|------|--------|----------|
| Sequence | (none) | Shows items in order, stops at last |
| Cycle | `&` | Shows items in order, loops forever |
| Shuffle | `~` | Random selection each time |
| Once-only | `!` | Each item shown once, then empty |

### 5.4.2 Sequence Alternatives

Sequences show options in order and stop at the last:

```whisker
{| First | Second | Third | Final }
```

**Behavior by visit:**

| Visit | Output |
|-------|--------|
| 1 | "First" |
| 2 | "Second" |
| 3 | "Third" |
| 4+ | "Final" |

**Example:**

```whisker
:: OldMan
{| "Ah, a visitor!" | "Back again?" | "You're persistent." | "What now?" }
the old man says.

+ [Ask about the cave] -> CaveInfo
+ [Leave] -> Village
```

### 5.4.3 Cycle Alternatives

Cycles loop through options forever:

```whisker
{&| Red | Green | Blue }
```

**Behavior by visit:**

| Visit | Output |
|-------|--------|
| 1 | "Red" |
| 2 | "Green" |
| 3 | "Blue" |
| 4 | "Red" |
| 5 | "Green" |
| ... | (continues) |

**Example:**

```whisker
:: WeatherReport
The sky is {&| clear | cloudy | overcast | partly cloudy }.
The wind blows from the {&| north | east | south | west }.
```

### 5.4.4 Shuffle Alternatives

Shuffles select randomly each time:

```whisker
{~| Option A | Option B | Option C }
```

**Behavior:**
- Each evaluation selects one option randomly
- All options have equal probability
- Same option may repeat consecutively
- Selection is independent of previous choices

**Example:**

```whisker
:: Forest
You notice {~| a squirrel | a rabbit | a deer | nothing } in the underbrush.
The trees sway {~| gently | wildly | barely } in the breeze.
```

### 5.4.5 Once-Only Alternatives

Once-only alternatives show each option exactly once, then produce nothing:

```whisker
{!| First time. | Second time. | Last time. }
```

**Behavior by visit:**

| Visit | Output |
|-------|--------|
| 1 | "First time." |
| 2 | "Second time." |
| 3 | "Last time." |
| 4+ | "" (empty) |

**Example:**

```whisker
:: Hints
{!| Hint: Check behind the painting. | Hint: The key is brass. | Hint: Listen for the click. }

The puzzle awaits your solution.
```

### 5.4.6 Alternative Syntax Details

**Complete syntax:**

```
{[prefix]| option1 | option2 | ... | optionN }
```

**Parsing rules:**

| Rule | Description |
|------|-------------|
| Opening | `{`, optional prefix, `\|` |
| Options | Separated by ` \| ` (space-pipe-space) |
| Closing | `}` |
| Whitespace | Trimmed from each option |
| Empty options | Valid, produce empty string |

**Examples:**

```whisker
// Minimum (two options)
{| a | b }

// With empty option
{| something |  }    // Second option is empty

// Multiple options
{~| one | two | three | four | five }

// Multiword options
{| the quick fox | a lazy dog | some random text }
```

#### 5.4.6.1 Alternative Edge Cases

| Scenario | Input | Behavior | Notes |
|----------|-------|----------|-------|
| Single option | `{| only }` | Error WLS-SYN-030 | Minimum 2 options required |
| All empty | `{| | }` | Valid | Outputs empty string |
| Trailing pipe | `{| a | b | }` | Valid | Third option is empty |
| Leading pipe | `{| | a | b }` | Valid | First option is empty |
| Whitespace only | `{|   |   }` | Valid | All options trim to empty |
| No space around pipe | `{|a|b}` | Valid | Parsed correctly |
| Nested braces | `{| {a} | b }` | Parsed as expression | `{a}` evaluates first |
| Pipe in string | `{| "a\|b" | c }` | Valid | Escaped pipe is literal |
| Unmatched quotes | `{| "abc | def }` | Error WLS-SYN-031 | Unterminated string |
| Very many options | `{| a | b | ... }` (1000+) | Valid | No limit, but perf warning |

**Exhausted Alternatives:**

| Type | When Exhausted | Behavior |
|------|----------------|----------|
| Sequence `{|}` | All visited | Repeat last option forever |
| Cycle `{&|}` | Never | Loops back to first |
| Shuffle `{~|}` | All visited | Reshuffle and restart |
| Once `{!|}` | All visited | Output empty string |

**Nested Alternatives:**

```whisker
// Valid: alternatives can contain expressions
{| {$name} says hello | {$other} waves }

// Valid but not recommended: alternatives inside alternatives
{| Option A with {| sub1 | sub2 } | Option B }
```

Nested alternatives have independent state tracking. The outer alternative increments once per visit; the inner alternative increments only when its branch is selected.

### 5.4.7 Tracking State

Alternative state is tracked per passage and per alternative:

```whisker
:: Room
{| First | Second | Third }     // Alternative A
{| Red | Blue | Green }          // Alternative B
```

- Alternative A tracks its own visit count
- Alternative B tracks its own visit count separately
- Both reset if the story restarts

**Implementation Note:** Implementations track alternatives by their position within each passage. Moving alternatives may reset their state.

### 5.4.8 Named Alternatives

Alternatives may be named for stable state tracking across story edits.

**Motivation:**

By default, alternative state is tracked by position (index 0, 1, 2, etc.). This means reordering alternatives resets their state. Named alternatives solve this.

**Syntax:**

```whisker
{| name=greeting "Hello!" | "Back again?" | "Welcome back!" }
{&| name=weather "sunny" | "cloudy" | "rainy" }
{~| name=reactions "smile" | "frown" | "laugh" }
```

**Behavior Comparison:**

| Feature | Unnamed | Named |
|---------|---------|-------|
| State tracking | By position | By name |
| Reordering | Resets state | Preserves state |
| Save format | `"Passage:0"` | `"Passage:greeting"` |

**Example:**

```whisker
:: OldMan
The old man says, {| name=greeting "Hello!" | "You again?" | "Welcome back!" }
```

Reordering options preserves the visit count for "greeting".

**Accessing State in Lua:**

```lua
-- Get visit count for named alternative
local count = whisker.alternative.visits("OldMan", "greeting")

-- Reset named alternative
whisker.alternative.reset("OldMan", "greeting")
```

**Error Handling:**

| Scenario | Behavior |
|----------|----------|
| Duplicate name in same passage | Warning WLS-FLW-015 |
| Invalid name (not identifier) | Error WLS-SYN-018 |
| Accessing undefined name in Lua | Returns 0 visits |

### 5.4.9 Alternatives in Choice Text

Alternatives can appear in choice text:

```whisker
:: Shop
* [{~| Browse | Look around | Check out } the wares] -> Browse
* [Talk to the {&| friendly | grumpy | distracted } merchant] -> Talk
+ [{| Buy the rare item | (Already purchased) }] -> BuyRare
```

### 5.4.10 Combining Alternatives

Multiple alternatives can appear in the same line:

```whisker
The {~| tall | short | mysterious } stranger wore a {~| red | blue | black } coat.
```

Each alternative is evaluated independently.

## 5.5 Evaluation Order

### 5.5.1 Content Processing Order

Content within a passage is processed in document order:

1. **Variable assignments** execute first
2. **Block conditionals** evaluate and include/exclude content
3. **Inline conditionals** resolve within lines
4. **Alternatives** select their current value
5. **Variable interpolation** substitutes values
6. **Final output** is produced

**Example:**

```whisker
:: Example
$count = 5                           // 1. Assignment
{ $count > 0 }                       // 2. Block evaluates (true)
  Count is {$count > 3: high | low}  // 3. Inline evaluates ("high")
  Status: {| First | Second }        // 4. Alternative ("First" on first visit)
  Value: $count                      // 5. Interpolation ("5")
{/}
```

### 5.5.2 Short-Circuit Evaluation

Logical operators use short-circuit evaluation:

```whisker
// $b only evaluated if $a is true
{ $a and $b }
  Both are true.
{/}

// $b only evaluated if $a is false
{ $a or $b }
  At least one is true.
{/}
```

**Benefits:**
- Prevents errors from undefined variables
- Enables guard patterns
- Improves performance

**Example (guard pattern):**

```whisker
// Safe: $gold only accessed if $hasWallet is true
{ $hasWallet and $gold >= 100 }
  You can afford it.
{/}
```

### 5.5.3 Conditional Content and Variables

Variables assigned within conditionals follow scoping rules:

```whisker
:: Conditional Assignment
{ $isRich }
  $status = "wealthy"
{else}
  $status = "modest"
{/}

Your status: $status    // Always defined (one branch executed)
```

**Warning:** Assigning variables only in one branch may leave them undefined:

```whisker
// CAUTION: $bonus undefined if condition is false
{ $level > 10 }
  $bonus = 50
{/}
$total = $base + $bonus    // Error if $level <= 10
```

**Better approach:**

```whisker
$bonus = 0                  // Default value
{ $level > 10 }
  $bonus = 50
{/}
$total = $base + $bonus    // Always works
```

## 5.6 Complex Patterns

### 5.6.1 Conditional Choices

Combine conditionals with choices:

```whisker
:: Shop
Welcome to the shop!

{ $gold >= 100 }
  The premium items are available to you.
{/}

+ { $gold >= 50 } [Buy sword ($50)] { $gold -= 50 } -> BuySword
+ { $gold >= 100 } [Buy armor ($100)] { $gold -= 100 } -> BuyArmor
* [Just looking] -> Browse
+ [Leave] -> Exit
```

### 5.6.2 Dynamic Descriptions

Combine alternatives with conditionals:

```whisker
:: Tavern
The tavern is {~| busy | quiet | moderately full } tonight.

{ whisker.visited("Tavern") == 1 }
  {| You've never been here before. | You remember this place. }
{/}

The bartender {$metBartender: nods in recognition | eyes you suspiciously}.
```

### 5.6.3 Progressive Revelation

Use once-only alternatives for gradual information:

```whisker
:: AncientLibrary
The library holds countless secrets.

{!| You notice the books are arranged by color, not subject. }
{!| A hidden compartment reveals itself in one shelf. }
{!| Ancient runes glow faintly on the ceiling. }

What would you like to examine?

* [Search the shelves] -> SearchShelves
+ [Leave] -> Exit
```

### 5.6.4 State-Based Narratives

Build complex state-dependent narratives:

```whisker
:: ThroneRoom
{ $allegiance == "king" }
  The king smiles warmly as you approach.
  { $completedQuest }
    "You have served me well," he says.
  {else}
    "Have you completed your task?"
  {/}
{elif $allegiance == "rebels"}
  Guards immediately surround you.
  { $hasDisguise }
    But your disguise holds. They let you pass.
  {else}
    "Seize the traitor!" someone shouts.
  {/}
{else}
  The king regards you with curiosity.
  "A new face. State your business."
{/}
```

## 5.7 Error Conditions

### 5.7.1 Control Flow Errors

| Error | Cause | Example |
|-------|-------|---------|
| Unclosed block | Missing `{/}` | `{ $x }...` (no close) |
| Orphan close | `{/}` without open | `{/}` alone |
| Orphan else | `{else}` without block | `{else} text {/}` |
| Invalid condition | Syntax error in expression | `{ $x == }` |
| Mismatched nesting | Wrong close order | Interleaved blocks |

### 5.7.2 Error Examples

**Unclosed block:**

```whisker
// INVALID: Missing {/}
{ $hasKey }
  You have the key.

:: NextPassage
```

> **Error:** Unclosed conditional block at line 2. Expected `{/}` before passage declaration.

**Invalid inline:**

```whisker
// INVALID: Missing false option
The door is {$hasKey: open}.
```

> **Error:** Inline conditional missing false option. Expected `| falseText}`.

### 5.7.3 Error Recovery

Implementations SHOULD:

1. Report the specific error type
2. Include line and column numbers
3. Continue parsing when possible
4. Suggest corrections

## 5.8 Implementation Notes

### 5.8.1 Parsing Considerations

Block conditionals can be parsed as:

```
conditional_block = "{" , expression , "}" ,
                    content ,
                    { elif_clause } ,
                    [ else_clause ] ,
                    "{/}" ;

elif_clause = "{elif" , expression , "}" , content ;
else_clause = "{else}" , content ;
```

### 5.8.2 Alternative State Storage

Implementations MUST track:

| Data | Per | Purpose |
|------|-----|---------|
| Visit count | Alternative instance | Sequence/cycle position |
| Used indices | Once-only alternative | Track shown options |
| Random seed | Optional | Reproducible shuffles |

### 5.8.3 Performance Considerations

- Cache condition evaluation results when expressions are pure
- Avoid re-evaluating alternatives on back navigation
- Consider lazy evaluation for complex conditionals
- Pre-compile expressions for repeated evaluation

### 5.8.4 Testing Requirements

Implementations MUST correctly handle:

- Deeply nested conditionals (at least 10 levels)
- Adjacent alternatives on same line
- Empty conditional branches
- All alternative types at boundary conditions
- Short-circuit evaluation

## 5.9 Gather Points

### 5.9.1 Overview

Gather points provide a way to reconverge flow after branching choices within a single passage. They reduce passage explosion by allowing multiple choice branches to continue to common content without requiring separate passages.

**Syntax:**

```whisker
- Content after gather point
```

The gather marker (`-`) at the start of a line marks a gather point. All choices above the gather point reconverge at this line.

### 5.9.2 Basic Usage

```whisker
:: Conversation
"What do you think of the proposal?"

+ [Agree]
  "I'm glad you see it my way," she says with a smile.
+ [Disagree]
  "That's... disappointing," she says with a frown.
+ [Stay silent]
  She waits expectantly, then sighs.

- "Either way, we should discuss the details."

+ [Continue] -> Details
+ [Leave] -> Exit
```

**Behavior:**
1. Player selects one of the three choices
2. The corresponding response is displayed
3. Flow continues to the gather point
4. "Either way, we should discuss the details." is displayed
5. New choices are presented

### 5.9.3 Multiple Gather Points

A passage can contain multiple gather points:

```whisker
:: Interview
"First question: What's your greatest strength?"

+ [Leadership]
  "Excellent quality for this role."
+ [Technical skills]
  "We value expertise."

- "Second question: Why do you want this job?"

+ [Growth opportunity]
  "That's a mature perspective."
+ [Compensation]
  She raises an eyebrow but nods.

- "Thank you for your time."
-> Exit
```

### 5.9.4 Nested Choices and Gathers

Gather points work with nested choice structures:

```whisker
:: Negotiation
"Let's discuss the price."

+ [Make an offer]
  "I'll give you $50."

  + + [Accept]
    "Deal!" he says.
  + + [Counter]
    "How about $40?"

  - - The merchant considers.

+ [Walk away]
  "Wait, wait!" he calls after you.

- The deal concludes one way or another.
```

**Nesting rules:**
- Gather depth matches choice depth (same number of markers)
- `- -` gathers nested choices (`+ +`)
- Single `-` gathers top-level choices

### 5.9.5 Gather Point Restrictions

| Restriction | Description |
|-------------|-------------|
| Line start | Must appear at beginning of line (after optional indent) |
| After choices | Must follow at least one choice |
| Same passage | Cannot gather across passages |
| Depth matching | Gather depth must match choice depth |

**Invalid examples:**

```whisker
// INVALID: Gather without preceding choices
:: Example
Some text.
- This is invalid.

// INVALID: Mismatched depth
+ [Choice]
  Content.
- - Wrong depth (should be single -)
```

## 5.10 Tunnels

### 5.10.1 Overview

Tunnels enable reusable passages that return to the caller. They function like subroutines, allowing common content sequences to be defined once and called from multiple locations.

**Tunnel call syntax:**
```whisker
-> PassageName ->
```

**Tunnel return syntax:**
```whisker
<-
```

### 5.10.2 Basic Usage

```whisker
:: Morning
You wake up and stretch.
-> BrushTeeth ->
-> GetDressed ->
Ready for the day!
+ [Go to work] -> Work
+ [Stay home] -> Home

:: BrushTeeth
You brush your teeth thoroughly.
<-

:: GetDressed
You put on your favorite outfit.
<-
```

**Execution flow:**
1. "You wake up and stretch." displays
2. Engine pushes return location to call stack
3. BrushTeeth passage executes
4. `<-` pops stack and returns to Morning
5. GetDressed passage executes
6. `<-` returns to Morning
7. "Ready for the day!" displays
8. Choices are presented

### 5.10.3 Tunnels with Choices

Tunnels can contain choices that don't exit the tunnel:

```whisker
:: Shop
Welcome to the shop!
-> BrowseItems ->
Come back anytime!
-> Exit

:: BrowseItems
"What interests you?"
+ [Weapons]
  You examine the sword display.
+ [Armor]
  The armor gleams invitingly.
+ [Potions]
  Colorful bottles line the shelves.
- "Let me know if you need help."
<-
```

### 5.10.4 Nested Tunnels

Tunnels can call other tunnels:

```whisker
:: MainQuest
You embark on your journey.
-> TravelSequence ->
You arrive at your destination.

:: TravelSequence
-> PackSupplies ->
-> MountHorse ->
You ride through the countryside.
<-

:: PackSupplies
You gather your supplies.
<-

:: MountHorse
You mount your trusty steed.
<-
```

**Call stack depth:**
- Implementations MUST support at least 100 levels of nesting
- Stack overflow SHOULD produce a clear error message

### 5.10.5 Conditional Returns

Tunnels can have multiple return points:

```whisker
:: GuardCheck
The guard examines you.
{ $hasPass }
  "Everything seems in order."
  <-
{/}
{ $bribeAmount >= 50 }
  "Well, I suppose I can look the other way."
  $gold -= $bribeAmount
  <-
{/}
"You cannot pass!"
-> Prison
```

**Note:** If a tunnel navigates to another passage without returning (`-> Prison` above), the call stack is NOT unwound. The tunnel becomes a normal navigation.

### 5.10.6 Tunnel with Parameters

While WLS doesn't have formal parameters, you can use temporary variables:

```whisker
:: Combat
$_enemy = "Goblin"
$_enemyHealth = 30
-> BattleSequence ->
"Victory! The $_enemy is defeated."

:: BattleSequence
"You face the $_enemy!"
{ $_enemyHealth > 0 }
  + [Attack]
    $_enemyHealth -= 10
    { $_enemyHealth > 0 }
      "The $_enemy staggers but fights on."
    {else}
      "The $_enemy falls!"
    {/}
  + [Flee]
    "You attempt to escape..."
    <- // Return early
{/}
- <-
```

### 5.10.7 Error Conditions

| Error Code | Name | Description |
|------------|------|-------------|
| WLS-FLW-009 | tunnel_target_not_found | Tunnel call to undefined passage |
| WLS-FLW-010 | missing_tunnel_return | Tunnel passage has no `<-` |
| WLS-FLW-011 | orphan_tunnel_return | `<-` outside of tunnel context |

**Example errors:**

```whisker
// WLS-FLW-009: Tunnel target not found
-> NonExistent ->

// WLS-FLW-010: Missing tunnel return (warning)
:: MyTunnel
Some content but no <- to return.

// WLS-FLW-011: Orphan tunnel return
:: Start
<-  // Error: not called as tunnel
```

### 5.10.8 Tunnel State and Save/Load

When saving game state, implementations MUST preserve:

| State | Description |
|-------|-------------|
| Call stack | Current tunnel call chain |
| Return positions | Where to continue after `<-` |
| Local variables | Temporary variables in scope |

**Example state structure:**
```json
{
  "tunnel_stack": [
    { "passage": "Morning", "position": 3 },
    { "passage": "TravelSequence", "position": 2 }
  ]
}
```

## 5.11 Advanced Flow Patterns

### 5.11.1 Hub with Tunnels

Combine tunnels with a hub passage for exploration:

```whisker
:: TownSquare
You stand in the town square.

+ [Visit blacksmith] -> Blacksmith ->
+ [Visit tavern] -> Tavern ->
+ [Visit market] -> Market ->
+ [Leave town] -> Road

// After returning from any tunnel, choices are available again
```

### 5.11.2 Gather with Conditional Branches

```whisker
:: Encounter
A stranger approaches.

+ [Greet warmly]
  $friendliness += 1
  "Hello, friend!"
+ [Nod curtly]
  "Hmph," the stranger mutters.
+ [Ignore]
  $friendliness -= 1
  They seem offended.

- { $friendliness > 0 }
  "Perhaps we could travel together?"
  + [Accept] -> TravelTogether
{else}
  They pass by without another word.
{/}
-> Continue
```

## 5.12 Error Codes Summary

| Code | Name | Severity | Description |
|------|------|----------|-------------|
| WLS-FLW-001 | dead_end | warning | Passage has no exits |
| WLS-FLW-002 | unreachable_code | warning | Code after unconditional navigation |
| WLS-FLW-003 | cycle_detected | info | Flow cycle in story |
| WLS-FLW-004 | infinite_loop | error | Guaranteed infinite loop |
| WLS-FLW-005 | unclosed_conditional | error | Missing `{/}` |
| WLS-FLW-006 | orphan_else | error | `{else}` without conditional |
| WLS-FLW-007 | invalid_gather_placement | error | Gather without preceding choices |
| WLS-FLW-008 | unreachable_gather | warning | Gather can never be reached |
| WLS-FLW-009 | tunnel_target_not_found | error | Tunnel to undefined passage |
| WLS-FLW-010 | missing_tunnel_return | warning | Tunnel has no `<-` |
| WLS-FLW-011 | orphan_tunnel_return | error | `<-` outside tunnel context |

---

**Previous Chapter:** [Variables](04-VARIABLES.md)
**Next Chapter:** [Choices](06-CHOICES.md)

---


# Chapter 6: Choices

**Whisker Language Specification 1.0**

---

## 6.1 Overview

Choices are the primary mechanism for player interaction in Whisker stories. A choice presents the player with options, each leading to a different passage or outcome.

WLS provides:

| Feature | Description |
|---------|-------------|
| Once-only choices | Disappear after selection |
| Sticky choices | Remain available |
| Conditional choices | Show based on conditions |
| Choice actions | Execute code on selection |
| Fallback behavior | Handle exhausted choices |

## 6.2 Basic Choice Syntax

### 6.2.1 Simple Choices

A basic choice uses the `+` marker:

```whisker
:: Start
You stand at a crossroads.

+ [Go north] -> NorthPath
+ [Go south] -> SouthPath
+ [Go east] -> EastPath
```

**Components:**

| Component | Symbol | Required | Description |
|-----------|--------|----------|-------------|
| Marker | `+` or `*` | Yes | Choice type |
| Text | `[...]` | Yes | Displayed text |
| Arrow | `->` | Yes | Navigation indicator |
| Target | passage name | Yes | Destination passage |

### 6.2.2 Choice Text

Choice text appears within square brackets:

```whisker
+ [This text is shown to the player] -> Target
```

**Text rules:**

| Rule | Description |
|------|-------------|
| Content | Any text except unescaped `]` |
| Interpolation | Variables allowed: `[$name's choice]` |
| Escaping | Use `\]` for literal bracket |
| Length | No limit (implementation may truncate display) |

**Examples:**

```whisker
+ [Simple text] -> Target
+ [You have $gold gold. Spend some?] -> Shop
+ [Say "Hello, $npcName\!"] -> Greeting
+ [Option with \[brackets\]] -> Special
```

### 6.2.3 Navigation Targets

The arrow `->` points to the destination passage:

```whisker
+ [Go to the castle] -> Castle
+ [Enter the forest] -> DarkForest
+ [Return home] -> PlayerHome
```

**Target rules:**

| Rule | Description |
|------|-------------|
| Name | Must be valid passage identifier |
| Existence | Target passage MUST exist |
| Case | Case-sensitive matching |
| Self-reference | May target current passage |

**Special targets:**

| Target | Behavior |
|--------|----------|
| `-> END` | Ends the story |
| `-> BACK` | Returns to previous passage |
| `-> RESTART` | Restarts the story |

```whisker
:: GameOver
You have died.

+ [Try again] -> RESTART
+ [Quit] -> END
```

## 6.3 Choice Types

### 6.3.1 Once-Only Choices (`+`)

Once-only choices disappear after selection:

```whisker
:: TreasureRoom
You see a chest and a door.

+ [Open the chest] -> OpenChest      // Gone after selection
+ [Go through the door] -> NextRoom  // Gone after selection
```

**Behavior:**
- Visible until selected
- Hidden permanently after selection (within session)
- State persists across passage visits
- Restored on story restart

**Use cases:**
- One-time events
- Consumable resources
- Irreversible decisions
- Story progression

### 6.3.2 Sticky Choices (`*`)

Sticky choices remain available after selection:

```whisker
:: Library
The library is full of books.

* [Search the shelves] -> SearchShelves  // Always available
* [Read a random book] -> RandomBook     // Always available
+ [Leave the library] -> Exit            // Once-only
```

**Behavior:**
- Always visible (unless conditionally hidden)
- Can be selected multiple times
- Useful for repeatable actions

**Use cases:**
- Examining objects
- Asking questions
- Repeatable actions
- Navigation options

### 6.3.3 Comparison

| Feature | Once-Only (`+`) | Sticky (`*`) |
|---------|-----------------|--------------|
| After selection | Hidden | Visible |
| Repeat selection | No | Yes |
| Typical use | Events, decisions | Examination, navigation |
| State tracking | Yes | No |

## 6.4 Conditional Choices

### 6.4.1 Basic Conditions

Add a condition before the choice text:

```whisker
+ { condition } [Choice text] -> Target
```

The choice is only visible when the condition is true:

```whisker
:: Shop
Welcome to the armory!

+ { $gold >= 50 } [Buy sword ($50)] -> BuySword
+ { $gold >= 100 } [Buy armor ($100)] -> BuyArmor
+ { $hasVoucher } [Redeem voucher] -> RedeemVoucher
* [Just looking] -> Browse
+ [Leave] -> Exit
```

### 6.4.2 Condition Expressions

Conditions use standard Whisker expressions:

```whisker
// Comparison
+ { $level >= 10 } [Enter expert dungeon] -> ExpertDungeon

// Logical operators
+ { $hasKey and $hasTorch } [Enter dark cave] -> DarkCave

// Negation
+ { not $hasVisited } [Explore the ruins] -> Ruins

// Complex expressions
+ { ($gold >= 100 or $hasDiscount) and not $isBanned } [VIP entrance] -> VIPRoom

// Function calls
+ { whisker.visited("Cave") == 0 } [Discover the cave] -> Cave
```

### 6.4.3 Condition vs. Once-Only

Conditions and once-only behavior are independent:

| Scenario | Marker | Condition | Result |
|----------|--------|-----------|--------|
| Always visible, once | `+` | none | Shows until selected |
| Always visible, repeatable | `*` | none | Always shows |
| Conditional, once | `+` | `{ cond }` | Shows if true AND not selected |
| Conditional, repeatable | `*` | `{ cond }` | Shows if true |

**Example:**

```whisker
:: Shop
// Only shows if can afford AND hasn't bought
+ { $gold >= 50 } [Buy the unique sword] -> BuySword

// Shows whenever you can afford
* { $gold >= 10 } [Buy healing potion] -> BuyPotion
```

### 6.4.4 Dynamic Visibility

Choice visibility updates when the passage is displayed:

```whisker
:: Shop
$gold = 100

+ [Spend 60 gold] { $gold -= 60 } -> Spent60
// After selecting above, $gold = 40
// The choice below becomes hidden on revisit

+ { $gold >= 50 } [Buy expensive item] -> BuyExpensive
```

## 6.5 Choice Actions

### 6.5.1 Action Syntax

Execute code when a choice is selected:

```whisker
+ [Choice text] { action } -> Target
```

The action block executes AFTER selection but BEFORE navigation:

```whisker
+ [Buy sword ($50)] { $gold -= 50 } -> Inventory
+ [Take the gem] { $hasGem = true } -> Exit
+ [Attack] { $enemyHealth -= 10 } -> Combat
```

### 6.5.2 Action Contents

Actions can contain:

| Content | Example |
|---------|---------|
| Variable assignment | `{ $gold = 100 }` |
| Compound assignment | `{ $health -= 10 }` |
| Multiple statements | `{ $gold -= 50; $hasSword = true }` |
| Lua code | `{ whisker.state.set("items", 5) }` |

**Examples:**

```whisker
// Single assignment
+ [Pick up gold] { $gold += 25 } -> Continue

// Multiple assignments
+ [Buy equipment] { $gold -= 100; $hasArmor = true; $defense += 5 } -> Shop

// Complex logic via Lua
+ [Roll dice] { $roll = whisker.random(1, 6) } -> RollResult
```

### 6.5.3 Action Execution Order

When a choice is selected:

```
1. Player clicks/selects choice
2. Choice action executes (if any)
3. Current passage's @onExit executes (if any)
4. Navigation occurs
5. Target passage's @onEnter executes (if any)
6. Target passage renders
```

**Example:**

```whisker
:: Room1
@onExit: $exitCount += 1

+ [Go to Room2] { $transitionType = "choice" } -> Room2

:: Room2
@onEnter: $enterCount += 1

You arrived via $transitionType.
// exitCount and enterCount both incremented
```

### 6.5.4 Actions and Conditions Combined

The full choice syntax:

```whisker
marker { condition } [text] { action } -> target
```

**Order matters:**
1. Condition comes BEFORE text
2. Action comes AFTER text

```whisker
// Correct order
+ { $gold >= 50 } [Buy sword ($50)] { $gold -= 50 } -> Inventory

// Components:
// +                    - once-only marker
// { $gold >= 50 }      - condition (visibility)
// [Buy sword ($50)]    - display text
// { $gold -= 50 }      - action (on selection)
// -> Inventory         - navigation target
```

## 6.6 Choice Presentation

### 6.6.1 Choice Order

Choices are presented in document order:

```whisker
:: Room
+ [First choice] -> A    // Displayed first
+ [Second choice] -> B   // Displayed second
+ [Third choice] -> C    // Displayed third
```

Hidden choices do not affect order of visible choices.

### 6.6.2 Choice Grouping

Choices MUST appear consecutively at the end of passage content:

```whisker
:: ValidPassage
This is narrative content.
More narrative here.

+ [Choice 1] -> A
+ [Choice 2] -> B
* [Choice 3] -> C
```

**Invalid:**

```whisker
:: InvalidPassage
Some text.
+ [Choice 1] -> A
More text here.          // ERROR: Content after choices
+ [Choice 2] -> B
```

### 6.6.3 No Choices

A passage MAY have no choices:

```whisker
:: Ending
The story concludes here.
Thank you for playing.

// No choices - story ends or requires programmatic navigation
```

Implementations SHOULD handle this gracefully (see Section 6.8).

## 6.7 Advanced Patterns

### 6.7.1 Exhaustible Choice Sets

Combine once-only choices with a sticky fallback:

```whisker
:: Investigation
You examine the crime scene.

+ [Check the window] -> CheckWindow
+ [Look under the bed] -> CheckBed
+ [Examine the desk] -> CheckDesk
* [Done investigating] -> LeaveScene
```

As once-only choices are selected, they disappear. The sticky choice remains.

### 6.7.2 Resource-Gated Choices

Use conditions to gate choices by resources:

```whisker
:: Shop
Your gold: $gold

+ { $gold >= 100 } [Buy legendary sword ($100)] { $gold -= 100 } -> BuyLegendary
+ { $gold >= 50 } [Buy steel sword ($50)] { $gold -= 50 } -> BuySteel
+ { $gold >= 10 } [Buy wooden sword ($10)] { $gold -= 10 } -> BuyWood
* { $gold < 10 } [You can't afford anything] -> BrowseOnly
+ [Leave shop] -> Exit
```

### 6.7.3 State-Dependent Choices

Show different choices based on story state:

```whisker
:: ThroneRoom
You stand before the king.

{ $allegiance == "loyal" }
  + [Kneel and pledge fealty] -> PledgeFealty
  + [Report on your mission] -> MissionReport
{/}

{ $allegiance == "rebel" }
  + [Draw your hidden blade] -> Assassinate
  + [Maintain your cover] -> PlayAlong
{/}

* [Observe silently] -> Observe
```

### 6.7.4 Branching Conversations

Create dialogue trees:

```whisker
:: TalkToMerchant
"Welcome, traveler! What can I help you with?"

+ { not $askedAboutPrices } [Ask about prices] { $askedAboutPrices = true } -> MerchantPrices
+ { not $askedAboutRumors } [Ask about rumors] { $askedAboutRumors = true } -> MerchantRumors
+ { $askedAboutPrices and $askedAboutRumors } [Ask about the secret] -> MerchantSecret
* [Browse wares] -> MerchantShop
+ [Goodbye] -> MarketSquare
```

### 6.7.5 Timed Revelation

Reveal choices based on visit count:

```whisker
:: MysteriousDoor
An ancient door covered in runes.

* [Examine the runes] -> ExamineRunes
+ { whisker.visited("ExamineRunes") >= 3 } [You notice a hidden switch] -> HiddenSwitch
+ [Leave] -> Hallway
```

### 6.7.6 Mutually Exclusive Paths

Create choices that lock out alternatives:

```whisker
:: Crossroads
$pathChosen = false

+ { not $pathChosen } [Take the mountain path] { $pathChosen = true; $route = "mountain" } -> MountainPath
+ { not $pathChosen } [Take the forest path] { $pathChosen = true; $route = "forest" } -> ForestPath
+ { not $pathChosen } [Take the river path] { $pathChosen = true; $route = "river" } -> RiverPath
+ { $pathChosen } [Continue on your chosen path] -> ContinueJourney
```

## 6.8 Fallback Behavior

### 6.8.1 When All Choices Are Unavailable

If all choices become hidden (conditions false or once-only exhausted), the engine MUST handle this gracefully.

**Default behavior options:**

| Option | Description |
|--------|-------------|
| Display message | "No choices available" |
| Auto-navigate | Go to designated fallback passage |
| End story | Treat as story end |

### 6.8.2 Fallback Passage

Authors can specify a fallback:

```whisker
:: Scene
@fallback: NoChoicesLeft

+ { $option1Available } [Option 1] -> Path1
+ { $option2Available } [Option 2] -> Path2

:: NoChoicesLeft
You've exhausted all options here.
+ [Return to start] -> Start
```

### 6.8.3 Ensuring Available Choices

Best practice is to always ensure at least one choice:

```whisker
:: Room
+ { $hasKey } [Unlock door] -> UnlockedDoor
+ { not $hasKey } [Search for key] -> SearchForKey
* [Wait] -> RoomWait    // Sticky fallback always available
```

## 6.9 Choice State Persistence

### 6.9.1 Session Persistence

Once-only choice state persists for the session:

| Event | Once-Only State |
|-------|-----------------|
| Select choice | Marked as used |
| Revisit passage | Remains hidden |
| Navigate back | Remains hidden |
| Story restart | Reset to available |

### 6.9.2 Save/Load Behavior

When saving and loading:

| Data | Saved |
|------|-------|
| Selected once-only choices | Yes |
| Choice conditions (via variables) | Yes |
| Visit counts | Yes |

### 6.9.3 Implementation Requirements

Implementations MUST:

1. Track which once-only choices have been selected
2. Persist this state across passage transitions
3. Include state in save data
4. Reset state on story restart

## 6.10 Error Conditions

### 6.10.1 Choice Errors

| Error | Cause | Example |
|-------|-------|---------|
| Missing target | No `->` or target | `+ [Text]` |
| Invalid target | Target passage doesn't exist | `+ [Go] -> NonExistent` |
| Invalid condition | Syntax error in condition | `+ { $x == } [Text] -> T` |
| Invalid action | Syntax error in action | `+ [Text] { $x = } -> T` |
| Missing text | No `[...]` section | `+ -> Target` |

### 6.10.2 Error Examples

**Missing target:**

```whisker
// INVALID
+ [Go somewhere]
```

> **Error:** Choice missing navigation target. Expected `-> PassageName`.

**Invalid target:**

```whisker
// INVALID (if "Dungeon" doesn't exist)
+ [Enter] -> Dungeon
```

> **Error:** Target passage "Dungeon" does not exist.

### 6.10.3 Validation

Implementations SHOULD validate at parse time:

1. All choices have targets
2. All targets reference existing passages
3. Conditions are syntactically valid
4. Actions are syntactically valid

## 6.11 Implementation Notes

### 6.11.1 Choice Data Structure

A choice can be represented as:

```
Choice {
  type: "once" | "sticky"
  condition: Expression | null
  text: string (with interpolation markers)
  action: Statement[] | null
  target: string
  selected: boolean (runtime state)
}
```

### 6.11.2 Evaluation Algorithm

When displaying choices:

```
for each choice in passage.choices:
  if choice.type == "once" and choice.selected:
    continue  // Skip selected once-only

  if choice.condition and not evaluate(choice.condition):
    continue  // Skip failed condition

  display(interpolate(choice.text))
```

### 6.11.3 Selection Algorithm

When a choice is selected:

```
function selectChoice(choice):
  if choice.action:
    execute(choice.action)

  if choice.type == "once":
    choice.selected = true

  navigate(choice.target)
```

### 6.11.4 Performance Considerations

- Cache condition evaluation when expressions are pure
- Pre-compile choice conditions
- Index once-only state by passage + choice index
- Lazy evaluation of choice text interpolation

### 6.11.5 Accessibility

Implementations SHOULD:

- Support keyboard navigation
- Provide clear focus indicators
- Allow screen reader compatibility
- Support alternative input methods

---

**Previous Chapter:** [Control Flow](05-CONTROL_FLOW.md)
**Next Chapter:** [Lua API](07-LUA_API.md)

---


# Chapter 7: Lua API

**Whisker Language Specification 1.0**

---

## 7.1 Overview

WLS uses Lua as its scripting language. The `whisker.*` API provides a unified interface for story logic, state management, and navigation.

### 7.1.1 API Namespaces

| Namespace | Purpose |
|-----------|---------|
| `whisker.state` | Variable management |
| `whisker.passage` | Passage operations |
| `whisker.history` | Navigation history |
| `whisker.choice` | Choice management |
| Top-level functions | Common utilities |

### 7.1.2 Notation Conventions

Function signatures use this format:

```
functionName(param: type, optionalParam?: type) -> returnType
```

| Symbol | Meaning |
|--------|---------|
| `?` | Optional parameter |
| `...` | Variable arguments |
| `\|` | Union type (either type) |
| `nil` | No value / nothing |

## 7.2 Embedded Lua

### 7.2.1 Inline Expressions

Use double braces for inline Lua expressions:

```whisker
$random = {{ math.random(1, 100) }}
$doubled = {{ whisker.state.get("gold") * 2 }}
```

**Rules:**
- Expression MUST return a value
- Result is assigned or interpolated
- Single expression only (no statements)

### 7.2.2 Block Scripts

Use double braces with line breaks for multi-line Lua:

```whisker
{{
  local gold = whisker.state.get("gold")
  local bonus = whisker.state.get("level") * 10
  whisker.state.set("gold", gold + bonus)
}}
```

**Rules:**
- May contain multiple statements
- Last expression value is discarded (use for side effects)
- Local variables are scoped to the block

### 7.2.3 Lifecycle Scripts

Passages can define entry and exit scripts:

```whisker
:: TreasureRoom
@onEnter: whisker.state.set("foundTreasure", true)
@onExit: whisker.state.set("gold", whisker.state.get("gold") + 100)

You found the treasure room!
```

**Execution order:**
1. `@onEnter` executes when entering passage
2. Passage content renders
3. Player selects choice
4. Choice action executes
5. `@onExit` executes when leaving passage

### 7.2.4 Expression Context

Lua expressions can appear in:

| Context | Example |
|---------|---------|
| Variable assignment | `$x = {{ expr }}` |
| Conditions | `{ {{ expr }} }` |
| Choice actions | `+ [Text] { {{ expr }} } -> Target` |
| Lifecycle scripts | `@onEnter: {{ expr }}` |

## 7.3 whisker.state

The `whisker.state` namespace manages story variables.

### 7.3.1 get

```lua
whisker.state.get(key: string) -> any | nil
```

Returns the value of a variable, or `nil` if undefined.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Variable name (without `$` prefix) |

**Returns:** The variable value, or `nil` if not set.

**Example:**

```lua
local gold = whisker.state.get("gold")
local name = whisker.state.get("playerName")

if whisker.state.get("hasKey") then
  -- player has the key
end
```

### 7.3.2 set

```lua
whisker.state.set(key: string, value: any) -> nil
```

Sets a variable value. Creates the variable if it doesn't exist.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Variable name (without `$` prefix) |
| `value` | any | Value to set (number, string, or boolean) |

**Returns:** Nothing.

**Example:**

```lua
whisker.state.set("gold", 100)
whisker.state.set("playerName", "Hero")
whisker.state.set("hasKey", true)

-- Modify existing value
local gold = whisker.state.get("gold")
whisker.state.set("gold", gold + 50)
```

### 7.3.3 has

```lua
whisker.state.has(key: string) -> boolean
```

Checks if a variable exists (has been set).

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Variable name to check |

**Returns:** `true` if variable exists, `false` otherwise.

**Example:**

```lua
if whisker.state.has("gold") then
  -- gold has been defined
else
  whisker.state.set("gold", 0)
end
```

**Note:** A variable set to `nil` is considered non-existent.

### 7.3.4 delete

```lua
whisker.state.delete(key: string) -> nil
```

Removes a variable from state.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Variable name to delete |

**Returns:** Nothing.

**Example:**

```lua
whisker.state.delete("temporaryFlag")

-- After deletion:
whisker.state.has("temporaryFlag")  -- false
whisker.state.get("temporaryFlag")  -- nil
```

### 7.3.5 all

```lua
whisker.state.all() -> table
```

Returns a table containing all story variables.

**Parameters:** None.

**Returns:** Table with variable names as keys and values as values.

**Example:**

```lua
local state = whisker.state.all()

for name, value in pairs(state) do
  print(name .. " = " .. tostring(value))
end

-- Access specific values
local gold = state.gold
local name = state.playerName
```

**Note:** The returned table is a copy. Modifying it does not affect actual state.

### 7.3.6 reset

```lua
whisker.state.reset() -> nil
```

Clears all story variables.

**Parameters:** None.

**Returns:** Nothing.

**Example:**

```lua
-- Clear all state (typically on restart)
whisker.state.reset()
```

**Warning:** This removes ALL variables. Use with caution.

## 7.4 whisker.passage

The `whisker.passage` namespace manages passages.

### 7.4.1 current

```lua
whisker.passage.current() -> Passage
```

Returns the current passage object.

**Parameters:** None.

**Returns:** Passage object (see Section 7.4.7).

**Example:**

```lua
local passage = whisker.passage.current()
print(passage.id)       -- "TreasureRoom"
print(passage.content)  -- Raw content string
```

### 7.4.2 get

```lua
whisker.passage.get(id: string) -> Passage | nil
```

Returns a passage by its identifier.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Passage identifier |

**Returns:** Passage object, or `nil` if not found.

**Example:**

```lua
local intro = whisker.passage.get("Introduction")
if intro then
  print(intro.content)
end
```

### 7.4.3 go

```lua
whisker.passage.go(id: string) -> nil
```

Navigates to a passage immediately.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Target passage identifier |

**Returns:** Nothing (navigation occurs).

**Example:**

```lua
-- Programmatic navigation
if whisker.state.get("health") <= 0 then
  whisker.passage.go("GameOver")
end
```

**Warning:** This bypasses normal choice flow. Use sparingly.

#### Mid-Render Navigation Behavior

When `whisker.passage.go()` is called during passage rendering:

| Context | Behavior |
|---------|----------|
| During content rendering | Immediately abort current render, navigate |
| During onEnter hook | Complete hook, then navigate |
| During choice action | Complete action, then navigate |
| During onExit hook | UNDEFINED - avoid this pattern |

**Execution Sequence:**

```
Passage A rendering
  → Content line 1 rendered
  → Content line 2 rendered
  → Lua block calls whisker.passage.go("B")
  → ABORT: Remaining content NOT rendered
  → ABORT: Choices NOT presented
  → onExit("A") fires
  → Navigate to B
  → onEnter("B") fires
  → B content renders normally
```

**Best Practices:**

1. Prefer choices for player-driven navigation
2. Use `go()` only for game logic (death, time limits, triggers)
3. Never call `go()` in onExit (may cause recursion)
4. State changes before `go()` ARE preserved

**Error Handling:**

| Error | Behavior |
|-------|----------|
| Non-existent passage | WLS-LNK-001, halt execution |
| Self-navigation | Allowed, restarts passage |
| During save | Navigation queued until save completes |

### 7.4.4 exists

```lua
whisker.passage.exists(id: string) -> boolean
```

Checks if a passage exists.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Passage identifier to check |

**Returns:** `true` if passage exists, `false` otherwise.

**Example:**

```lua
if whisker.passage.exists("SecretRoom") then
  -- Enable secret room choice
end
```

### 7.4.5 all

```lua
whisker.passage.all() -> table
```

Returns all passages as a table.

**Parameters:** None.

**Returns:** Table with passage IDs as keys and Passage objects as values.

**Example:**

```lua
local passages = whisker.passage.all()

for id, passage in pairs(passages) do
  print(id)
end
```

### 7.4.6 tags

```lua
whisker.passage.tags(tag: string) -> table
```

Returns all passages with a specific tag.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | Tag to search for |

**Returns:** Array of Passage objects with that tag.

**Example:**

```lua
local chapters = whisker.passage.tags("chapter")

for _, passage in ipairs(chapters) do
  print(passage.id)
end
```

### 7.4.7 Passage Object

The Passage object structure:

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique passage identifier |
| `content` | string | Raw passage content |
| `tags` | table | Array of tags |
| `metadata` | table | Metadata key-value pairs |

**Example:**

```lua
local p = whisker.passage.current()

print(p.id)              -- "Cave"
print(p.tags[1])         -- "dark"
print(p.metadata.color)  -- "#333333"
```

## 7.5 whisker.history

The `whisker.history` namespace manages navigation history.

### 7.5.1 back

```lua
whisker.history.back() -> boolean
```

Navigates to the previous passage.

**Parameters:** None.

**Returns:** `true` if navigation occurred, `false` if no history.

**Example:**

```lua
if not whisker.history.back() then
  -- No history to go back to
  whisker.passage.go("Start")
end
```

### 7.5.2 canBack

```lua
whisker.history.canBack() -> boolean
```

Checks if back navigation is possible.

**Parameters:** None.

**Returns:** `true` if history has entries, `false` otherwise.

**Example:**

```lua
-- Only show back option if possible
if whisker.history.canBack() then
  -- Enable back button
end
```

### 7.5.3 list

```lua
whisker.history.list() -> table
```

Returns the navigation history as an array.

**Parameters:** None.

**Returns:** Array of passage IDs, oldest first.

**Example:**

```lua
local history = whisker.history.list()

-- Most recent is last
local previous = history[#history]

-- Full history
for i, passageId in ipairs(history) do
  print(i .. ": " .. passageId)
end
```

### 7.5.4 count

```lua
whisker.history.count() -> number
```

Returns the number of entries in history.

**Parameters:** None.

**Returns:** Number of history entries.

**Example:**

```lua
local steps = whisker.history.count()
print("You've visited " .. steps .. " passages")
```

### 7.5.5 contains

```lua
whisker.history.contains(id: string) -> boolean
```

Checks if a passage is in the history.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Passage identifier to check |

**Returns:** `true` if passage is in history, `false` otherwise.

**Example:**

```lua
if whisker.history.contains("SecretRoom") then
  -- Player has been to the secret room
end
```

### 7.5.6 clear

```lua
whisker.history.clear() -> nil
```

Clears all navigation history.

**Parameters:** None.

**Returns:** Nothing.

**Example:**

```lua
-- Clear history (e.g., on chapter transition)
whisker.history.clear()
```

## 7.6 whisker.choice

The `whisker.choice` namespace manages choices in the current passage.

### 7.6.1 available

```lua
whisker.choice.available() -> table
```

Returns currently available choices.

**Parameters:** None.

**Returns:** Array of Choice objects.

**Example:**

```lua
local choices = whisker.choice.available()

for i, choice in ipairs(choices) do
  print(i .. ": " .. choice.text)
end
```

### 7.6.2 select

```lua
whisker.choice.select(index: number) -> nil
```

Programmatically selects a choice by index.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based choice index |

**Returns:** Nothing (selection and navigation occur).

**Example:**

```lua
-- Auto-select first choice
whisker.choice.select(1)

-- Random choice
local choices = whisker.choice.available()
local randomIndex = math.random(1, #choices)
whisker.choice.select(randomIndex)
```

### 7.6.3 count

```lua
whisker.choice.count() -> number
```

Returns the number of available choices.

**Parameters:** None.

**Returns:** Number of currently available choices.

**Example:**

```lua
if whisker.choice.count() == 0 then
  -- No choices available
  whisker.passage.go("Fallback")
end
```

### 7.6.4 Choice Object

The Choice object structure:

| Property | Type | Description |
|----------|------|-------------|
| `text` | string | Displayed choice text (interpolated) |
| `target` | string | Target passage identifier |
| `type` | string | `"once"` or `"sticky"` |
| `index` | number | Position in choice list |

## 7.7 whisker.hook

The `whisker.hook` namespace manages named text regions for dynamic content updates.

### 7.7.1 Overview

Hooks are named, modifiable text regions that enable dynamic content updates without page navigation. They bridge the story logic layer and presentation layer.

```whisker
:: Room
|description>[The room is dark.]

+ [Light torch] {{ whisker.hook.replace("description", "The room is illuminated.") }} -> Room
```

### 7.7.2 define

```lua
whisker.hook.define(name: string, content: string, visible?: boolean) -> boolean
```

Defines a new hook.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Hook identifier |
| `content` | string | Initial content |
| `visible` | boolean | Initial visibility (default: `true`) |

**Returns:** `true` if created, `false` if hook already exists.

### 7.7.3 get

```lua
whisker.hook.get(name: string) -> string
```

Retrieves the current content of a hook.

**Returns:** String content, or `""` if hook doesn't exist.

### 7.7.4 replace

```lua
whisker.hook.replace(name: string, content: string) -> boolean
```

Replaces the entire content of a hook.

**Returns:** `true` if replaced, `false` if hook doesn't exist.

### 7.7.5 append

```lua
whisker.hook.append(name: string, content: string) -> boolean
```

Adds content after the existing hook content.

**Returns:** `true` if appended, `false` if hook doesn't exist.

### 7.7.6 prepend

```lua
whisker.hook.prepend(name: string, content: string) -> boolean
```

Adds content before the existing hook content.

**Returns:** `true` if prepended, `false` if hook doesn't exist.

### 7.7.7 show

```lua
whisker.hook.show(name: string) -> boolean
```

Makes a hidden hook visible.

**Returns:** `true` if shown, `false` if hook doesn't exist or already visible.

### 7.7.8 hide

```lua
whisker.hook.hide(name: string) -> boolean
```

Makes a visible hook invisible (content preserved but not rendered).

**Returns:** `true` if hidden, `false` if hook doesn't exist or already hidden.

### 7.7.9 isVisible

```lua
whisker.hook.isVisible(name: string) -> boolean
```

Checks if a hook is currently visible.

**Returns:** `true` if visible, `false` if hidden or doesn't exist.

### 7.7.10 exists

```lua
whisker.hook.exists(name: string) -> boolean
```

Checks if a hook is defined.

**Returns:** `true` if hook exists, `false` otherwise.

### 7.7.11 clear

```lua
whisker.hook.clear(name: string) -> boolean
```

Removes a hook entirely.

**Returns:** `true` if cleared, `false` if hook doesn't exist.

### 7.7.12 all

```lua
whisker.hook.all() -> table
```

Returns all defined hooks.

**Returns:** Table mapping hook names to their state:

```lua
{
  description = { content = "The room is dark.", visible = true },
  secret = { content = "Hidden treasure", visible = false }
}
```

### 7.7.13 Directive Syntax

Hooks can also be manipulated via directive syntax in choice actions:

```whisker
+ [Light torch] { @replace: description { The room is illuminated. } } -> Room
+ [Look closer] { @append: description { You see ancient runes. } } -> Room
+ [Hide warning] { @hide: warning } -> Room
+ [Show hint] { @show: hint } -> Room
```

### 7.7.14 Hook Scope

- Hooks are **passage-scoped** by default
- Hooks persist across revisits to the same passage
- Hooks are **not saved** by default (presentation-layer only)
- To persist hooks, include in save state explicitly

## 7.8 Top-Level Functions

These functions are available directly on the `whisker` namespace.

### 7.8.1 visited

```lua
whisker.visited(passage?: string) -> number
```

Returns the visit count for a passage.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `passage` | string (optional) | Passage ID, or current passage if omitted |

**Returns:** Number of times the passage has been visited.

**Example:**

```lua
-- Current passage visits
local visits = whisker.visited()

-- Specific passage visits
local caveVisits = whisker.visited("Cave")

-- First visit check
if whisker.visited("Introduction") == 0 then
  -- Never been here
end
```

**Note:** Visit count increments when entering a passage, before `@onEnter` executes.

### 7.8.2 random

```lua
whisker.random(min: number, max: number) -> number
```

Returns a random integer between min and max (inclusive).

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum value (inclusive) |
| `max` | number | Maximum value (inclusive) |

**Returns:** Random integer in range [min, max].

**Example:**

```lua
-- Roll a d6
local roll = whisker.random(1, 6)

-- Random gold drop
local gold = whisker.random(10, 50)
whisker.state.set("gold", whisker.state.get("gold") + gold)
```

#### Random State and Seeding

**Seeding:**

```lua
whisker.random.seed(seed: number) -> nil
```

Sets the random number generator seed for reproducible sequences.

| Parameter | Type | Description |
|-----------|------|-------------|
| `seed` | number | Integer seed value |

**Getting Current Seed:**

```lua
whisker.random.getseed() -> number
```

Returns the current seed (for save state).

**Reproducibility Requirements:**

| Requirement | Specification |
|-------------|---------------|
| Algorithm | Implementation-defined (recommend xorshift128+) |
| Same seed = same sequence | MUST be true within same implementation |
| Cross-implementation | NOT guaranteed (different algorithms) |
| Save/Load | Seed MUST be saved and restored |

**Save State Integration:**

The random seed MUST be included in save state:

```json
{
  "variables": { ... },
  "random_seed": 12345,
  "random_calls": 42
}
```

Where `random_calls` is the number of random() calls since last seed, allowing exact replay.

**Testing Mode:**

For deterministic testing, implementations SHOULD support:

```lua
-- Set fixed seed at story start
whisker.random.seed(42)

-- All random() calls now deterministic
assert(whisker.random(1, 6) == 3)  -- Always 3 with seed 42
```

**Default Behavior:**

- New story: seed from system time/entropy
- Load save: restore seed + call count
- No explicit seed: non-deterministic

### 7.8.3 pick

```lua
whisker.pick(...) -> any
```

Returns a random value from the arguments.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `...` | any | Values to choose from |

**Returns:** One of the provided values, randomly selected.

**Example:**

```lua
local color = whisker.pick("red", "green", "blue")
local enemy = whisker.pick("goblin", "orc", "troll", "dragon")

whisker.state.set("randomEnemy", enemy)
```

### 7.8.4 print

```lua
whisker.print(...) -> nil
```

Outputs text to the debug console.

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `...` | any | Values to print |

**Returns:** Nothing.

**Example:**

```lua
whisker.print("Debug:", whisker.state.get("gold"))
whisker.print("Entering passage:", whisker.passage.current().id)
```

**Note:** Output destination is implementation-defined. MAY be suppressed in production.

### 7.8.5 Relationship Helpers

Helper functions for NPC relationship tracking patterns.

#### clamp

```lua
whisker.clamp(value: number, min: number, max: number) -> number
```

Constrains a value to a range. Useful for relationship bounds.

**Example:**

```lua
-- Keep relationship in 0-100 range
local rel = whisker.state.get("rel_alice")
rel = whisker.clamp(rel + 10, 0, 100)
whisker.state.set("rel_alice", rel)
```

#### modify

```lua
whisker.modify(varname: string, delta: number, min?: number, max?: number) -> number
```

Modifies a numeric variable with optional clamping. Returns new value.

**Example:**

```lua
-- Add 10 to relationship, keep in 0-100
local newVal = whisker.modify("rel_alice", 10, 0, 100)

-- Subtract 5 from health, minimum 0
whisker.modify("health", -5, 0)
```

#### threshold

```lua
whisker.threshold(value: number, thresholds: table) -> string
```

Returns a label based on value thresholds.

**Example:**

```lua
local rel = whisker.state.get("rel_alice")
local status = whisker.threshold(rel, {
  {0, "hostile"},
  {25, "unfriendly"},
  {50, "neutral"},
  {75, "friendly"},
  {90, "devoted"}
})
-- rel=60 returns "neutral", rel=80 returns "friendly"
```

#### compare

```lua
whisker.compare(var1: string, var2: string) -> string
```

Compares two variables, returns "higher", "lower", or "equal".

**Example:**

```lua
-- Who likes us more?
local result = whisker.compare("rel_alice", "rel_bob")
if result == "higher" then
  -- Alice likes us more
end
```

## 7.9 Lua Standard Library

### 7.9.1 Available Functions

WLS implementations MUST provide these Lua standard functions:

| Library | Functions |
|---------|-----------|
| Basic | `type`, `tostring`, `tonumber`, `pairs`, `ipairs`, `next`, `select`, `unpack` |
| String | `string.len`, `string.sub`, `string.upper`, `string.lower`, `string.find`, `string.match`, `string.gsub`, `string.format`, `string.rep`, `string.reverse` |
| Table | `table.insert`, `table.remove`, `table.concat`, `table.sort` |
| Math | `math.abs`, `math.ceil`, `math.floor`, `math.max`, `math.min`, `math.random`, `math.randomseed`, `math.sqrt`, `math.pow`, `math.sin`, `math.cos`, `math.tan` |

### 7.9.2 Restricted Functions

These functions MUST NOT be available (security):

| Function | Reason |
|----------|--------|
| `io.*` | File system access |
| `os.execute` | System command execution |
| `os.exit` | Process termination |
| `os.remove` | File deletion |
| `os.rename` | File manipulation |
| `loadfile` | Arbitrary code loading |
| `dofile` | Arbitrary code execution |
| `load` | Dynamic code execution |
| `require` | Module loading |
| `debug.*` | Debug library access |

### 7.9.3 Safe os Functions

These `os` functions MAY be provided:

| Function | Description |
|----------|-------------|
| `os.time` | Current timestamp |
| `os.date` | Date formatting |
| `os.difftime` | Time difference |
| `os.clock` | CPU time |

## 7.10 Sandboxing

### 7.10.1 Execution Environment

Lua code executes in a sandboxed environment:

| Constraint | Requirement |
|------------|-------------|
| Global access | Limited to `whisker.*` and safe stdlib |
| File access | Prohibited |
| Network access | Prohibited |
| System access | Prohibited |
| Execution time | Implementation MAY limit |
| Memory | Implementation MAY limit |

### 7.10.2 Global Variables

Scripts SHOULD NOT rely on global variable persistence between executions:

```lua
-- Avoid: Global may not persist
myGlobal = "value"

-- Prefer: Use whisker.state
whisker.state.set("myValue", "value")
```

### 7.10.3 Error Isolation

Lua errors SHOULD NOT crash the engine:

| Error Type | Handling |
|------------|----------|
| Syntax error | Report at parse time |
| Runtime error | Catch, report, continue |
| Infinite loop | Timeout (implementation-defined) |

## 7.11 Error Handling

### 7.11.1 API Errors

| Error | Cause | Example |
|-------|-------|---------|
| Invalid argument | Wrong type passed | `whisker.state.get(123)` |
| Missing argument | Required param missing | `whisker.state.set("key")` |
| Invalid passage | Passage doesn't exist | `whisker.passage.go("NoExist")` |
| Index out of range | Invalid choice index | `whisker.choice.select(999)` |

### 7.11.2 Error Messages

Implementations SHOULD provide helpful errors:

```
Error in passage "Shop" at line 5:
  whisker.state.get() requires a string argument

  Got: nil
  Expected: string
```

### 7.11.3 Defensive Coding

Authors SHOULD validate before calling:

```lua
-- Check before navigation
if whisker.passage.exists(target) then
  whisker.passage.go(target)
else
  whisker.passage.go("ErrorPassage")
end

-- Check before state access
local gold = whisker.state.get("gold") or 0
```

## 7.12 Implementation Notes

### 7.12.1 API Consistency

Implementations MUST:

1. Implement all documented functions
2. Accept documented parameter types
3. Return documented return types
4. Handle edge cases gracefully

### 7.12.2 Dot vs Colon Notation

WLS uses dot notation exclusively:

```lua
-- Correct (WLS)
whisker.state.get("gold")

-- Incorrect (not WLS)
whisker.state:get("gold")
```

### 7.12.3 Thread Safety and Concurrency

WLS assumes a **single-threaded execution model** by default. This section clarifies behavior for implementations that support concurrency.

#### Single-Threaded Semantics

The canonical execution model is single-threaded:
- One passage executes at a time
- State changes are immediately visible
- No race conditions possible

#### Multi-Threaded Implementations

If implementations support concurrent execution:

**Required Guarantees:**

| Operation | Requirement |
|-----------|-------------|
| State read | Atomic |
| State write | Atomic |
| State read-modify-write | Serialized |
| Navigation | Serialized (one active at a time) |
| History operations | Thread-safe |
| Choice selection | Atomic |

**Prohibited:**

- Concurrent passage execution in same story instance
- Parallel modification of shared state
- Unsynchronized access to story variables

**Recommended Patterns:**

1. **Instance Isolation**: Each story instance has independent state
2. **Copy-on-Write**: Clone state before parallel operations
3. **Message Passing**: Use queues for cross-thread communication

#### Lua Concurrency

Lua scripts MUST execute in a single-threaded context:

```lua
-- SAFE: Sequential operations
whisker.state.set("a", 1)
whisker.state.set("b", 2)

-- UNDEFINED: Concurrent access from multiple threads
-- Implementations MUST prevent this scenario
```

#### Save/Load Atomicity

Save and load operations MUST be atomic:
- Partial saves MUST NOT be persisted
- Load MUST completely replace state or fail entirely
- Concurrent save/load MUST be serialized

### 7.12.4 Performance

Implementations SHOULD:

- Cache passage lookups
- Optimize frequent state access
- Minimize memory allocation in hot paths
- Consider lazy evaluation for computed properties

## 7.13 Quick Reference

### 7.13.1 State Management

```lua
whisker.state.get(key)           -- Get variable
whisker.state.set(key, value)    -- Set variable
whisker.state.has(key)           -- Check exists
whisker.state.delete(key)        -- Remove variable
whisker.state.all()              -- Get all as table
whisker.state.reset()            -- Clear all
```

### 7.13.2 Passage Operations

```lua
whisker.passage.current()        -- Current passage
whisker.passage.get(id)          -- Get by ID
whisker.passage.go(id)           -- Navigate to
whisker.passage.exists(id)       -- Check exists
whisker.passage.all()            -- Get all passages
whisker.passage.tags(tag)        -- Get by tag
```

### 7.13.3 History

```lua
whisker.history.back()           -- Go back
whisker.history.canBack()        -- Can go back?
whisker.history.list()           -- Get history
whisker.history.count()          -- History length
whisker.history.contains(id)     -- In history?
whisker.history.clear()          -- Clear history
```

### 7.13.4 Choices

```lua
whisker.choice.available()       -- Get choices
whisker.choice.select(index)     -- Select choice
whisker.choice.count()           -- Choice count
```

### 7.13.5 Utilities

```lua
whisker.visited(passage?)        -- Visit count
whisker.random(min, max)         -- Random integer
whisker.pick(...)                -- Random selection
whisker.print(...)               -- Debug output
```

---

**Previous Chapter:** [Choices](06-CHOICES.md)
**Next Chapter:** [File Formats](08-FILE_FORMATS.md)

---


# Chapter 8: File Formats

**Whisker Language Specification 1.0**

---

## 8.1 Overview

WLS defines two file formats for representing stories:

| Format | Extension | Purpose |
|--------|-----------|---------|
| Text | `.ws` | Human authoring and editing |
| JSON | `.json` | Machine processing and interchange |

Both formats represent the same underlying data and MUST be convertible without loss.

### 8.1.1 Format Comparison

| Feature | Text (.ws) | JSON |
|---------|------------|------|
| Human readable | Excellent | Good |
| Machine parsing | Moderate | Excellent |
| Version control | Excellent | Good |
| Editor support | Custom parsers | Standard JSON |
| File size | Smaller | Larger |

## 8.2 Text Format (.ws)

### 8.2.1 File Structure

A `.ws` file has this structure:

```
┌─────────────────────────────┐
│ Story Header (optional)     │
│   @title, @author, etc.     │
├─────────────────────────────┤
│ Variable Declarations       │
│   @vars block (optional)    │
├─────────────────────────────┤
│ Passages                    │
│   :: PassageName            │
│   Content...                │
│   Choices...                │
│                             │
│   :: AnotherPassage         │
│   Content...                │
└─────────────────────────────┘
```

### 8.2.2 Encoding

| Property | Requirement |
|----------|-------------|
| Character encoding | UTF-8 |
| BOM | Optional (SHOULD NOT include) |
| Line endings | LF (`\n`) or CRLF (`\r\n`) |
| Trailing newline | SHOULD include |

### 8.2.3 Story Header

The story header contains metadata directives:

```whisker
@title: The Enchanted Forest
@author: Jane Writer
@version: 1.0.0
@ifid: 550e8400-e29b-41d4-a716-446655440000
@start: Prologue
```

**Header Directives:**

| Directive | Type | Required | Description |
|-----------|------|----------|-------------|
| `@title:` | string | SHOULD | Story title |
| `@author:` | string | SHOULD | Author name |
| `@version:` | string | MAY | Story version (semver) |
| `@ifid:` | string | SHOULD | Interactive Fiction ID (UUID) |
| `@start:` | string | MAY | Start passage ID |
| `@description:` | string | MAY | Brief description |
| `@created:` | string | MAY | ISO 8601 timestamp |
| `@modified:` | string | MAY | ISO 8601 timestamp |

**Rules:**
- Header MUST appear before any passages
- Each directive on its own line
- Colon followed by space, then value
- Values extend to end of line
- Unknown directives SHOULD be preserved

### 8.2.4 Variable Declarations

Pre-declare variables with initial values:

```whisker
@vars
  gold: 100
  playerName: "Adventurer"
  hasKey: false
  health: 100.0
```

**Syntax:**

```
@vars
  varName: value
  varName: value
  ...
```

**Rules:**
- Indentation required (2 spaces recommended)
- One variable per line
- Colon separates name from value
- Values follow literal syntax (Chapter 3)
- Block ends at next directive or passage

**Value Types:**

| Type | Syntax | Example |
|------|--------|---------|
| Number | digits, optional decimal | `100`, `3.14` |
| String | double-quoted | `"Hello"` |
| Boolean | `true` or `false` | `true` |

### 8.2.5 Passage Declaration

Passages begin with the `::` marker:

```whisker
:: PassageName
Passage content here.
```

**With metadata:**

```whisker
:: PassageName
@tags: tag1, tag2, tag3
@color: #ff5500
@position: 100, 200
@notes: Author notes here
@onEnter: whisker.state.set("visited", true)
@onExit: whisker.print("leaving")

Passage content starts after blank line or directives.
```

**Passage Directives:**

| Directive | Type | Description |
|-----------|------|-------------|
| `@tags:` | string[] | Comma-separated tags |
| `@color:` | string | Hex color for editor |
| `@position:` | number[] | Editor position (x, y) |
| `@notes:` | string | Author notes (not rendered) |
| `@onEnter:` | string | Lua script on entry |
| `@onExit:` | string | Lua script on exit |
| `@fallback:` | string | Fallback passage ID |

### 8.2.6 Passage Content

Content follows the passage declaration:

```whisker
:: Garden
The garden is peaceful.

$visits += 1

{ $visits == 1 }
  You've never been here before.
{else}
  You recognize this place.
{/}

+ [Smell the flowers] -> Flowers
+ [Leave] -> Exit
```

**Content Elements:**

| Element | Description |
|---------|-------------|
| Plain text | Narrative prose |
| Blank lines | Paragraph breaks |
| Variable assignment | `$var = value` |
| Conditionals | `{ cond }...{/}` |
| Alternatives | `{\| a \| b }` |
| Choices | `+ [text] -> target` |
| Comments | `//` or `/* */` |
| Embedded Lua | `{{ code }}` |

### 8.2.7 Comments

```whisker
// Single-line comment

/* Multi-line
   comment */

$gold = 100  // Inline comment
```

Comments are stripped during parsing and not preserved in JSON output.

### 8.2.8 Complete Example

```whisker
@title: The Lost Key
@author: Example Author
@version: 1.0.0
@ifid: 123e4567-e89b-12d3-a456-426614174000
@start: Start

@vars
  gold: 50
  hasKey: false
  playerName: "Traveler"

:: Start
@tags: beginning
@color: #3498db

Welcome, $playerName!

You find yourself at the entrance to a mysterious dungeon.
Your purse contains $gold gold coins.

+ [Enter the dungeon] -> DungeonEntrance
+ [Search the area] -> SearchArea

:: SearchArea
You search the surrounding area carefully.

{ whisker.visited("SearchArea") == 1 }
  {~| Under a rock | Behind a bush | In the grass }, you find something!
  $gold += 10
  You found 10 gold coins!
{else}
  You've already searched here. Nothing new to find.
{/}

+ [Enter the dungeon] -> DungeonEntrance
+ [Keep searching] -> SearchArea

:: DungeonEntrance
@tags: dungeon, main

The dungeon entrance looms before you.

{ $hasKey }
  The iron gate stands open.
  + [Proceed inside] -> DungeonInner
{else}
  A locked iron gate blocks your path.
  + { $gold >= 25 } [Bribe the guard ($25)] { $gold -= 25; $hasKey = true } -> DungeonEntrance
  + [Look for another way] -> SearchArea
{/}

+ [Leave this place] -> END

:: DungeonInner
@onEnter: whisker.state.set("dungeonVisits", (whisker.state.get("dungeonVisits") or 0) + 1)

You enter the dungeon depths.

{| First time here... spooky! | Back again. | You know this place well now. }

The adventure continues...

+ [Explore deeper] -> END
```

## 8.3 JSON Format

### 8.3.1 Schema Overview

JSON format version: **2.1**
Schema file: `wls.schema.json`

```json
{
  "format": "whisker",
  "version": "2.1",
  "wls": "1.0",
  "metadata": { ... },
  "settings": { ... },
  "variables": { ... },
  "passages": [ ... ],
  "assets": [ ... ]
}
```

### 8.3.2 Root Object

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `format` | string | Yes | Must be `"whisker"` |
| `version` | string | Yes | Format version (e.g., `"2.1"`) |
| `wls` | string | Yes | WLS version (e.g., `"1.0"`) |
| `metadata` | object | Yes | Story metadata |
| `settings` | object | No | Story settings |
| `variables` | object | No | Initial variables |
| `passages` | array | Yes | Passage objects |
| `assets` | array | No | Asset references |

### 8.3.3 Metadata Object

```json
{
  "metadata": {
    "title": "The Lost Key",
    "author": "Example Author",
    "version": "1.0.0",
    "ifid": "123e4567-e89b-12d3-a456-426614174000",
    "description": "A short adventure",
    "created": "2025-12-29T10:00:00Z",
    "modified": "2025-12-29T15:30:00Z",
    "start": "Start"
  }
}
```

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `title` | string | SHOULD | Story title |
| `author` | string | SHOULD | Author name |
| `version` | string | MAY | Story version |
| `ifid` | string | SHOULD | UUID identifier |
| `description` | string | MAY | Brief description |
| `created` | string | MAY | ISO 8601 timestamp |
| `modified` | string | MAY | ISO 8601 timestamp |
| `start` | string | MAY | Start passage ID |

### 8.3.4 Settings Object

```json
{
  "settings": {
    "debug": false,
    "historyLimit": 100,
    "autoSave": true
  }
}
```

Settings are implementation-defined. Common settings:

| Setting | Type | Description |
|---------|------|-------------|
| `debug` | boolean | Enable debug mode |
| `historyLimit` | number | Max history entries |
| `autoSave` | boolean | Enable auto-save |

### 8.3.5 Variables Object

```json
{
  "variables": {
    "gold": {
      "type": "number",
      "value": 50
    },
    "playerName": {
      "type": "string",
      "value": "Traveler"
    },
    "hasKey": {
      "type": "boolean",
      "value": false
    }
  }
}
```

**Variable Definition:**

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `type` | string | Yes | `"number"`, `"string"`, or `"boolean"` |
| `value` | any | Yes | Initial value |
| `description` | string | No | Documentation |

### 8.3.6 Passage Object

```json
{
  "passages": [
    {
      "id": "Start",
      "content": "Welcome, $playerName!\n\nYou find yourself at the entrance.",
      "tags": ["beginning"],
      "metadata": {
        "color": "#3498db",
        "position": [100, 200],
        "notes": "Opening scene"
      },
      "scripts": {
        "onEnter": null,
        "onExit": null
      },
      "choices": [
        {
          "type": "once",
          "condition": null,
          "text": "Enter the dungeon",
          "action": null,
          "target": "DungeonEntrance"
        }
      ]
    }
  ]
}
```

**Passage Properties:**

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | string | Yes | Unique identifier |
| `content` | string | Yes | Passage content |
| `tags` | string[] | No | Passage tags |
| `metadata` | object | No | Editor metadata |
| `scripts` | object | No | Lifecycle scripts |
| `choices` | array | No | Choice objects |

**Metadata Object:**

| Property | Type | Description |
|----------|------|-------------|
| `color` | string | Hex color |
| `position` | number[] | [x, y] coordinates |
| `notes` | string | Author notes |

**Scripts Object:**

| Property | Type | Description |
|----------|------|-------------|
| `onEnter` | string \| null | Entry script |
| `onExit` | string \| null | Exit script |

### 8.3.7 Choice Object

```json
{
  "type": "once",
  "condition": "$gold >= 25",
  "text": "Bribe the guard ($25)",
  "action": "$gold -= 25; $hasKey = true",
  "target": "DungeonEntrance"
}
```

**Choice Properties:**

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `type` | string | Yes | `"once"` or `"sticky"` |
| `condition` | string \| null | No | Visibility condition |
| `text` | string | Yes | Display text |
| `action` | string \| null | No | Selection action |
| `target` | string | Yes | Target passage ID |

### 8.3.8 Asset Object

```json
{
  "assets": [
    {
      "id": "forest-bg",
      "type": "image",
      "path": "assets/images/forest.png",
      "mimeType": "image/png"
    },
    {
      "id": "ambient-music",
      "type": "audio",
      "path": "assets/audio/ambient.mp3",
      "mimeType": "audio/mpeg"
    }
  ]
}
```

**Asset Properties:**

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | string | Yes | Unique identifier |
| `type` | string | Yes | `"image"`, `"audio"`, `"video"` |
| `path` | string | Yes | Relative file path |
| `mimeType` | string | No | MIME type |
| `metadata` | object | No | Additional metadata |

### 8.3.9 Complete JSON Example

```json
{
  "format": "whisker",
  "version": "2.1",
  "wls": "1.0",
  "metadata": {
    "title": "The Lost Key",
    "author": "Example Author",
    "version": "1.0.0",
    "ifid": "123e4567-e89b-12d3-a456-426614174000",
    "description": "A short dungeon adventure",
    "created": "2025-12-29T10:00:00Z",
    "modified": "2025-12-29T15:30:00Z",
    "start": "Start"
  },
  "settings": {
    "debug": false
  },
  "variables": {
    "gold": {
      "type": "number",
      "value": 50
    },
    "hasKey": {
      "type": "boolean",
      "value": false
    },
    "playerName": {
      "type": "string",
      "value": "Traveler"
    }
  },
  "passages": [
    {
      "id": "Start",
      "content": "Welcome, $playerName!\n\nYou find yourself at the entrance to a mysterious dungeon.\nYour purse contains $gold gold coins.",
      "tags": ["beginning"],
      "metadata": {
        "color": "#3498db",
        "position": [100, 100]
      },
      "scripts": {
        "onEnter": null,
        "onExit": null
      },
      "choices": [
        {
          "type": "once",
          "condition": null,
          "text": "Enter the dungeon",
          "action": null,
          "target": "DungeonEntrance"
        },
        {
          "type": "once",
          "condition": null,
          "text": "Search the area",
          "action": null,
          "target": "SearchArea"
        }
      ]
    },
    {
      "id": "SearchArea",
      "content": "You search the surrounding area carefully.\n\n{ whisker.visited(\"SearchArea\") == 1 }\n  {~| Under a rock | Behind a bush | In the grass }, you find something!\n  $gold += 10\n  You found 10 gold coins!\n{else}\n  You've already searched here. Nothing new to find.\n{/}",
      "tags": [],
      "metadata": {
        "position": [300, 100]
      },
      "scripts": {
        "onEnter": null,
        "onExit": null
      },
      "choices": [
        {
          "type": "once",
          "condition": null,
          "text": "Enter the dungeon",
          "action": null,
          "target": "DungeonEntrance"
        },
        {
          "type": "sticky",
          "condition": null,
          "text": "Keep searching",
          "action": null,
          "target": "SearchArea"
        }
      ]
    },
    {
      "id": "DungeonEntrance",
      "content": "The dungeon entrance looms before you.\n\n{ $hasKey }\n  The iron gate stands open.\n{else}\n  A locked iron gate blocks your path.\n{/}",
      "tags": ["dungeon", "main"],
      "metadata": {
        "position": [200, 300]
      },
      "scripts": {
        "onEnter": null,
        "onExit": null
      },
      "choices": [
        {
          "type": "once",
          "condition": "$hasKey",
          "text": "Proceed inside",
          "action": null,
          "target": "DungeonInner"
        },
        {
          "type": "once",
          "condition": "$gold >= 25 and not $hasKey",
          "text": "Bribe the guard ($25)",
          "action": "$gold -= 25; $hasKey = true",
          "target": "DungeonEntrance"
        },
        {
          "type": "once",
          "condition": "not $hasKey",
          "text": "Look for another way",
          "action": null,
          "target": "SearchArea"
        },
        {
          "type": "once",
          "condition": null,
          "text": "Leave this place",
          "action": null,
          "target": "END"
        }
      ]
    },
    {
      "id": "DungeonInner",
      "content": "You enter the dungeon depths.\n\n{| First time here... spooky! | Back again. | You know this place well now. }\n\nThe adventure continues...",
      "tags": ["dungeon"],
      "metadata": {
        "position": [200, 500]
      },
      "scripts": {
        "onEnter": "whisker.state.set(\"dungeonVisits\", (whisker.state.get(\"dungeonVisits\") or 0) + 1)",
        "onExit": null
      },
      "choices": [
        {
          "type": "once",
          "condition": null,
          "text": "Explore deeper",
          "action": null,
          "target": "END"
        }
      ]
    }
  ],
  "assets": []
}
```

## 8.4 Format Conversion

### 8.4.1 Text to JSON

Converting `.ws` to JSON:

1. Parse story header into `metadata`
2. Parse `@vars` block into `variables`
3. Parse each passage:
   - Extract ID from `:: Name`
   - Extract directives into `metadata` and `scripts`
   - Keep content as raw string
   - Parse choices into choice objects
4. Validate all passage references

### 8.4.2 JSON to Text

Converting JSON to `.ws`:

1. Write header directives from `metadata`
2. Write `@vars` block from `variables`
3. Write each passage:
   - Write `:: id`
   - Write directives from `metadata` and `scripts`
   - Write content string
   - (Choices are embedded in content)

### 8.4.3 Lossless Conversion

Conversion MUST be lossless for:

| Element | Preserved |
|---------|-----------|
| Metadata | All standard fields |
| Variables | Type and value |
| Passage content | Exact string |
| Choices | All properties |
| Tags | Order and values |

MAY be lost in conversion:

| Element | Notes |
|---------|-------|
| Comments | Stripped in text → JSON |
| Whitespace | Normalized |
| Unknown directives | Implementation-dependent |

## 8.5 MIME Types and Extensions

### 8.5.1 File Extensions

| Format | Extension | Notes |
|--------|-----------|-------|
| Text | `.ws` | Primary extension |
| Text | `.whisker` | Alternative (not recommended) |
| JSON | `.json` | Standard JSON |
| JSON | `.wsjson` | Optional specific extension |

### 8.5.2 MIME Types

| Format | MIME Type |
|--------|-----------|
| Text | `text/x-whisker` |
| JSON | `application/json` |

## 8.6 Validation

### 8.6.1 Required Validation

Implementations MUST validate:

| Check | Description |
|-------|-------------|
| Format identifier | `format` equals `"whisker"` |
| Version compatibility | `wls` version is supported |
| Passage references | All targets exist |
| Variable types | Values match declared types |
| Unique IDs | No duplicate passage IDs |
| Start passage | Start passage exists |

### 8.6.2 Validation Errors

```json
{
  "valid": false,
  "errors": [
    {
      "type": "INVALID_REFERENCE",
      "message": "Choice target 'NonExistent' does not exist",
      "location": {
        "passage": "Start",
        "choice": 0
      }
    }
  ]
}
```

### 8.6.3 Schema Validation

JSON files SHOULD validate against `wls.schema.json`:

```bash
# Example validation command
ajv validate -s wls.schema.json -d story.json
```

## 8.7 Versioning

### 8.7.1 Format Version

The `version` field tracks JSON format changes:

| Version | Changes |
|---------|---------|
| 1.0 | Initial format |
| 2.0 | Added WLS compliance fields |
| 2.1 | Added asset support |

### 8.7.2 WLS Version

The `wls` field indicates language specification version:

| Version | Description |
|---------|-------------|
| 1.0 | This specification |

### 8.7.3 Compatibility

Implementations SHOULD:

1. Support current and previous format versions
2. Warn on unknown format versions
3. Reject incompatible WLS versions
4. Upgrade older formats when possible

## 8.8 Implementation Notes

### 8.8.1 Parsing Recommendations

**Text Format:**

1. Use line-by-line parsing for headers
2. Use state machine for passage boundaries
3. Preserve content strings exactly
4. Parse choices with regex or parser combinator

**JSON Format:**

1. Use standard JSON parser
2. Validate against schema
3. Build passage index for lookups

### 8.8.2 Serialization

When writing JSON:

- Use 2-space indentation for readability
- Sort object keys consistently
- Escape special characters properly
- Use `null` for absent optional values

### 8.8.3 Performance

For large stories:

- Lazy-load passage content
- Index passages by ID
- Cache parsed structures
- Stream large files

---

**Previous Chapter:** [Lua API](07-LUA_API.md)
**Next Chapter:** [Examples](09-EXAMPLES.md)

---


# Chapter 10: Common Patterns

**Whisker Language Specification 1.0**

---

This chapter provides ready-to-use patterns for common interactive fiction scenarios.

## 10.1 Inventory System

A LIST-based inventory pattern using the built-in list type.

```whisker
--- story
LIST items = (empty), key, sword, torch, map, potion

$inventory = (empty)
---

=== Inventory Check ===
{$inventory == (empty)}
  You are carrying nothing.
{/}
{$inventory ~= (empty)}
  You are carrying: $inventory
{/}

+ [Take the key] {$inventory += key} -> Room
+ [Drop the sword] {$sword in $inventory: $inventory -= sword} -> Room
```

## 10.2 Relationship Tracking

Track NPC relationships with numeric values.

```whisker
--- story
$rel_alice = 50   // Neutral (0-100 scale)
$rel_bob = 50
---

=== Talk to Alice ===
{$rel_alice >= 75}
  Alice smiles warmly. "It's wonderful to see you!"
{$rel_alice >= 25 and $rel_alice < 75}
  Alice nods politely. "Hello there."
{$rel_alice < 25}
  Alice scowls. "What do you want?"
{/}

+ [Compliment her] {$rel_alice += 10} -> AliceHappy
+ [Insult her] {$rel_alice -= 20} -> AliceAngry
+ [Leave] -> Tavern
```

## 10.3 Dialog Trees

Conversation menu pattern with exhaustible options.

```whisker
=== Talk to Merchant ===
What would you like to discuss?

+ [Ask about prices] -> MerchantPrices -> TalkToMerchant
+ [Ask about rumors] -> MerchantRumors -> TalkToMerchant
+ [Ask about the war] {not visited("MerchantWar")} -> MerchantWar -> TalkToMerchant
* [Goodbye] -> Market

=== MerchantPrices ===
"Prices are fair, I assure you. Take a look."
->->

=== MerchantRumors ===
"I hear the old mine has reopened..."
->->

=== MerchantWar ===
"We don't speak of such things here."
->->
```

## 10.4 Time/Turn Counting

Track the passage of time through turns.

```whisker
--- story
$turn = 0
$hour = 8    // Start at 8 AM
$day = 1
---

=== Any Passage ===
{$turn += 1}
{$hour += 1}
{$hour >= 24}
  {$hour = 0}
  {$day += 1}
{/}

It is {$hour < 12: morning | $hour < 18: afternoon | evening} on day $day.

// Time-gated content
{$hour >= 22 or $hour < 6}
  The streets are dark and empty.
{/}
```

### 10.4.1 Advanced Turn Tracking

**Scheduled Events:**

```whisker
--- story
$turn = 0
ARRAY scheduledEvents = []
---

FUNCTION scheduleEvent(turnNumber, eventName)
  {{
    local events = whisker.state.get("scheduledEvents")
    table.insert(events, {turn = turnNumber, event = eventName})
    whisker.state.set("scheduledEvents", events)
  }}
END

FUNCTION checkScheduledEvents()
  {{
    local currentTurn = whisker.state.get("turn")
    local events = whisker.state.get("scheduledEvents")
    local remaining = {}

    for _, evt in ipairs(events) do
      if evt.turn <= currentTurn then
        whisker.passage.go(evt.event)
        return true
      else
        table.insert(remaining, evt)
      end
    end

    whisker.state.set("scheduledEvents", remaining)
    return false
  }}
END

:: StartQuest
The merchant says "Come back in 3 turns for your order."
{{ scheduleEvent(whisker.state.get("turn") + 3, "OrderReady") }}
-> Town

:: OrderReady
@tags: scheduled
The merchant waves you over. "Your order is ready!"
```

**Countdown Timer:**

```whisker
$bombTimer = 10

:: BombRoom
@on-enter: {$bombTimer -= 1}

{$bombTimer > 5}
  The bomb beeps steadily. Plenty of time.
{$bombTimer > 2}
  The beeping is faster now. Hurry!
{$bombTimer > 0}
  BEEP BEEP BEEP! Almost out of time!
{else}
  -> Explosion
{/}

* [Cut the red wire] -> DefuseBomb
* [Cut the blue wire] -> Explosion
* [Run!] -> Escape
```

**Recurring Events:**

```whisker
$lastMealTurn = 0
$hungerThreshold = 5

=== ProcessHunger ===
{{
  local turn = whisker.state.get("turn")
  local lastMeal = whisker.state.get("lastMealTurn")
  local threshold = whisker.state.get("hungerThreshold")

  if turn - lastMeal >= threshold then
    whisker.state.set("isHungry", true)
  end
}}

{$isHungry}
  Your stomach growls. You should find food soon.
{/}
```

### 10.4.2 Time Formatting

```whisker
FUNCTION formatTime(hour, minute)
  {{
    local h = hour or whisker.state.get("hour")
    local m = minute or 0
    local period = h >= 12 and "PM" or "AM"
    local displayHour = h % 12
    if displayHour == 0 then displayHour = 12 end
    return string.format("%d:%02d %s", displayHour, m, period)
  }}
END

FUNCTION formatDate(day, month, year)
  {{
    local d = day or whisker.state.get("day")
    local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
    local m = month or 1
    local y = year or 1
    return string.format("%s %d, Year %d", months[m], d, y)
  }}
END

:: Clock
The time is {{ formatTime() }}.
Today is {{ formatDate() }}.
```

### 10.4.3 Time-Based State Changes

```whisker
LIST shopStatus = open, closed, lunch_break

=== UpdateShopStatus ===
{{
  local hour = whisker.state.get("hour")
  local status = whisker.state.get("shopStatus")

  -- Clear all statuses
  status = {}

  if hour >= 9 and hour < 12 then
    status.open = true
  elseif hour >= 12 and hour < 13 then
    status.lunch_break = true
  elseif hour >= 13 and hour < 18 then
    status.open = true
  else
    status.closed = true
  end

  whisker.state.set("shopStatus", status)
}}

:: Shop
{$shopStatus ? open}
  The shop is open for business!
  + [Browse wares] -> ShopInventory
{$shopStatus ? lunch_break}
  A sign reads "Back in 1 hour - Lunch"
{$shopStatus ? closed}
  The shop is closed. Come back during business hours (9-18).
{/}
+ [Leave] -> Town
```

## 10.5 Stat Checks

Attribute-gated choices with skill checks.

```whisker
--- story
$strength = 12
$charisma = 8
$intelligence = 14
---

=== Blocked Door ===
A heavy door blocks your path.

+ [Force it open] {$strength >= 15} -> DoorOpened
+ [Force it open] {$strength < 15} -> DoorStuck
+ [Pick the lock] {$intelligence >= 12} -> DoorOpened
+ [Charm the guard] {$charisma >= 10} -> GuardHelps
* [Find another way] -> Hallway
```

## 10.6 Random Encounters

Probability-based event triggering.

```whisker
=== Forest Path ===
You walk through the forest.

{random() < 0.3}
  -> RandomEncounter
{/}

The path continues ahead.
+ [Continue] -> DeepForest
+ [Return] -> Village

=== RandomEncounter ===
_encounter = pick("wolf", "bandit", "trader", "nothing")
{_encounter == "wolf"}
  A wolf blocks your path!
  + [Fight] -> WolfFight
  + [Run] -> ForestPath
{_encounter == "bandit"}
  A bandit demands your gold!
  + [Pay] {$gold -= 10} -> ForestPath
  + [Fight] -> BanditFight
{_encounter == "trader"}
  You meet a friendly trader.
  + [Trade] -> TraderShop
  + [Chat] -> TraderChat
{_encounter == "nothing"}
  -> ForestPath
{/}
```

## 10.7 Dialog System

A reusable conversation system with topics, attitudes, and memory.

### 10.7.1 Basic Dialog Hub

```whisker
--- story
// Dialog state per NPC
$alice_topics_discussed = []
$alice_attitude = "neutral"
---

=== TalkToAlice ===
{$alice_attitude == "friendly"}
  Alice smiles at you. "What would you like to talk about?"
{$alice_attitude == "neutral"}
  Alice regards you calmly. "Yes?"
{$alice_attitude == "hostile"}
  Alice glares. "What do you want?"
{/}

+ [Ask about the weather] {not ("weather" in $alice_topics_discussed)} -> AliceWeather
+ [Ask about the king] {not ("king" in $alice_topics_discussed)} -> AliceKing
+ [Ask about herself] {not ("herself" in $alice_topics_discussed)} -> AliceHerself
+ [Give her a gift] {$hasFlowers} -> AliceGift
* [Goodbye] -> Town
```

### 10.7.2 Topic Passages

```whisker
=== AliceWeather ===
{$alice_topics_discussed[] = "weather"}

"The weather has been strange lately," Alice says. "Too much rain."

{$alice_attitude == "friendly"}
  She leans closer. "Between you and me, I think it's magical."
{/}

+ [Continue talking] -> TalkToAlice

=== AliceKing ===
{$alice_topics_discussed[] = "king"}

Alice's expression darkens. "The king... I'd rather not discuss him."

{$rel_alice >= 75}
  She sighs. "But since it's you... he's not what he seems."
  {$alice_topics_discussed[] = "king_secret"}
{/}

+ [Continue talking] -> TalkToAlice

=== AliceGift ===
{$hasFlowers = false}
{$rel_alice += 20}

Alice's eyes light up. "Flowers! For me?"

{whisker.modify("rel_alice", 20, 0, 100)}
{$alice_attitude = "friendly"}

"Thank you so much!"

+ [Continue talking] -> TalkToAlice
```

### 10.7.3 Dialog with Barks

Short contextual responses based on state:

```whisker
=== AliceBark ===
// Quick reaction, returns to previous context
{$rel_alice < 25}
  Alice: "Hmph."
{$rel_alice >= 25 and $rel_alice < 75}
  Alice: "Hello."
{$rel_alice >= 75}
  Alice: "Oh, it's you! Hello, friend!"
{/}
->->

=== SomeOtherPassage ===
You see Alice in the market.
->-> AliceBark

She's examining vegetables.
+ [Approach her] -> TalkToAlice
+ [Keep walking] -> Market
```

### 10.7.4 Mood-Based Responses

```whisker
--- story
LIST moods = calm, happy, angry, sad, afraid
$npc_mood = calm
---

=== NPCReaction ===
{$npc_mood == happy}
  The merchant laughs heartily. "Welcome, welcome!"
{$npc_mood == angry}
  The merchant scowls. "What do you want?"
{$npc_mood == sad}
  The merchant sighs deeply. "Oh... hello."
{$npc_mood == afraid}
  The merchant looks around nervously. "Y-yes?"
{else}
  The merchant nods. "How can I help you?"
{/}
```

## 10.8 Stat Screen Pattern

A common requirement is displaying character statistics or inventory status accessible from any point in the story.

### 10.8.1 Basic Stat Screen

```whisker
--- story
$playerName = "Hero"
$health = 100
$maxHealth = 100
$gold = 50
$level = 1
$xp = 0
$xpNeeded = 100
---

FUNCTION showStats()
  === StatScreen ===
  @tags: system, no-save

  ╔══════════════════════════╗
  ║     CHARACTER STATS      ║
  ╠══════════════════════════╣
  ║ Name:   $playerName      ║
  ║ Level:  $level           ║
  ║ Health: $health/$maxHealth  ║
  ║ Gold:   $gold            ║
  ║ XP:     $xp/$xpNeeded    ║
  ╚══════════════════════════╝

  + [Return] ->-> // Tunnel back
END

:: AnyPassage
You see a door ahead.
+ [Check Stats] ->-> StatScreen
+ [Continue] -> NextRoom
```

### 10.8.2 Stat Screen with Inventory

```whisker
ARRAY inventory = []
LIST equipped = sword, shield  // Currently equipped

=== InventoryScreen ===
@tags: system

**Inventory** (${#$inventory} items)
{ #$inventory == 0 }
  Empty!
{else}
  {{
    for i, item in ipairs(whisker.state.get("inventory")) do
      whisker.output("- " .. item .. "\n")
    end
  }}
{/}

**Equipped**:
{ $equipped ? sword } Sword (equipped) {/}
{ $equipped ? shield } Shield (equipped) {/}

+ [Return] ->->
```

### 10.8.3 Tab-Based Stat Screen

```whisker
$currentTab = "stats"

=== StatScreen ===
@tags: system

// Tab header
[ {$currentTab == "stats"} **STATS** {else} Stats {/} ]
[ {$currentTab == "inventory"} **INVENTORY** {else} Inventory {/} ]
[ {$currentTab == "quests"} **QUESTS** {else} Quests {/} ]

// Tab content
{$currentTab == "stats"}
  Name: $playerName
  Health: $health / $maxHealth
  Level: $level
{$currentTab == "inventory"}
  Gold: $gold coins
  Items: ${#$inventory}
{$currentTab == "quests"}
  Active Quests: ${#$activeQuests}
  Completed: ${#$completedQuests}
{/}

// Tab navigation
* {$currentTab ~= "stats"} [View Stats] {$currentTab = "stats"} -> StatScreen
* {$currentTab ~= "inventory"} [View Inventory] {$currentTab = "inventory"} -> StatScreen
* {$currentTab ~= "quests"} [View Quests] {$currentTab = "quests"} -> StatScreen
+ [Close] ->->
```

### 10.8.4 Always-Visible Status Bar

For runtimes that support it, a status bar can be rendered separately:

```whisker
FUNCTION renderStatusBar()
  {{
    -- This is called by the runtime to get status bar content
    local hp = whisker.state.get("health")
    local maxHp = whisker.state.get("maxHealth")
    local gold = whisker.state.get("gold")

    return string.format("HP: %d/%d | Gold: %d", hp, maxHp, gold)
  }}
END
```

Runtime implementations can call this function to populate a persistent UI element.

---

**Previous Chapter:** [File Formats](08-FILE_FORMATS.md)
**Next Chapter:** [Modules](12-MODULES.md)

---


# Chapter 12: Modules

**Whisker Language Specification 1.0**

---

## 12.1 Overview

Modules provide code organization and reuse mechanisms for large Whisker projects. WLS supports three modularity features:

| Feature | Purpose | Syntax |
|---------|---------|--------|
| INCLUDE | Import external files | `INCLUDE "path/file.ws"` |
| FUNCTION | Define reusable logic | `FUNCTION name(params)...END` |
| NAMESPACE | Scope passage names | `NAMESPACE Name...END NAMESPACE` |

## 12.2 Include Directive

### 12.2.1 Basic Syntax

The INCLUDE directive imports content from external files:

```whisker
INCLUDE "path/to/file.ws"
```

**Rules:**
- INCLUDE must appear at the top of the file, before passages
- Paths are relative to the including file's location
- File extension `.ws` is required
- Quotes are required around the path

**Example:**

```whisker
// main.ws
INCLUDE "common/dialogs.ws"
INCLUDE "characters/merchant.ws"

:: Start
@tags: start
Welcome to the game!
+ [Talk to merchant] -> Merchant::Greeting
```

### 12.2.2 Path Resolution

Paths are resolved relative to the including file:

```
project/
├── main.ws              # INCLUDE "lib/utils.ws"
├── lib/
│   ├── utils.ws         # Resolved from main.ws
│   └── helpers.ws       # INCLUDE "helpers.ws" from utils.ws
└── chapters/
    └── chapter1.ws      # INCLUDE "../lib/utils.ws"
```

**Resolution Rules:**

| Path | Meaning |
|------|---------|
| `"file.ws"` | Same directory as including file |
| `"dir/file.ws"` | Subdirectory relative to including file |
| `"../file.ws"` | Parent directory |
| `"../dir/file.ws"` | Sibling directory |

### 12.2.3 Include Order

Files are processed in order of inclusion:

1. Parse the main file
2. For each INCLUDE (in order):
   - Resolve the file path
   - Parse the included file recursively
   - Merge content into the main story
3. Resolve all passage references

**Merging Rules:**

| Content | Merge Behavior |
|---------|----------------|
| Passages | Added to story (namespace-prefixed if applicable) |
| Variables | Merged into global @vars |
| Functions | Added to function registry |
| Metadata | First file's metadata takes precedence |

### 12.2.4 Circular Include Detection

Circular includes are forbidden and produce an error:

```whisker
// a.ws
INCLUDE "b.ws"  // OK

// b.ws
INCLUDE "a.ws"  // ERROR: WLS-MOD-002 circular_include
```

**Detection:**
- Track include stack during parsing
- Error if a file appears twice in the stack
- Report the circular chain in the error message

### 12.2.5 Error Codes

| Code | Name | Severity | Description |
|------|------|----------|-------------|
| WLS-MOD-001 | include_not_found | error | Included file does not exist |
| WLS-MOD-002 | circular_include | error | Circular include detected |

## 12.3 Functions

### 12.3.1 Basic Syntax

Functions define reusable logic blocks:

```whisker
FUNCTION name(param1, param2)
  // Function body
  RETURN value
END
```

**Components:**

| Component | Description |
|-----------|-------------|
| `FUNCTION` | Keyword starting definition |
| `name` | Valid identifier |
| `(params)` | Comma-separated parameter list |
| Body | Statements and expressions |
| `RETURN` | Optional return statement |
| `END` | Keyword ending definition |

**Example:**

```whisker
FUNCTION greet(name)
  RETURN "Hello, " .. name .. "!"
END

FUNCTION roll_dice(sides)
  RETURN math.random(1, sides)
END

:: Start
{= greet("Player") }
You rolled: {= roll_dice(6) }
```

### 12.3.2 Parameters

Parameters are passed by value:

```whisker
FUNCTION add(a, b)
  RETURN a + b
END

:: Test
Result: {= add(5, 3) }  // Outputs: Result: 8
```

**Parameter Rules:**
- Parameters are local to the function
- Modifications do not affect caller's variables
- Parameters can have any type (number, string, boolean, table)
- Missing arguments default to `nil`

### 12.3.3 Return Values

Use RETURN to provide a value from the function:

```whisker
FUNCTION calculate_damage(base, modifier)
  local damage = base * modifier
  RETURN damage
END

// Without RETURN, function returns nil
FUNCTION log_message(msg)
  // Side effect only
END
```

**Return Rules:**
- RETURN immediately exits the function
- Value is passed back to the caller
- Multiple RETURN statements allowed (only first executed)
- Omitting RETURN returns `nil`

### 12.3.4 Local Variables

Variables declared in functions are local:

```whisker
FUNCTION process()
  local temp = 100      // Local to function
  $global = 200         // Modifies story variable
  RETURN temp
END
```

**Scope Rules:**

| Declaration | Scope |
|-------------|-------|
| `local var` | Function only |
| `$var` | Story-wide (game state) |
| Parameters | Function only |

### 12.3.5 Recursion

Functions can call themselves with depth limits:

```whisker
FUNCTION factorial(n)
  IF n <= 1 THEN
    RETURN 1
  END
  RETURN n * factorial(n - 1)
END
```

**Recursion Limits:**
- Default max depth: 100 calls
- Exceeding limit raises WLS-MOD-005: stack_overflow
- Depth is tracked per call chain

### 12.3.6 Error Codes

| Code | Name | Severity | Description |
|------|------|----------|-------------|
| WLS-MOD-003 | undefined_function | error | Called function not defined |
| WLS-MOD-005 | stack_overflow | error | Recursion depth exceeded |
| WLS-MOD-006 | invalid_function_name | error | Function name not valid identifier |

## 12.4 Namespaces

### 12.4.1 Basic Syntax

Namespaces group related passages:

```whisker
NAMESPACE Merchant

:: Greeting
Welcome to my shop!
+ [Browse wares] -> Inventory
+ [Leave] -> ::Start  // Root namespace

:: Inventory
Here are my wares.

END NAMESPACE
```

**Rules:**
- NAMESPACE keyword followed by identifier
- All passages until END NAMESPACE are prefixed
- Internal references resolve within namespace
- Use `::` prefix for root/global passages

### 12.4.2 Qualified Names

Passages get fully qualified names:

```whisker
NAMESPACE Combat

:: Start           // Becomes Combat::Start
:: Attack          // Becomes Combat::Attack

END NAMESPACE

:: Start           // Global ::Start (no namespace)
+ [Fight] -> Combat::Start
```

**Name Resolution:**

| Reference | From Global | From Combat NS |
|-----------|-------------|----------------|
| `Start` | ::Start | Combat::Start |
| `Combat::Start` | Combat::Start | Combat::Start |
| `::Start` | ::Start | ::Start |

### 12.4.3 Nested Namespaces

Namespaces can be nested:

```whisker
NAMESPACE Game

NAMESPACE Combat
:: Attack          // Game::Combat::Attack
END NAMESPACE

NAMESPACE Dialog
:: Greeting        // Game::Dialog::Greeting
END NAMESPACE

END NAMESPACE
```

**Resolution in Nested Namespaces:**
- Relative references check current namespace first
- Then parent namespaces
- Finally global namespace
- Use `::` for explicit global access

### 12.4.4 Cross-Namespace Navigation

Navigate between namespaces using qualified names:

```whisker
NAMESPACE Town

:: Square
+ [Enter shop] -> Shop::Entrance
+ [Leave town] -> ::Wilderness::Entrance

END NAMESPACE

NAMESPACE Shop

:: Entrance
+ [Return to square] -> Town::Square

END NAMESPACE
```

### 12.4.5 Namespace and Include Interaction

Included files can define namespaces:

```whisker
// merchant.ws
NAMESPACE Merchant
:: Greeting
Hello!
END NAMESPACE

// main.ws
INCLUDE "merchant.ws"

:: Start
+ [Talk to merchant] -> Merchant::Greeting
```

**Conflict Rules:**
- Duplicate qualified passage names are errors
- Same namespace in multiple files merges content
- Conflicts raise WLS-MOD-004

### 12.4.6 Error Codes

| Code | Name | Severity | Description |
|------|------|----------|-------------|
| WLS-MOD-004 | namespace_conflict | error | Duplicate qualified passage name |
| WLS-MOD-007 | invalid_namespace_name | error | Namespace name not valid identifier |
| WLS-MOD-008 | unmatched_end_namespace | error | END NAMESPACE without NAMESPACE |

## 12.5 Complete Example

```whisker
// game.ws - Main game file
@title: Modular Adventure
@author: Whisker Team

INCLUDE "lib/combat.ws"
INCLUDE "lib/inventory.ws"
INCLUDE "chapters/intro.ws"

// Global functions
FUNCTION check_health()
  IF $health <= 0 THEN
    RETURN "dead"
  ELIF $health < 20 THEN
    RETURN "critical"
  ELSE
    RETURN "healthy"
  END
END

:: Start
@tags: start
Welcome, $playerName!
Your status: {= check_health() }

+ [Check inventory] -> Inventory::Main
+ [Enter combat] -> Combat::Arena
+ [Begin adventure] -> Intro::Beginning
```

```whisker
// lib/combat.ws
NAMESPACE Combat

FUNCTION roll_attack(base)
  RETURN base + math.random(1, 6)
END

:: Arena
Prepare for battle!
+ [Attack] -> Attack
+ [Flee] -> ::Start

:: Attack
@onEnter: $lastAttack = roll_attack($strength)
You strike for {$lastAttack} damage!
+ [Continue] -> Arena

END NAMESPACE
```

```whisker
// lib/inventory.ws
NAMESPACE Inventory

:: Main
Your inventory:
{ $hasKey }
- Rusty Key
{/}
{ $gold > 0 }
- Gold: $gold
{/}

+ [Back] -> ::Start

END NAMESPACE
```

## 12.6 Error Code Summary

| Code | Name | Severity | Category |
|------|------|----------|----------|
| WLS-MOD-001 | include_not_found | error | modules |
| WLS-MOD-002 | circular_include | error | modules |
| WLS-MOD-003 | undefined_function | error | modules |
| WLS-MOD-004 | namespace_conflict | error | modules |
| WLS-MOD-005 | stack_overflow | error | modules |
| WLS-MOD-006 | invalid_function_name | error | modules |
| WLS-MOD-007 | invalid_namespace_name | error | modules |
| WLS-MOD-008 | unmatched_end_namespace | error | modules |

## 12.7 Implementation Notes

### 12.7.1 Parser Requirements

The parser must:
1. Recognize INCLUDE, FUNCTION, NAMESPACE, END, RETURN keywords
2. Track current namespace context during parsing
3. Generate fully qualified passage names
4. Build function registry during parsing
5. Handle nested namespace stacks

### 12.7.2 Runtime Requirements

The runtime must:
1. Load and merge included files
2. Maintain function call stack
3. Resolve namespace-qualified passage references
4. Enforce recursion limits
5. Handle local variable scoping in functions

### 12.7.3 Validation Requirements

Validators must check:
1. Include file existence
2. Circular include chains
3. Function existence before calls
4. Namespace-qualified link validity
5. Duplicate qualified passage names

---


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

#### 14.2.3.1 Extended Hover Content

**Keyword Hover:**

| Keyword | Hover Content |
|---------|---------------|
| `if` | "Conditional block. Evaluates expression and executes body if truthy." |
| `else` | "Alternative branch. Executes if preceding condition was false." |
| `let` | "Local variable declaration. Scoped to current passage." |
| `LIST` | "Enumerated set declaration. Use parentheses for initially active values." |
| `INCLUDE` | "Import external Whisker module. Path relative to current file." |

**Navigation Target Hover:**

```
-> Shop
─────────────────────
Target: :: Shop (line 145)
Tags: [commerce, npc]
Visit count: {runtime}
Contains: 4 choices, 2 variables
Preview:
  "Welcome to the shop!
   What would you like to buy?"
```

**Alternative Hover:**

```
{| First | Second | Third }
─────────────────────
Type: Sequence alternative
Options: 3
Current index: {runtime state}
Name: (unnamed)
State key: "Passage:0"
```

**Choice Hover:**

```
+ [Buy sword] {$gold -= 50} -> Armory
─────────────────────
Type: Sticky choice (always shown)
Text: "Buy sword"
Condition: none
Action: $gold -= 50
Target: :: Armory (line 200)
```

**Operator Hover:**

| Operator | Hover Content |
|----------|---------------|
| `~=` | "Not equal. Alias: `!=`. Returns true if operands differ." |
| `..` | "String concatenation. Joins two strings or coerces numbers." |
| `?` | "Contains operator. For lists, checks if value is active." |
| `#` | "Length operator. Returns count of elements in collection." |

**Lua Block Hover:**

```
{{ whisker.state.get("gold") }}
─────────────────────
Inline Lua expression
Sandbox: enabled
Returns: value of $gold variable
API calls: whisker.state.get
```

**Error Position Hover:**

When hovering over an error-marked region:
```
[Error] WLS-SYN-002
─────────────────────
Unclosed brace
Opened at line 10, column 5
Expected: }
Suggestion: Add closing brace
Quick fix available: Insert "}"
```

#### 14.2.3.2 Hover Response Format

```json
{
  "contents": {
    "kind": "markdown",
    "value": "**$gold** (story variable)\n\n---\n\nType: `number`\nInitial: `100`\nUsed in: 5 passages"
  },
  "range": {
    "start": { "line": 10, "character": 5 },
    "end": { "line": 10, "character": 10 }
  }
}
```

**Hover Priority** (when multiple hovers apply):
1. Error/diagnostic information
2. Symbol definition (variable, function, passage)
3. Operator/keyword documentation
4. Syntax structure explanation

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

### 14.5.5 Code Folding

Code folding enables collapsing sections for improved navigation.

**Foldable Regions:**

| Region Type | Start Pattern | End Pattern | Example |
|-------------|---------------|-------------|---------|
| Passage | `:: Name` | Next `::` or EOF | `:: Kitchen` |
| Conditional | `{$cond}` or `{if ...}` | `{/}` | `{$hasKey}...{/}` |
| Block Lua | `{{` (with newline) | `}}` | `{{ ... }}` |
| Function block | `FUNCTION name()` | `END` | Lua functions |
| Choice block | First `*` or `+` | Gather or next section | Choice groups |
| Comments | `/*` | `*/` | Block comments |

**LSP Folding Range Request:**

```json
// textDocument/foldingRange response
{
  "result": [
    {
      "startLine": 10,
      "startCharacter": 0,
      "endLine": 25,
      "endCharacter": 0,
      "kind": "region",
      "collapsedText": ":: Kitchen"
    },
    {
      "startLine": 15,
      "startCharacter": 0,
      "endLine": 20,
      "endCharacter": 3,
      "kind": "region",
      "collapsedText": "{if $hasKey}..."
    }
  ]
}
```

**Folding Kind Mapping:**

| WLS Construct | LSP FoldingRangeKind |
|---------------|---------------------|
| Passage | `region` |
| Conditional | `region` |
| Block comment | `comment` |
| Imports | `imports` |
| Block Lua | `region` |

**Manual Fold Markers:**

Authors may define custom fold regions with comments:

```whisker
// #region Inventory System
$gold = 100
$items = []
// ... inventory code ...
// #endregion

// #region Combat
$health = 100
$attack = 10
// #endregion
```

Implementations SHOULD recognize `#region` and `#endregion` comment markers.

**Folding Behavior:**

| Scenario | Behavior |
|----------|----------|
| Nested folds | All levels independently foldable |
| Invalid syntax | Best-effort folding, may be incomplete |
| Large passage | Fold entire passage from header |
| Choice cascade | Fold from first choice to gather |
| Cross-file reference | Not foldable (different document) |

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

### 14.8.6 Incremental Update Protocol

For LSP implementations, use this change notification protocol:

```typescript
interface IncrementalUpdate {
  // Document identifier
  uri: string;
  version: number;

  // Change range
  range: {
    start: { line: number; character: number };
    end: { line: number; character: number };
  };

  // New text for range
  text: string;

  // Affected scope (computed by parser)
  affectedScope: "line" | "passage" | "file" | "project";

  // Passages needing revalidation
  invalidatedPassages: string[];
}
```

### 14.8.7 Parse State Management

Maintain these caches for incremental updates:

| Cache | Granularity | Invalidation Trigger |
|-------|-------------|---------------------|
| Line tokens | Per-line | Line edit |
| Passage AST | Per-passage | Any edit in passage |
| Symbol table | Per-file | Declaration change |
| Cross-references | Per-project | Navigation target change |
| Diagnostics | Per-passage | AST change |

### 14.8.8 Partial Parse Recovery

When a partial parse fails, implementations SHOULD:

1. Mark affected passage as "error"
2. Preserve last valid AST for unchanged passages
3. Continue providing completions using partial information
4. Highlight error region without blocking other features

```
Valid state:  [Passage A ✓] [Passage B ✓] [Passage C ✓]
After error:  [Passage A ✓] [Passage B ✗] [Passage C ✓]
                            ↑ partial parse, show error
                            ↑ but don't invalidate A or C
```

### 14.8.9 Tree-Sitter Integration

For editors using Tree-Sitter, WLS provides:

```scheme
;; tree-sitter-whisker queries
(passage_declaration name: (identifier) @definition.passage)
(choice_statement text: (choice_text) @markup.list)
(variable (story_variable) @variable.other)
(variable (temp_variable) @variable.local)
(navigation target: (identifier) @reference.passage)
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

## 14.10 Story Graph Visualization

This section specifies data formats for story graph visualization tools.

### 14.10.1 Graph Export Format

Tools SHOULD export story graphs in this JSON format:

```json
{
  "format": "wls-graph",
  "version": "1.0",
  "story": {
    "title": "Story Title",
    "start": "Start"
  },
  "nodes": [
    {
      "id": "Start",
      "type": "passage",
      "label": "Start",
      "tags": ["intro"],
      "word_count": 150,
      "choice_count": 3,
      "position": { "x": 0, "y": 0 }
    }
  ],
  "edges": [
    {
      "source": "Start",
      "target": "Forest",
      "type": "choice",
      "label": "Enter the forest",
      "condition": "$courage > 5"
    }
  ],
  "metadata": {
    "total_passages": 45,
    "total_choices": 120,
    "max_depth": 12,
    "branches": 8,
    "endings": 5
  }
}
```

### 14.10.2 Node Types

| Type | Description | Visual Suggestion |
|------|-------------|-------------------|
| `passage` | Normal passage | Rectangle |
| `start` | Start passage | Rectangle with thick border |
| `ending` | Terminal passage | Double rectangle |
| `hub` | High-connectivity passage | Hexagon |
| `checkpoint` | Save point | Diamond |

### 14.10.3 Edge Types

| Type | Description | Visual Suggestion |
|------|-------------|-------------------|
| `choice` | Player choice | Solid arrow |
| `auto` | Automatic navigation | Dashed arrow |
| `tunnel` | Tunnel call | Dotted arrow |
| `conditional` | Condition-gated | Colored arrow |
| `fallback` | Fallback navigation | Gray arrow |

### 14.10.4 Layout Algorithms

Recommended layout algorithms for story graphs:

| Algorithm | Use Case |
|-----------|----------|
| Hierarchical | Linear stories with clear progression |
| Force-directed | Highly interconnected stories |
| Radial | Hub-and-spoke structures |
| Layered | Stories with clear acts/chapters |

### 14.10.5 Analysis Metrics

Visualization tools SHOULD compute:

| Metric | Description |
|--------|-------------|
| Reachability | Passages reachable from start |
| Bottlenecks | Single-entry points |
| Dead ends | Passages with no exits |
| Cycles | Loops in the graph |
| Complexity | Cyclomatic complexity per passage |
| Coverage | Percentage of paths tested |

---


# Appendix A: Error Codes Reference

This appendix provides a comprehensive reference for all WLS error codes.

## Error Code Format

All WLS error codes follow the format:

```
WLS-{CATEGORY}-{NUMBER}
```

Where:
- `WLS` - Whisker Language Specification prefix
- `{CATEGORY}` - Three-letter category code
- `{NUMBER}` - Three-digit error number (001-999)

## Categories

| Code | Category | Description |
|------|----------|-------------|
| STR | Structure | Story structure and organization |
| LNK | Links | Passage links and navigation |
| VAR | Variables | Variable declarations and usage |
| EXP | Expressions | Expression syntax and evaluation |
| FLW | Flow | Story flow and logic |
| QUA | Quality | Code quality and best practices |
| SYN | Syntax | General syntax errors |
| AST | Assets | Media and asset handling |
| META | Metadata | Story metadata |
| SCR | Scripts | Script blocks and Lua code |
| COL | Collections | LIST, ARRAY, MAP declarations |
| MOD | Modules | INCLUDE, FUNCTION, NAMESPACE |
| PRS | Presentation | Rich text, CSS, media, theming |
| DEV | Developer | Developer tools and debugging |

## Severity Levels

| Level | Description | Exit Code |
|-------|-------------|-----------|
| error | Must be fixed, prevents execution | 1 |
| warning | Should be fixed, may cause issues | 0 |
| info | Informational, best practices | 0 |

---

## Structure (STR)

### WLS-STR-001: missing_start_passage

**Severity:** error

**Message:** No start passage defined

**Description:** Every story must have a passage named "Start" or specify a start passage via `@start:` directive.

**Example (invalid):**
```whisker
@title: My Story

:: Chapter1
You begin your journey...
```

**Fix:**
```whisker
@title: My Story

:: Start
You begin your journey...
```

Or use the `@start:` directive:
```whisker
@title: My Story
@start: Chapter1

:: Chapter1
You begin your journey...
```

---

### WLS-STR-002: unreachable_passage

**Severity:** warning

**Message:** Passage "{passageName}" is unreachable

**Description:** This passage cannot be reached from the start passage through any path of choices.

**Example:**
```whisker
:: Start
Welcome!
+ [Continue] -> Chapter1

:: Chapter1
The adventure begins.

:: SecretEnding
-- This passage has no links pointing to it
You found the secret!
```

**Fix:** Either add a link to the passage or remove it if unused.

---

### WLS-STR-003: duplicate_passage

**Severity:** error

**Message:** Duplicate passage name: "{passageName}"

**Description:** Multiple passages have the same name.

**Example (invalid):**
```whisker
:: Start
First passage.

:: Start
Duplicate passage!
```

**Fix:** Give each passage a unique name.

---

### WLS-STR-004: empty_passage

**Severity:** warning

**Message:** Passage "{passageName}" is empty

**Description:** This passage has no content and no choices.

**Example:**
```whisker
:: EmptyRoom
```

**Fix:** Add content or choices, or remove the passage.

---

### WLS-STR-005: orphan_passage

**Severity:** info

**Message:** Passage "{passageName}" has no incoming links

**Description:** No other passages link to this passage (except if it's the start passage).

---

### WLS-STR-006: no_terminal

**Severity:** info

**Message:** Story has no terminal passages

**Description:** The story has no passages that end the story (via `-> END` or having no choices).

---

## Links (LNK)

### WLS-LNK-001: dead_link

**Severity:** error

**Message:** Choice links to non-existent passage: "{targetPassage}"

**Description:** The target passage does not exist in the story.

**Example (invalid):**
```whisker
:: Start
+ [Go to shop] -> Shopp
```

**Fix:**
```whisker
:: Start
+ [Go to shop] -> Shop

:: Shop
Welcome to the shop!
```

---

### WLS-LNK-002: self_link_no_change

**Severity:** warning

**Message:** Choice links to same passage without state change

**Description:** This choice links back to the same passage without any action, potentially causing an infinite loop.

**Example:**
```whisker
:: Loop
You are stuck.
+ [Try again] -> Loop
```

**Fix:** Add a state change or use a different target:
```whisker
:: Loop
You are stuck.
+ [Try again] {do $attempts += 1} -> Loop
```

---

### WLS-LNK-003: special_target_case

**Severity:** warning

**Message:** Special target "{actual}" should be "{expected}"

**Description:** Special targets (END, BACK, RESTART) must be uppercase.

**Example (invalid):**
```whisker
+ [End game] -> end
```

**Fix:**
```whisker
+ [End game] -> END
```

---

### WLS-LNK-004: back_on_start

**Severity:** warning

**Message:** BACK used on start passage

**Description:** Using BACK on the start passage has no effect since there's no history.

---

### WLS-LNK-005: empty_choice_target

**Severity:** error

**Message:** Choice has no target

**Description:** Every choice must have a target passage or special target.

---

## Variables (VAR)

### WLS-VAR-001: undefined_variable

**Severity:** error

**Message:** Undefined variable: "{variableName}"

**Description:** This variable is used before it is defined.

**Example (invalid):**
```whisker
:: Start
You have ${gold} gold.
```

**Fix:**
```whisker
@vars
  $gold = 100
@/vars

:: Start
You have ${gold} gold.
```

---

### WLS-VAR-002: unused_variable

**Severity:** warning

**Message:** Unused variable: "{variableName}"

**Description:** This variable is declared but never used.

---

### WLS-VAR-003: invalid_variable_name

**Severity:** error

**Message:** Invalid variable name: "{variableName}"

**Description:** Variable names must start with a letter or underscore and contain only alphanumerics.

---

### WLS-VAR-004: reserved_prefix

**Severity:** warning

**Message:** Variable uses reserved prefix: "{variableName}"

**Description:** Variables starting with "whisker_" or "__" are reserved.

---

### WLS-VAR-005: shadowing

**Severity:** warning

**Message:** Temporary variable shadows story variable: "{variableName}"

**Description:** A temp variable (`$_var`) has the same name as a story variable (`$var`).

---

### WLS-VAR-006: lone_dollar

**Severity:** warning

**Message:** Lone $ not followed by variable name

**Description:** A `$` character appears but is not followed by a valid variable name.

---

### WLS-VAR-007: unclosed_interpolation

**Severity:** error

**Message:** Unclosed expression interpolation

**Description:** An expression interpolation `${` is not closed with `}`.

---

### WLS-VAR-008: temp_cross_passage

**Severity:** error

**Message:** Temp variable used in different passage: "{variableName}"

**Description:** Temporary variables (`$_var`) are only valid within the passage where they are defined.

---

## Expressions (EXP)

### WLS-EXP-001: empty_expression

**Severity:** error

**Message:** Empty expression

**Description:** An expression block `${}` or condition `{}` is empty.

---

### WLS-EXP-002: unclosed_block

**Severity:** error

**Message:** Unclosed conditional block

**Description:** A conditional block `{` is not closed with `{/}`.

---

### WLS-EXP-003: assignment_in_condition

**Severity:** warning

**Message:** Assignment in condition (did you mean ==?)

**Description:** Single `=` (assignment) used in a condition where `==` (comparison) was likely intended.

---

### WLS-EXP-004: missing_operand

**Severity:** error

**Message:** Missing operand in expression

**Description:** A binary operator is missing an operand.

---

### WLS-EXP-005: invalid_operator

**Severity:** error

**Message:** Invalid operator: "{operator}"

**Description:** An unknown or invalid operator is used.

---

### WLS-EXP-006: unmatched_parenthesis

**Severity:** error

**Message:** Unmatched parenthesis

**Description:** Parentheses are not balanced.

---

### WLS-EXP-007: incomplete_expression

**Severity:** error

**Message:** Incomplete expression

**Description:** Expression is syntactically incomplete.

---

## Flow (FLW)

### WLS-FLW-001: dead_end

**Severity:** info

**Message:** Passage "{passageName}" is a dead end

**Description:** This passage has no choices and is not a terminal passage.

---

### WLS-FLW-002: bottleneck

**Severity:** info

**Message:** Passage "{passageName}" is a bottleneck

**Description:** All paths through the story must pass through this passage.

---

### WLS-FLW-003: cycle_detected

**Severity:** info

**Message:** Story contains cycles

**Description:** The story contains cycles (loops back to earlier passages).

---

### WLS-FLW-004: infinite_loop

**Severity:** warning

**Message:** Potential infinite loop in "{passageName}"

**Description:** A potential infinite loop exists with no exit condition.

---

### WLS-FLW-005: unreachable_choice

**Severity:** warning

**Message:** Choice condition is always false

**Description:** This choice can never be selected because its condition is always false.

---

### WLS-FLW-006: always_true_condition

**Severity:** info

**Message:** Choice condition is always true

**Description:** This choice condition is always true and could be simplified.

---

## Quality (QUA)

### WLS-QUA-001: low_branching

**Severity:** info

**Message:** Low branching factor ({value})

**Description:** Average choices per passage is below threshold.

---

### WLS-QUA-002: high_complexity

**Severity:** info

**Message:** High story complexity

**Description:** Story complexity score exceeds threshold.

---

### WLS-QUA-003: long_passage

**Severity:** info

**Message:** Passage "{passageName}" is very long ({wordCount} words)

**Description:** This passage exceeds the word count threshold.

---

### WLS-QUA-004: deep_nesting

**Severity:** warning

**Message:** Deep conditional nesting ({depth} levels)

**Description:** Conditional nesting exceeds recommended depth.

---

### WLS-QUA-005: many_variables

**Severity:** info

**Message:** Story has many variables ({count})

**Description:** Story has more variables than threshold.

---

## Syntax (SYN)

### WLS-SYN-001: syntax_error

**Severity:** error

**Message:** Syntax error in "{passageName}"

**Description:** Parse error in passage content.

---

### WLS-SYN-002: unmatched_braces

**Severity:** error

**Message:** Unmatched braces in stylesheet

**Description:** Opening and closing braces are not balanced.

---

### WLS-SYN-003: unmatched_keywords

**Severity:** error

**Message:** Unmatched Lua keywords

**Description:** Lua keywords like `function`/`end` or `if`/`then` are not balanced.

---

## Assets (AST)

### WLS-AST-001 through WLS-AST-007

Asset-related errors for missing IDs, paths, broken references, and unused assets.

---

## Metadata (META)

### WLS-META-001 through WLS-META-005

Metadata errors for missing or invalid IFID, dimensions, and reserved keys.

---

## Scripts (SCR)

### WLS-SCR-001 through WLS-SCR-004

Script errors for empty scripts, syntax errors, unsafe functions, and large scripts.

---

## Collections (COL) - WLS Gap 3

### WLS-COL-001: duplicate_list_value

**Severity:** error

**Message:** Duplicate value "{value}" in LIST "{listName}"

**Description:** LIST declarations cannot have duplicate values.

---

### WLS-COL-002 through WLS-COL-010

Collection errors for empty lists, invalid values, duplicate indices/keys, and undefined collections.

---

## Modules (MOD) - WLS Gap 4

### WLS-MOD-001: include_not_found

**Severity:** error

**Message:** Include file not found: "{path}"

**Description:** The file specified in INCLUDE directive does not exist.

---

### WLS-MOD-002 through WLS-MOD-008

Module errors for circular includes, undefined functions, namespace conflicts, and unmatched END NAMESPACE.

---

## Presentation (PRS) - WLS Gap 5

### WLS-PRS-001: invalid_markdown

**Severity:** error

**Message:** Invalid markdown syntax: {detail}

**Description:** The markdown formatting is malformed.

---

### WLS-PRS-002 through WLS-PRS-008

Presentation errors for invalid CSS classes, missing media, invalid themes, and style issues.

---

## Developer Experience (DEV) - WLS Gap 6

### WLS-DEV-001: lsp_connection_failed

**Severity:** error

**Message:** Failed to connect to language server

**Description:** The language server could not be started or connected to.

---

### WLS-DEV-002: debug_adapter_error

**Severity:** error

**Message:** Debug adapter protocol error: {detail}

**Description:** An error occurred in the debug adapter.

---

### WLS-DEV-003: format_parse_error

**Severity:** error

**Message:** Cannot format: file has parse errors

**Description:** The file cannot be formatted because it contains syntax errors.

---

### WLS-DEV-004: preview_runtime_error

**Severity:** warning

**Message:** Error during story preview: {detail}

**Description:** A runtime error occurred while previewing the story.

---

### WLS-DEV-005: breakpoint_invalid_location

**Severity:** warning

**Message:** Breakpoint at invalid location: line {line}

**Description:** A breakpoint was set at a location that cannot be executed.

---

## Error Message Format

WLS uses a standardized error message format:

```
WLS-XXX-NNN: Brief description at line L, column C

  L-2 | context line before
  L-1 | context line before
> L   | source line with error
           ^^^^
           Explanation of the error

Suggestion: How to fix
See: https://wls.whisker.dev/errors/WLS-XXX-NNN
```

### Example

```
WLS-LNK-001: Choice links to non-existent passage at line 5, column 8

  3 | Welcome to the adventure!
  4 |
> 5 | + [Go to shop] -> Shopp
                         ^^^^^
                         Passage "Shopp" does not exist

Suggestion: Did you mean "Shop"?
See: https://wls.whisker.dev/errors/WLS-LNK-001
```

---


# Appendix B: Save State Schema

This appendix defines the standard JSON format for WLS save states, enabling portable saves across implementations.

## B.1 Overview

Save states capture the complete runtime state of a story at a specific moment, allowing:
- Save/load functionality
- Cross-implementation portability
- Debugging and testing
- Analytics and telemetry

## B.2 JSON Schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "WLS Save State",
  "type": "object",
  "required": ["wls_version", "current_passage", "variables"],
  "properties": {
    "wls_version": {
      "type": "string",
      "description": "WLS specification version",
      "pattern": "^\\d+\\.\\d+\\.\\d+$"
    },
    "save_version": {
      "type": "string",
      "description": "Save format version",
      "default": "1"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "description": "ISO 8601 timestamp when save was created"
    },
    "current_passage": {
      "type": "string",
      "description": "Name of the current passage"
    },
    "variables": {
      "type": "object",
      "description": "All story variables (not temporaries)",
      "additionalProperties": true
    },
    "history": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Passage visit history (oldest first)"
    },
    "tunnel_stack": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "passage": { "type": "string" },
          "return_line": { "type": "integer" }
        }
      },
      "description": "Active tunnel return points"
    },
    "alternative_state": {
      "type": "object",
      "description": "Text alternative visit counts",
      "additionalProperties": { "type": "integer" }
    },
    "exhausted_choices": {
      "type": "object",
      "description": "Once-only choices that have been selected",
      "additionalProperties": {
        "type": "array",
        "items": { "type": "integer" }
      }
    },
    "hooks": {
      "type": "object",
      "description": "Hook states",
      "additionalProperties": {
        "type": "object",
        "properties": {
          "content": { "type": "string" },
          "visible": { "type": "boolean" }
        }
      }
    },
    "random_seed": {
      "type": "integer",
      "description": "RNG state for deterministic replay (optional)"
    },
    "custom": {
      "type": "object",
      "description": "Implementation-specific data (optional)"
    }
  }
}
```

## B.3 Example Save State

```json
{
  "wls_version": "1.0.0",
  "save_version": "1",
  "timestamp": "2026-01-17T12:34:56Z",
  "current_passage": "Forest",
  "variables": {
    "gold": 150,
    "playerName": "Hero",
    "hasKey": true,
    "inventory": ["sword", "potion", "map"],
    "stats": {
      "health": 85,
      "maxHealth": 100,
      "level": 3
    }
  },
  "history": [
    "Start",
    "Village",
    "Shop",
    "Village",
    "Forest"
  ],
  "tunnel_stack": [],
  "alternative_state": {
    "OldMan:0": 2,
    "OldMan:1": 1,
    "Forest:greeting": 3
  },
  "exhausted_choices": {
    "Shop": [0, 2],
    "Tavern": [1]
  },
  "hooks": {
    "statusBar": {
      "content": "Health: 85/100 | Gold: 150",
      "visible": true
    },
    "questLog": {
      "content": "Find the hidden temple",
      "visible": true
    }
  },
  "random_seed": 42
}
```

## B.4 Field Specifications

### B.4.1 Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `wls_version` | string | Spec version story targets (e.g., "1.0.0") |
| `current_passage` | string | Passage name where player is located |
| `variables` | object | All story-scoped variables |

### B.4.2 Optional Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `save_version` | string | "1" | Save format version for migration |
| `timestamp` | string | - | ISO 8601 creation time |
| `history` | array | `[]` | Passage visit history |
| `tunnel_stack` | array | `[]` | Active tunnel return points |
| `alternative_state` | object | `{}` | Visit counts per alternative |
| `exhausted_choices` | object | `{}` | Selected once-only choice indices |
| `hooks` | object | `{}` | Modified hook states |
| `random_seed` | integer | - | RNG state for replay |
| `custom` | object | `{}` | Implementation-specific data |

### B.4.3 Variable Serialization

| WLS Type | JSON Type | Example |
|----------|-----------|---------|
| Number | number | `42`, `3.14` |
| String | string | `"hello"` |
| Boolean | boolean | `true`, `false` |
| Array | array | `[1, 2, 3]` |
| Map | object | `{"key": "value"}` |
| List | object | `{"_type": "list", "active": ["happy"], "all": ["happy", "sad"]}` |
| nil | null | `null` |

### B.4.4 Alternative State Keys

Alternative state keys follow the format: `PassageName:index` or `PassageName:name`

- Index-based (unnamed): `"Forest:0"` = first alternative in Forest passage
- Name-based (named): `"Forest:greeting"` = alternative named "greeting"

### B.4.5 Exhausted Choices Keys

Keys are passage names; values are arrays of choice indices (0-based):

```json
{
  "Shop": [0, 2],    // First and third choices exhausted
  "Tavern": [1]      // Second choice exhausted
}
```

## B.5 Save/Load Operations

### B.5.1 Saving

```lua
-- Get save state as JSON string
local saveJson = whisker.save.toJson()

-- Get save state as Lua table
local saveTable = whisker.save.toTable()

-- Save with custom slot name
whisker.save.save("slot1")
```

### B.5.2 Loading

```lua
-- Load from JSON string
whisker.save.fromJson(jsonString)

-- Load from Lua table
whisker.save.fromTable(saveTable)

-- Load from named slot
whisker.save.load("slot1")
```

### B.5.3 Validation

Implementations MUST validate saves before loading:

1. Check `wls_version` compatibility
2. Verify `current_passage` exists
3. Validate variable types match declarations
4. Check for required fields

Invalid saves SHOULD produce error WLS-SAVE-001 with specific failure reason.

## B.6 Migration

When loading a save from a different `save_version`:

1. Check if migration path exists
2. Transform data structure as needed
3. Log migration actions
4. Update `save_version` field

### B.6.1 Version 1 → 2 (Example)

```lua
if save.save_version == "1" then
  -- Migrate alternative_state key format
  for key, value in pairs(save.alternative_state) do
    -- Old: "PassageName:0" → New: "PassageName::0"
    local newKey = key:gsub(":", "::")
    save.alternative_state[newKey] = value
  end
  save.save_version = "2"
end
```

## B.7 Implementation Requirements

1. Implementations MUST support JSON save format
2. Implementations MUST validate saves before loading
3. Implementations MUST NOT corrupt saves on error
4. Implementations SHOULD support save compression
5. Implementations MAY add custom fields in `custom` object
6. Implementations MUST preserve unknown fields when re-saving

## B.8 Security Considerations

1. **Input validation**: Sanitize all loaded values
2. **Size limits**: Reject saves exceeding reasonable size (recommend 1MB)
3. **Injection prevention**: Don't evaluate save content as code
4. **Integrity**: Consider checksums for save validation

---

# Appendix C: Implementation Limits

Conformant implementations MUST support at least these minimums:

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| Conditional nesting depth | 50 | 100 |
| Tunnel call depth | 100 | 1000 |
| History entries | 1000 | 10000 |
| Story variables | 1000 | 10000 |
| Temp variables per passage | 100 | 1000 |
| String length | 1 MB | 16 MB |
| Array elements | 10000 | 100000 |
| Map entries | 10000 | 100000 |
| Passage content size | 1 MB | 16 MB |
| Identifier length | 255 | 1024 |
| Include depth | 10 | 50 |

Implementations MAY provide configuration to adjust these limits.

Exceeding limits SHOULD produce appropriate WLS-LIM-* errors.

---

# Appendix D: Migration Guides

This appendix provides migration tables for users coming from other interactive fiction systems.

## D.1 Ink to WLS

| Ink | WLS | Notes |
|-----|-----|-------|
| `=== knot ===` | `=== Passage ===` | Same syntax |
| `= stitch` | Use namespaces | `namespace::passage` |
| `* choice` | `+ [choice]` | Once-only |
| `+ sticky` | `* [choice]` | Sticky |
| `-> knot` | `-> Passage` | Same syntax |
| `<- knot` | `->-> Passage` | Tunnel |
| `->->` | `->->` | Same (return) |
| `VAR x = 5` | `$x = 5` | In header |
| `~ x = 5` | `{$x = 5}` | Assignment |
| `{condition:}` | `{$condition}...{/}` | Block conditional |
| `{x}` | `$x` | Interpolation |
| `{~a|b|c}` | `{~\|a\|b\|c}` | Shuffle |
| `{&a|b|c}` | `{&\|a\|b\|c}` | Cycle |
| `{!a|b|c}` | `{!\|a\|b\|c}` | Once |
| `INCLUDE file` | `#include "file"` | Module import |
| `LIST items` | `LIST items` | Same syntax |
| `!=` | `~=` | Not equal (Lua style) |

## D.2 Twine (Harlowe) to WLS

| Harlowe | WLS | Notes |
|---------|-----|-------|
| `::Passage` | `=== Passage ===` | Passage declaration |
| `[[Link]]` | `+ [Link] -> Link` | Choice + navigation |
| `[[Text->Target]]` | `+ [Text] -> Target` | Labeled link |
| `(set: $x to 5)` | `{$x = 5}` | Assignment |
| `(if: $x > 0)` | `{$x > 0}...{/}` | Conditional |
| `(else:)` | `{else}...{/}` | Else clause |
| `(print: $x)` | `$x` | Interpolation |
| `(either: "a", "b")` | `{~\|a\|b}` | Random pick |
| `(cycling-link:)` | `{&\|a\|b\|c}` | Cycle |
| `(visited:)` | `visited("passage")` | Visit check |
| `(history:)` | `whisker.history.list()` | History access |
| `(live:)` | No direct equivalent | Use Lua timing |

## D.3 ChoiceScript to WLS

| ChoiceScript | WLS | Notes |
|--------------|-----|-------|
| `*create var 5` | `$var = 5` | In header |
| `*temp var 5` | `_var = 5` | Temp variable |
| `*set var 5` | `{$var = 5}` | Assignment |
| `*if condition` | `{$condition}` | Block conditional |
| `*elseif` | `{elif $condition}` | Elif clause |
| `*else` | `{else}` | Else clause |
| `*choice` | Choices with `+` | Choice block |
| `#Option` | `+ [Option]` | Choice option |
| `*goto label` | `-> Label` | Navigation |
| `*gosub label` | `->-> Label` | Tunnel call |
| `*return` | `->->` | Tunnel return |
| `*label name` | `=== Name ===` | Passage |
| `*page_break` | Use hooks | `@pagebreak` |
| `*finish` | `-> END` | End story |
| `${var}` | `$var` | Interpolation |
| `*rand var 1 6` | `{$var = random(1, 6)}` | Random number |

## D.4 Common Migration Patterns

### Conditional Text

```
// Ink
{health > 50: You feel fine.|You feel weak.}

// WLS
{$health > 50: You feel fine. | You feel weak.}
```

### Visit Counting

```
// Ink
{knot > 2: You've been here before.}

// WLS
{visited("Passage") > 2: You've been here before.}
```

### Inventory Checking

```
// Ink
{LIST_COUNT(inventory) > 0: You're carrying items.}

// WLS
{#$inventory > 0: You're carrying items.}
```

## D.5 Migration Tool Specification

This section specifies the interface for automated migration tools.

### D.5.1 CLI Interface

Migration tools SHOULD follow this interface:

```bash
# Convert single file
whisker-migrate <source-format> <input-file> [output-file]

# Convert directory
whisker-migrate <source-format> <input-dir> --output <output-dir>

# Validate conversion
whisker-migrate <source-format> <input-file> --validate

# Show diff only
whisker-migrate <source-format> <input-file> --dry-run
```

**Source formats:**
- `ink` - Ink (.ink files)
- `twine` - Twine/Harlowe (.html, .twee)
- `choicescript` - ChoiceScript (.txt scenes)
- `json` - Generic JSON story format

### D.5.2 Conversion Report Format

Tools MUST output a JSON conversion report:

```json
{
  "source_format": "ink",
  "source_file": "story.ink",
  "output_file": "story.ws",
  "status": "success|partial|failed",
  "statistics": {
    "passages_converted": 45,
    "choices_converted": 120,
    "variables_converted": 15,
    "warnings": 3,
    "errors": 0
  },
  "warnings": [
    {
      "line": 42,
      "code": "MIG-WARN-001",
      "message": "Ink tunnel syntax converted to WLS tunnel",
      "source": "<- subplot",
      "target": "->-> Subplot"
    }
  ],
  "errors": [],
  "unsupported_features": [
    "external functions",
    "threading"
  ]
}
```

### D.5.3 Warning/Error Codes

| Code | Meaning |
|------|---------|
| MIG-WARN-001 | Syntax converted with semantic change |
| MIG-WARN-002 | Feature approximated |
| MIG-WARN-003 | Manual review recommended |
| MIG-ERR-001 | Unsupported feature |
| MIG-ERR-002 | Parse error in source |
| MIG-ERR-003 | Ambiguous conversion |

### D.5.4 Validation Requirements

After conversion, tools SHOULD verify:

1. All passages are reachable
2. All variables are defined before use
3. No dead links exist
4. Story can be parsed by WLS parser

---

# Appendix E: TextMate Grammar

A complete TextMate grammar for WLS syntax highlighting.

```json
{
  "name": "Whisker",
  "scopeName": "source.whisker",
  "fileTypes": ["ws", "whisker"],
  "patterns": [
    { "include": "#comment" },
    { "include": "#header" },
    { "include": "#passage" },
    { "include": "#choice" },
    { "include": "#conditional" },
    { "include": "#alternative" },
    { "include": "#variable" },
    { "include": "#navigation" },
    { "include": "#string" },
    { "include": "#number" },
    { "include": "#keyword" },
    { "include": "#operator" }
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
    "header": {
      "name": "meta.header.whisker",
      "begin": "^---\\s*(story|passage)?\\s*$",
      "end": "^---\\s*$",
      "beginCaptures": {
        "0": { "name": "punctuation.definition.header.whisker" },
        "1": { "name": "keyword.control.header.whisker" }
      },
      "endCaptures": {
        "0": { "name": "punctuation.definition.header.whisker" }
      },
      "patterns": [
        { "include": "#variable" },
        { "include": "#string" },
        { "include": "#number" },
        {
          "match": "^(\\w+)\\s*:",
          "captures": {
            "1": { "name": "entity.name.tag.whisker" }
          }
        }
      ]
    },
    "passage": {
      "name": "meta.passage.whisker",
      "match": "^(===)\\s*([\\w\\s]+?)\\s*(===)\\s*$",
      "captures": {
        "1": { "name": "punctuation.definition.passage.whisker" },
        "2": { "name": "entity.name.section.whisker" },
        "3": { "name": "punctuation.definition.passage.whisker" }
      }
    },
    "choice": {
      "name": "meta.choice.whisker",
      "begin": "^\\s*([+*])\\s*(\\[)",
      "end": "(\\])",
      "beginCaptures": {
        "1": { "name": "keyword.control.choice.whisker" },
        "2": { "name": "punctuation.definition.choice.begin.whisker" }
      },
      "endCaptures": {
        "1": { "name": "punctuation.definition.choice.end.whisker" }
      },
      "patterns": [
        { "include": "#variable" },
        { "include": "#conditional" }
      ]
    },
    "conditional": {
      "patterns": [
        {
          "name": "meta.conditional.block.whisker",
          "begin": "(\\{)(?=\\$|_|not |and |or )",
          "end": "(\\}|\\{/\\})",
          "beginCaptures": {
            "1": { "name": "punctuation.definition.conditional.whisker" }
          },
          "endCaptures": {
            "1": { "name": "punctuation.definition.conditional.whisker" }
          },
          "patterns": [
            { "include": "#variable" },
            { "include": "#operator" },
            { "include": "#keyword" }
          ]
        }
      ]
    },
    "alternative": {
      "name": "meta.alternative.whisker",
      "begin": "(\\{)([&~!]?)(\\|)",
      "end": "(\\})",
      "beginCaptures": {
        "1": { "name": "punctuation.definition.alternative.whisker" },
        "2": { "name": "keyword.control.alternative.whisker" },
        "3": { "name": "punctuation.separator.alternative.whisker" }
      },
      "endCaptures": {
        "1": { "name": "punctuation.definition.alternative.whisker" }
      },
      "patterns": [
        {
          "match": "\\|",
          "name": "punctuation.separator.alternative.whisker"
        }
      ]
    },
    "variable": {
      "patterns": [
        {
          "name": "variable.other.story.whisker",
          "match": "\\$[a-zA-Z_][a-zA-Z0-9_]*"
        },
        {
          "name": "variable.other.temp.whisker",
          "match": "_[a-zA-Z_][a-zA-Z0-9_]*"
        }
      ]
    },
    "navigation": {
      "name": "keyword.control.navigation.whisker",
      "match": "->\\s*([\\w:]+|END|BACK)"
    },
    "string": {
      "name": "string.quoted.double.whisker",
      "begin": "\"",
      "end": "\"",
      "patterns": [
        {
          "name": "constant.character.escape.whisker",
          "match": "\\\\."
        },
        { "include": "#variable" }
      ]
    },
    "number": {
      "name": "constant.numeric.whisker",
      "match": "\\b-?\\d+(\\.\\d+)?\\b"
    },
    "keyword": {
      "name": "keyword.control.whisker",
      "match": "\\b(if|else|elif|and|or|not|true|false|nil|LIST|INCLUDE)\\b"
    },
    "operator": {
      "name": "keyword.operator.whisker",
      "match": "(==|~=|>=|<=|>|<|\\+|-|\\*|/|%|=)"
    }
  }
}
```

## E.1 Installation

### VS Code

1. Create folder: `~/.vscode/extensions/whisker-syntax/`
2. Add `package.json`:
```json
{
  "name": "whisker-syntax",
  "displayName": "Whisker Language",
  "version": "1.0.0",
  "engines": { "vscode": "^1.50.0" },
  "contributes": {
    "languages": [{
      "id": "whisker",
      "extensions": [".ws", ".whisker"],
      "aliases": ["Whisker", "whisker"]
    }],
    "grammars": [{
      "language": "whisker",
      "scopeName": "source.whisker",
      "path": "./whisker.tmLanguage.json"
    }]
  }
}
```
3. Save the TextMate grammar as `whisker.tmLanguage.json`
4. Restart VS Code

### Sublime Text

1. Open `Preferences > Browse Packages...`
2. Create folder `Whisker/`
3. Save grammar as `Whisker.tmLanguage.json`

---

# Appendix F: Glossary

## A

**Action Block**: Code executed when a choice is selected. Syntax: `{$var = value}`

**Alternative**: Dynamic text that varies on each visit. Types: sequence (`|`), cycle (`&|`), shuffle (`~|`), once (`!|`)

**Array**: Ordered collection of values. Syntax: `[1, 2, 3]`

## B

**Block Conditional**: Multi-line conditional content. Syntax: `{$condition}...{/}`

**BOM**: Byte Order Mark. UTF-8 BOM is tolerated but stripped.

## C

**Choice**: Player-selectable option. Types: once-only (`+`), sticky (`*`)

**Conformant**: Meeting all requirements of this specification

**Cycle Alternative**: Repeats through options forever. Syntax: `{&| a | b | c }`

## E

**EBNF**: Extended Backus-Naur Form. Formal grammar notation used in this spec

**Expression**: Code that produces a value. Examples: `$x + 5`, `visited("Start")`

## F

**Fallback Passage**: Navigation target when all choices are unavailable

## G

**Gather Point**: Convergence point after branching choices. Syntax: `-`

## H

**Header**: Story or passage metadata block. Syntax: `--- story ... ---`

**History**: Record of visited passages. Access via `whisker.history`

**Hook**: Named text region for dynamic manipulation. Syntax: `[@name: content]`

## I

**Identifier**: Name for variables, passages, functions. Pattern: `[A-Za-z_][A-Za-z0-9_]*`

**Implementation**: Software that executes WLS stories

**Inline Conditional**: Single-line conditional. Syntax: `{$x: true | false}`

**Interpolation**: Embedding variable values in text. Syntax: `$variable`

## L

**LIST**: Enumerated set type for flags and inventory. Syntax: `LIST items = a, b, c`

**Lua**: Scripting language embedded in WLS for advanced logic

## M

**Map**: Key-value collection. Syntax: `{key: value}`

**Module**: Reusable code unit imported with `#include`

## N

**Namespace**: Grouping for passages and functions. Syntax: `#namespace Name`

**Navigation**: Moving between passages. Syntax: `-> PassageName`

**NFC**: Unicode Normalization Form Canonical Composition

## O

**Once-Only Choice**: Choice that disappears after selection. Syntax: `+ [text]`

## P

**Passage**: Named section of content. Syntax: `=== Name ===`

**Prose**: Narrative text rendered to the player

## R

**Recovery**: Continuing execution after a non-fatal error

**Runtime**: The execution environment for WLS stories

## S

**Sequence Alternative**: Shows options in order. Syntax: `{| a | b | c }`

**Shuffle Alternative**: Random order without repeats. Syntax: `{~| a | b | c }`

**Sticky Choice**: Choice that remains available. Syntax: `* [text]`

**Story**: Complete WLS document or project

**Story Variable**: Persistent variable with `$` prefix

## T

**Temp Variable**: Passage-scoped variable with `_` prefix

**Tunnel**: Subroutine-like passage call. Syntax: `->-> Passage`

## U

**UTF-8**: Required character encoding for WLS files

## V

**Visit Count**: Number of times a passage has been entered. Access via `visited()`

---

# Appendix G: Implementation Guidance

This appendix provides guidance for teams implementing WLS runtimes, editors, or related tools.

## G.1 Acceptance Criteria Format

Use this standard format for WLS feature acceptance criteria:

### G.1.1 Feature Criteria Template

```yaml
feature: Feature Name
version: 1.0.0
status: required | optional | deprecated

acceptance_criteria:
  - id: AC-001
    description: Brief description of criterion
    given: Initial state/preconditions
    when: Action or trigger
    then: Expected outcome
    error_code: WLS-XXX-NNN (if applicable)

  - id: AC-002
    description: Another criterion
    given: ...
    when: ...
    then: ...

test_cases:
  - id: TC-001
    criteria: [AC-001]
    input: |
      === Start ===
      Test content
    expected_output: "Test content"

edge_cases:
  - id: EC-001
    description: Edge case description
    handling: How to handle
```

### G.1.2 Conformance Levels

| Level | Requirements |
|-------|--------------|
| **Minimal** | All MUST criteria pass |
| **Standard** | All MUST + SHOULD criteria pass |
| **Full** | All criteria pass including MAY |

## G.2 Implementation Phases

Recommended phasing for WLS implementation:

### G.2.1 Phase 1: MVP (Core)

**Duration**: Foundation

| Component | Features |
|-----------|----------|
| Parser | Passages, choices, variables, conditionals |
| Runtime | Navigation, state, basic rendering |
| State | Story variables, temp variables |
| Error | Parse errors, basic runtime errors |

**Exit Criteria:**
- Can run simple linear stories
- Supports branching with choices
- Variables work correctly
- Passes Phase 1 test suite

### G.2.2 Phase 2: Complete Language

**Duration**: After Phase 1

| Component | Features |
|-----------|----------|
| Parser | Tunnels, alternatives, hooks, modules |
| Runtime | Visit tracking, history, hooks |
| State | Lists, arrays, maps |
| Error | Full error code coverage |

**Exit Criteria:**
- Passes full conformance suite
- All WLS syntax supported
- Save/load works correctly

### G.2.3 Phase 3: Tooling

**Duration**: After Phase 2

| Component | Features |
|-----------|----------|
| LSP | Completions, diagnostics, hover |
| CLI | lint, fmt, preview |
| Debug | Breakpoints, stepping, inspection |

**Exit Criteria:**
- IDE integration functional
- CLI tools usable
- Debugging supported

### G.2.4 Phase 4: Optimization

**Duration**: Ongoing

| Component | Features |
|-----------|----------|
| Parser | Incremental parsing |
| Runtime | Performance optimization |
| Memory | Efficient state storage |

## G.3 Integration Interface

Standard interface for embedding WLS in applications:

### G.3.1 Runtime Interface

```typescript
interface WLSRuntime {
  // Lifecycle
  load(source: string | StoryJSON): void;
  start(): void;
  reset(): void;

  // State
  getState(): StoryState;
  setState(state: StoryState): void;
  getVariable(name: string): any;
  setVariable(name: string, value: any): void;

  // Navigation
  getCurrentPassage(): Passage;
  getAvailableChoices(): Choice[];
  selectChoice(index: number): void;
  canGoBack(): boolean;
  goBack(): void;

  // Events
  on(event: string, callback: Function): void;
  off(event: string, callback: Function): void;

  // Save/Load
  save(): SaveState;
  restore(state: SaveState): void;
}
```

### G.3.2 Event Types

| Event | Payload | When |
|-------|---------|------|
| `passage:enter` | `{ id, tags }` | Entering passage |
| `passage:exit` | `{ id }` | Leaving passage |
| `content:render` | `{ text }` | Content ready |
| `choices:available` | `{ choices[] }` | Choices ready |
| `choice:selected` | `{ index, text }` | Player chose |
| `state:changed` | `{ key, value }` | Variable changed |
| `error` | `{ code, message }` | Error occurred |
| `story:end` | `{}` | Story finished |

### G.3.3 Embedding Example

```javascript
const runtime = new WLSRuntime();

// Load story
runtime.load(storySource);

// Handle events
runtime.on('content:render', ({ text }) => {
  displayElement.innerHTML = text;
});

runtime.on('choices:available', ({ choices }) => {
  renderChoices(choices);
});

// Start
runtime.start();

// User interaction
function onChoiceClick(index) {
  runtime.selectChoice(index);
}
```

## G.4 Collaborative Workflow

Guidance for team-based story development:

### G.4.1 File Organization

```
project/
├── src/
│   ├── main.ws           # Entry point
│   ├── chapters/
│   │   ├── ch1.ws
│   │   ├── ch2.ws
│   │   └── ch3.ws
│   ├── characters/
│   │   ├── alice.ws
│   │   └── bob.ws
│   └── shared/
│       ├── inventory.ws
│       └── dialogs.ws
├── test/
│   └── *.test.ws
└── assets/
```

### G.4.2 Content Locking

For teams using content management:

```yaml
# .whisker-lock.yaml
locks:
  - file: chapters/ch1.ws
    owner: alice@team.com
    expires: 2026-01-20T12:00:00Z
    reason: "Editing chapter 1 dialog"

  - file: characters/bob.ws
    owner: bob@team.com
    expires: 2026-01-18T18:00:00Z
```

### G.4.3 Review Workflow

```
1. Author creates branch: feature/ch5-forest
2. Author writes content in chapters/ch5.ws
3. CI runs: whisker-lint, whisker-test
4. Author opens PR with playable preview link
5. Editor reviews in preview, adds comments
6. Author addresses feedback
7. QA runs full playthrough
8. Merge to main
```

### G.4.4 Approval Gates

| Gate | Requirement | Enforced By |
|------|-------------|-------------|
| Lint | No errors | CI |
| Test | All tests pass | CI |
| Preview | Build succeeds | CI |
| Editorial | Editor approval | PR review |
| QA | Playtest complete | Manual check |

### G.4.5 Version Control Best Practices

1. **One passage per meaningful change** - Don't batch unrelated edits
2. **Descriptive commits** - "Add forest encounter choices" not "Update ch5"
3. **Branch per feature** - Keep changes isolated
4. **Regular merges** - Avoid long-lived branches
5. **Lock before editing** - Prevent conflicts on large files

---

# Appendix H: Quick Reference (Cheat Sheet)

## Syntax at a Glance

### Passages
```whisker
=== PassageName ===        // Passage declaration
=== Name [tag1, tag2] ===  // With tags
```

### Choices
```whisker
+ [Once-only choice] -> Target      // Disappears after selection
* [Sticky choice] -> Target         // Always available
+ [Conditional] {$x > 5} -> Target  // Only if condition true
+ [With action] {$gold += 10} -> Target
```

### Variables
```whisker
$story_var = 10       // Persists across passages
_temp_var = "hello"   // Cleared on passage exit
$name                 // Interpolation in text
${$a + $b}            // Expression interpolation
```

### Conditionals
```whisker
{$condition}          // Block conditional (start)
  Content if true
{elif $other}         // Else-if
  Other content
{else}                // Else
  Fallback content
{/}                   // End block

{$x: yes | no}        // Inline conditional
```

### Alternatives
```whisker
{| a | b | c }        // Sequence (in order)
{&| a | b | c }       // Cycle (loops)
{~| a | b | c }       // Shuffle (random, no repeat)
{!| a | b | c }       // Once (then empty)
```

### Navigation
```whisker
-> PassageName        // Go to passage
-> END                // End story
-> BACK               // Go back in history
->-> PassageName      // Tunnel (call)
->->                  // Tunnel return
```

### Comments
```whisker
// Single-line comment
/* Multi-line
   comment */
```

## Operators

| Op | Meaning | Example |
|----|---------|---------|
| `+` | Add | `$a + 5` |
| `-` | Subtract | `$a - 5` |
| `*` | Multiply | `$a * 2` |
| `/` | Divide | `$a / 2` |
| `%` | Modulo | `$a % 3` |
| `==` | Equal | `$a == 5` |
| `~=` | Not equal | `$a ~= 5` |
| `!=` | Not equal | `$a != 5` |
| `<` | Less than | `$a < 5` |
| `>` | Greater | `$a > 5` |
| `<=` | Less/equal | `$a <= 5` |
| `>=` | Greater/equal | `$a >= 5` |
| `and` | Logical AND | `$a and $b` |
| `or` | Logical OR | `$a or $b` |
| `not` | Logical NOT | `not $a` |

## Data Types

| Type | Example | Notes |
|------|---------|-------|
| Number | `42`, `3.14`, `-5` | IEEE 754 double |
| String | `"hello"`, `"line\n"` | UTF-8 |
| Boolean | `true`, `false` | |
| List | `LIST items = a, b, c` | Enumerated set |
| Array | `[1, 2, 3]` | Ordered, 1-indexed |
| Map | `{key: "value"}` | Key-value pairs |

## Built-in Functions

| Function | Description |
|----------|-------------|
| `visited("Name")` | Times passage visited |
| `random(min, max)` | Random integer |
| `pick(a, b, c)` | Random from args |
| `whisker.state.get("var")` | Get variable |
| `whisker.state.set("var", val)` | Set variable |
| `whisker.passage.go("Name")` | Navigate |
| `whisker.history.back()` | Go back |

## Escape Sequences

| Escape | Character |
|--------|-----------|
| `\\` | Backslash |
| `\"` | Quote |
| `\n` | Newline |
| `\t` | Tab |
| `\{` | Literal `{` |
| `\$` | Literal `$` |

## Error Codes

| Prefix | Category |
|--------|----------|
| WLS-STR | Structure |
| WLS-LNK | Links |
| WLS-VAR | Variables |
| WLS-EXP | Expressions |
| WLS-FLW | Flow |
| WLS-SYN | Syntax |

## File Extensions

| Extension | Format |
|-----------|--------|
| `.ws` | WLS text format |
| `.whisker` | WLS text format |
| `.wls.json` | WLS JSON format |

---

