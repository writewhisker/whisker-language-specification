#!/usr/bin/env node
/**
 * WLS Test Corpus Runner for whisker-editor-web
 * Runs test corpus against the whisker-editor-web parser
 *
 * Usage: node whisker-editor-runner.cjs [corpus_path] [output_file]
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

// Default paths
const CORPUS_PATH = process.argv[2] || path.join(__dirname, '../test-corpus');
const OUTPUT_FILE = process.argv[3] || path.join(__dirname, '../test-results/whisker-editor-results.json');

// Test categories
// Note: 'api' is skipped - it uses {{ }} Lua expression syntax not supported by TS parser
const CATEGORIES = [
    'syntax',
    'variables',
    'conditionals',
    'choices',
    'alternatives',
    // 'api' - skipped: uses {{ }} Lua expression syntax (runtime tests)
    'formats',
    'edge-cases'
];

// Load parser
let parse;
try {
    const parserPath = path.resolve(__dirname, '../../../writewhisker/whisker-editor-web/packages/parser/dist/index.js');
    const parserModule = require(parserPath);
    parse = parserModule.parse;
} catch (err) {
    console.error('Error loading parser:', err.message);
    console.error('Make sure to run: pnpm --filter @writewhisker/parser build');
    process.exit(1);
}

// Load YAML file
function loadYaml(filepath) {
    try {
        const content = fs.readFileSync(filepath, 'utf-8');
        return yaml.load(content);
    } catch (err) {
        console.error(`Error loading ${filepath}:`, err.message);
        return null;
    }
}

// Run a single test
function runTest(test) {
    const startTime = Date.now();
    const result = {
        name: test.name,
        passed: false,
        expected: test.expected || {},
        actual: {},
        duration: 0
    };

    try {
        // Add timeout protection
        const parseResult = parse(test.input || '');

        result.actual.valid = parseResult.errors.length === 0;
        if (parseResult.ast && parseResult.ast.passages) {
            result.actual.passages = parseResult.ast.passages.length;
        } else {
            result.actual.passages = 0;
        }

        if (parseResult.errors.length > 0) {
            result.actual.error = parseResult.errors[0].message;
        }
    } catch (err) {
        result.actual.valid = false;
        result.actual.error = err.message || String(err);
    }

    result.duration = Date.now() - startTime;

    // Compare results
    let passed = true;

    if (result.expected.valid !== undefined) {
        if (result.actual.valid !== result.expected.valid) {
            passed = false;
        }
    }

    if (result.expected.passages !== undefined) {
        if (result.actual.passages !== result.expected.passages) {
            passed = false;
        }
    }

    result.passed = passed;
    return result;
}

// Run all tests in a category
function runCategory(category) {
    const categoryPath = path.join(CORPUS_PATH, category);
    if (!fs.existsSync(categoryPath)) {
        console.log(`  Category ${category} not found, skipping`);
        return null;
    }

    const files = fs.readdirSync(categoryPath).filter(f => f.endsWith('.yaml') || f.endsWith('.yml'));
    const tests = [];

    for (const file of files) {
        const data = loadYaml(path.join(categoryPath, file));
        if (data && data.tests) {
            tests.push(...data.tests);
        }
    }

    if (tests.length === 0) {
        return null;
    }

    const results = [];
    let passed = 0;
    let failed = 0;

    for (const test of tests) {
        const result = runTest(test);
        results.push(result);
        if (result.passed) {
            passed++;
        } else {
            failed++;
        }
    }

    return {
        category,
        total: tests.length,
        passed,
        failed,
        tests: results
    };
}

// Main
async function main() {
    console.log('WLS Test Corpus Runner - whisker-editor-web');
    console.log('================================================');
    console.log(`Corpus path: ${CORPUS_PATH}`);
    console.log(`Output file: ${OUTPUT_FILE}`);
    console.log('');

    const report = {
        platform: 'whisker-editor-web',
        timestamp: new Date().toISOString(),
        categories: [],
        summary: {
            total: 0,
            passed: 0,
            failed: 0,
            passRate: '0.0%'
        }
    };

    for (const category of CATEGORIES) {
        console.log(`Running ${category}...`);
        const result = runCategory(category);
        if (result) {
            report.categories.push(result);
            report.summary.total += result.total;
            report.summary.passed += result.passed;
            report.summary.failed += result.failed;
            console.log(`  ${result.passed}/${result.total} passed`);
        }
    }

    report.summary.passRate = ((report.summary.passed / report.summary.total) * 100).toFixed(1) + '%';

    // Print summary
    console.log('');
    console.log('Summary');
    console.log('-------');
    console.log(`Total: ${report.summary.total}`);
    console.log(`Passed: ${report.summary.passed}`);
    console.log(`Failed: ${report.summary.failed}`);
    console.log(`Pass Rate: ${report.summary.passRate}`);

    // Print failed tests
    if (report.summary.failed > 0) {
        console.log('');
        console.log('Failed Tests:');
        for (const cat of report.categories) {
            for (const test of cat.tests) {
                if (!test.passed) {
                    console.log(`  - ${cat.category}/${test.name}`);
                    console.log(`    Expected: valid=${test.expected.valid}, passages=${test.expected.passages}`);
                    console.log(`    Actual: valid=${test.actual.valid}, passages=${test.actual.passages}`);
                    if (test.actual.error) {
                        console.log(`    Error: ${test.actual.error}`);
                    }
                }
            }
        }
    }

    // Save results
    const outputDir = path.dirname(OUTPUT_FILE);
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }
    fs.writeFileSync(OUTPUT_FILE, JSON.stringify(report, null, 2));
    console.log(`\nResults saved to: ${OUTPUT_FILE}`);
}

main().catch(console.error);
