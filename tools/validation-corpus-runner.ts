#!/usr/bin/env npx ts-node
/**
 * WLS Validation Corpus Runner for whisker-editor-web (TypeScript)
 *
 * Runs validation test corpus against TypeScript validators.
 *
 * Usage: npx ts-node validation-corpus-runner.ts [corpus_path] [output_file]
 */

import * as fs from 'fs';
import * as path from 'path';
import * as yaml from 'js-yaml';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

// Import from whisker-editor-web packages
import { WLSImporter } from '../../whisker-editor-web/packages/import/src/formats/WLSImporter';
import { createDefaultValidator } from '../../whisker-editor-web/packages/story-validation/src/defaultValidator';
import type { ValidationIssue } from '../../whisker-editor-web/packages/story-validation/src/types';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Types
interface ValidationExpected {
  errors?: Array<{ code: string; [key: string]: unknown }>;
  warnings?: Array<{ code: string; [key: string]: unknown }>;
  info?: Array<{ code: string; [key: string]: unknown }>;
}

interface TestCase {
  name: string;
  description: string;
  input: string;
  expected: {
    valid?: boolean;
    passages?: number;
  };
  validation?: ValidationExpected;
}

interface TestFile {
  tests: TestCase[];
}

interface TestResult {
  name: string;
  description: string;
  passed: boolean;
  expected: {
    errors: string[];
    warnings: string[];
    info: string[];
  };
  actual: {
    errors: string[];
    warnings: string[];
    info: string[];
  };
  errors_match: boolean;
  warnings_match: boolean;
  info_match: boolean;
  parse_valid: boolean;
  duration: number;
  error?: string;
}

interface FileResult {
  filename: string;
  total: number;
  passed: number;
  failed: number;
  tests: TestResult[];
}

interface Results {
  platform: string;
  type: string;
  timestamp: string;
  files: FileResult[];
  summary: {
    total: number;
    passed: number;
    failed: number;
    passRate: string;
  };
}

// Default paths
const CORPUS_PATH = process.argv[2] || path.join(__dirname, '../test-corpus/validation');
const OUTPUT_FILE = process.argv[3] || path.join(__dirname, '../test-results/validation-ts-results.json');

// Validation test files
const TEST_FILES = [
  'structural-tests.yaml',
  'links-tests.yaml',
  'variables-tests.yaml',
  'flow-tests.yaml',
  'combined-tests.yaml',
];

// Load YAML file
function loadYaml(filepath: string): TestFile | null {
  try {
    const content = fs.readFileSync(filepath, 'utf-8');
    return yaml.load(content) as TestFile;
  } catch (error) {
    console.error(`Could not load ${filepath}:`, error);
    return null;
  }
}

// Extract error codes from validation issues by severity
function extractCodes(issues: ValidationIssue[], severity: string): string[] {
  return issues
    .filter(issue => issue.severity === severity)
    .map(issue => issue.code)
    .sort();
}

// Compare two sorted arrays
function arraysEqual(a: string[], b: string[]): boolean {
  if (a.length !== b.length) return false;
  for (let i = 0; i < a.length; i++) {
    if (a[i] !== b[i]) return false;
  }
  return true;
}

// Extract expected codes from validation section
function extractExpectedCodes(items: Array<{ code: string; [key: string]: unknown }> | undefined): string[] {
  if (!items) return [];
  return items.map(item => item.code).sort();
}

// Run a single validation test
async function runTest(test: TestCase): Promise<TestResult> {
  const startTime = Date.now();
  const result: TestResult = {
    name: test.name,
    description: test.description,
    passed: false,
    expected: {
      errors: extractExpectedCodes(test.validation?.errors),
      warnings: extractExpectedCodes(test.validation?.warnings),
      info: extractExpectedCodes(test.validation?.info),
    },
    actual: {
      errors: [],
      warnings: [],
      info: [],
    },
    errors_match: false,
    warnings_match: false,
    info_match: false,
    parse_valid: false,
    duration: 0,
  };

  try {
    // Import WLS content
    const importer = new WLSImporter();
    const importResult = await importer.import({
      data: test.input,
      filename: `${test.name}.ws`,
    });

    result.parse_valid = importResult.success;

    if (importResult.success && importResult.story) {
      // Create validator with all validators registered
      const validator = createDefaultValidator();

      // Run validation
      const validationResult = validator.validate(importResult.story);

      // Extract actual codes by severity
      result.actual.errors = extractCodes(validationResult.issues, 'error');
      result.actual.warnings = extractCodes(validationResult.issues, 'warning');
      result.actual.info = extractCodes(validationResult.issues, 'info');
    }
  } catch (error) {
    result.error = error instanceof Error ? error.message : String(error);
  }

  result.duration = Date.now() - startTime;

  // Check if test passed
  result.errors_match = arraysEqual(result.actual.errors, result.expected.errors);
  result.warnings_match = arraysEqual(result.actual.warnings, result.expected.warnings);
  result.info_match = arraysEqual(result.actual.info, result.expected.info);

  result.passed = result.errors_match && result.warnings_match && result.info_match;

  return result;
}

// Main runner
async function main(): Promise<boolean> {
  console.log('WLS Validation Corpus Runner for whisker-editor-web');
  console.log('========================================================');
  console.log(`Loading validation tests from: ${CORPUS_PATH}`);
  console.log('');

  const results: Results = {
    platform: 'whisker-editor-web',
    type: 'validation',
    timestamp: new Date().toISOString(),
    files: [],
    summary: {
      total: 0,
      passed: 0,
      failed: 0,
      passRate: '0%',
    },
  };

  let totalTests = 0;
  let totalPassed = 0;

  for (const filename of TEST_FILES) {
    const filepath = path.join(CORPUS_PATH, filename);
    const data = loadYaml(filepath);

    if (data && data.tests) {
      const fileResults: FileResult = {
        filename,
        total: data.tests.length,
        passed: 0,
        failed: 0,
        tests: [],
      };

      console.log(`  Running ${filename} (${data.tests.length} tests)...`);

      for (const test of data.tests) {
        const testResult = await runTest(test);
        fileResults.tests.push(testResult);

        if (testResult.passed) {
          fileResults.passed++;
        } else {
          // Print failure details
          console.log(`    \u2717 ${testResult.name}`);
          if (!testResult.errors_match) {
            console.log(`      Expected errors: ${testResult.expected.errors.join(', ')}`);
            console.log(`      Actual errors:   ${testResult.actual.errors.join(', ')}`);
          }
          if (!testResult.warnings_match) {
            console.log(`      Expected warnings: ${testResult.expected.warnings.join(', ')}`);
            console.log(`      Actual warnings:   ${testResult.actual.warnings.join(', ')}`);
          }
          if (!testResult.info_match) {
            console.log(`      Expected info: ${testResult.expected.info.join(', ')}`);
            console.log(`      Actual info:   ${testResult.actual.info.join(', ')}`);
          }
        }
      }

      fileResults.failed = fileResults.total - fileResults.passed;
      results.files.push(fileResults);

      totalTests += fileResults.total;
      totalPassed += fileResults.passed;

      const status = fileResults.failed === 0 ? '\u2713' : '\u2717';
      console.log(`    ${status} ${fileResults.passed}/${fileResults.total} passed`);
    } else {
      console.log(`  Warning: Could not load ${filepath}`);
    }
  }

  results.summary.total = totalTests;
  results.summary.passed = totalPassed;
  results.summary.failed = totalTests - totalPassed;
  if (totalTests > 0) {
    results.summary.passRate = `${((totalPassed / totalTests) * 100).toFixed(1)}%`;
  }

  // Print summary
  console.log('');
  console.log('========================================================');
  console.log('Summary');
  console.log('========================================================');
  console.log(`  Total:     ${totalTests}`);
  console.log(`  Passed:    ${totalPassed}`);
  console.log(`  Failed:    ${totalTests - totalPassed}`);
  console.log(`  Pass Rate: ${results.summary.passRate}`);
  console.log('');

  // Ensure output directory exists
  const outputDir = path.dirname(OUTPUT_FILE);
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  // Save results
  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(results, null, 2));
  console.log(`Results saved to: ${OUTPUT_FILE}`);

  return totalTests - totalPassed === 0;
}

// Run and exit with appropriate code
main()
  .then(success => process.exit(success ? 0 : 1))
  .catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
