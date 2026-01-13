#!/usr/bin/env node
/**
 * WLS Cross-Platform Validation Comparison
 * Compares TypeScript and Lua validation results for parity
 */

const fs = require('fs');
const path = require('path');

const RESULTS_DIR = path.join(__dirname, '../test-results');
const TS_RESULTS = path.join(RESULTS_DIR, 'validation-ts-results.json');
const LUA_RESULTS = path.join(RESULTS_DIR, 'validation-lua-results.json');

function loadResults(filepath) {
  try {
    return JSON.parse(fs.readFileSync(filepath, 'utf-8'));
  } catch (err) {
    console.error(`Failed to load ${filepath}:`, err.message);
    return null;
  }
}

function normalizeArray(arr) {
  if (!arr || typeof arr !== 'object') return [];
  if (Array.isArray(arr)) return arr.sort();
  return Object.values(arr).sort();
}

function arraysEqual(a, b) {
  const normA = normalizeArray(a);
  const normB = normalizeArray(b);
  if (normA.length !== normB.length) return false;
  for (let i = 0; i < normA.length; i++) {
    if (normA[i] !== normB[i]) return false;
  }
  return true;
}

function main() {
  console.log('WLS Cross-Platform Validation Comparison');
  console.log('=============================================\n');

  const tsResults = loadResults(TS_RESULTS);
  const luaResults = loadResults(LUA_RESULTS);

  if (!tsResults || !luaResults) {
    console.error('Could not load both result files');
    process.exit(1);
  }

  console.log(`TypeScript: ${tsResults.summary.passed}/${tsResults.summary.total} passed`);
  console.log(`Lua:        ${luaResults.summary.passed}/${luaResults.summary.total} passed\n`);

  // Build test maps by name
  const tsTests = new Map();
  const luaTests = new Map();

  for (const file of tsResults.files) {
    for (const test of file.tests) {
      tsTests.set(test.name, { ...test, file: file.filename });
    }
  }

  for (const file of luaResults.files) {
    for (const test of file.tests) {
      luaTests.set(test.name, { ...test, file: file.filename });
    }
  }

  // Compare each test
  let identical = 0;
  let different = 0;
  const differences = [];

  for (const [name, tsTest] of tsTests) {
    const luaTest = luaTests.get(name);
    if (!luaTest) {
      differences.push({ name, issue: 'Missing in Lua results' });
      different++;
      continue;
    }

    const errorsMatch = arraysEqual(tsTest.actual.errors, luaTest.actual.errors);
    const warningsMatch = arraysEqual(tsTest.actual.warnings, luaTest.actual.warnings);
    const infoMatch = arraysEqual(tsTest.actual.info, luaTest.actual.info);

    if (errorsMatch && warningsMatch && infoMatch) {
      identical++;
    } else {
      different++;
      differences.push({
        name,
        file: tsTest.file,
        ts: tsTest.actual,
        lua: luaTest.actual,
        errorsMatch,
        warningsMatch,
        infoMatch
      });
    }
  }

  // Check for tests only in Lua
  for (const [name] of luaTests) {
    if (!tsTests.has(name)) {
      differences.push({ name, issue: 'Missing in TypeScript results' });
      different++;
    }
  }

  // Report
  console.log('Comparison Results');
  console.log('==================');
  console.log(`  Identical: ${identical}`);
  console.log(`  Different: ${different}`);
  console.log('');

  if (differences.length > 0) {
    console.log('Differences Found:');
    console.log('------------------');
    for (const diff of differences) {
      if (diff.issue) {
        console.log(`  ${diff.name}: ${diff.issue}`);
      } else {
        console.log(`  ${diff.name} (${diff.file}):`);
        if (!diff.errorsMatch) {
          console.log(`    Errors:   TS=${JSON.stringify(normalizeArray(diff.ts.errors))} LUA=${JSON.stringify(normalizeArray(diff.lua.errors))}`);
        }
        if (!diff.warningsMatch) {
          console.log(`    Warnings: TS=${JSON.stringify(normalizeArray(diff.ts.warnings))} LUA=${JSON.stringify(normalizeArray(diff.lua.warnings))}`);
        }
        if (!diff.infoMatch) {
          console.log(`    Info:     TS=${JSON.stringify(normalizeArray(diff.ts.info))} LUA=${JSON.stringify(normalizeArray(diff.lua.info))}`);
        }
      }
    }
    console.log('');
  }

  // Summary
  const passRate = ((identical / (identical + different)) * 100).toFixed(1);
  console.log('=============================================');
  console.log(`Cross-Platform Parity: ${passRate}%`);
  console.log('=============================================');

  if (different === 0) {
    console.log('\nTypeScript and Lua validators produce IDENTICAL results!');
  }

  process.exit(different === 0 ? 0 : 1);
}

main();
