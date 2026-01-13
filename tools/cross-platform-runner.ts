/**
 * WLS Cross-Platform Test Runner
 *
 * Runs the WLS test corpus against multiple implementations:
 * - whisker-editor-web (TypeScript/Node)
 * - whisker-core (Lua) - when available
 *
 * Usage: npx ts-node cross-platform-runner.ts [options]
 */

import * as fs from 'fs';
import * as path from 'path';
import * as yaml from 'js-yaml';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Types
interface TestCase {
  name: string;
  description: string;
  input: string;
  expected: {
    passages?: number;
    valid?: boolean;
    output?: string;
    variables?: Record<string, unknown>;
    error?: string | null;
  };
}

interface TestFile {
  tests: TestCase[];
}

interface TestResult {
  name: string;
  passed: boolean;
  expected: TestCase['expected'];
  actual: {
    passages?: number;
    valid?: boolean;
    output?: string;
    variables?: Record<string, unknown>;
    error?: string | null;
  };
  error?: string;
  duration: number;
}

interface CategoryResults {
  category: string;
  total: number;
  passed: number;
  failed: number;
  tests: TestResult[];
}

interface PlatformResults {
  platform: string;
  timestamp: string;
  categories: CategoryResults[];
  summary: {
    total: number;
    passed: number;
    failed: number;
    passRate: string;
  };
}

interface CrossPlatformReport {
  timestamp: string;
  corpusVersion: string;
  platforms: PlatformResults[];
  comparison?: {
    identical: number;
    different: number;
    differences: Array<{
      test: string;
      platforms: Record<string, TestResult>;
    }>;
  };
}

// Test Runner Class
export class CrossPlatformRunner {
  private corpusPath: string;
  private outputPath: string;

  constructor(corpusPath: string, outputPath: string) {
    this.corpusPath = corpusPath;
    this.outputPath = outputPath;
  }

  /**
   * Load all test files from the corpus
   */
  loadCorpus(): Map<string, TestCase[]> {
    const categories = new Map<string, TestCase[]>();
    const categoryDirs = [
      'syntax',
      'variables',
      'conditionals',
      'choices',
      'alternatives',
      'api',
      'formats',
      'edge-cases'
    ];

    for (const category of categoryDirs) {
      const categoryPath = path.join(this.corpusPath, category);
      if (!fs.existsSync(categoryPath)) {
        console.warn(`Category directory not found: ${category}`);
        continue;
      }

      const files = fs.readdirSync(categoryPath).filter(f => f.endsWith('.yaml') || f.endsWith('.yml'));
      const tests: TestCase[] = [];

      for (const file of files) {
        const filePath = path.join(categoryPath, file);
        const content = fs.readFileSync(filePath, 'utf-8');
        const parsed = yaml.load(content) as TestFile;

        if (parsed && parsed.tests) {
          tests.push(...parsed.tests);
        }
      }

      if (tests.length > 0) {
        categories.set(category, tests);
      }
    }

    return categories;
  }

  /**
   * Run tests on whisker-editor-web parser
   */
  async runOnEditor(test: TestCase): Promise<TestResult> {
    const startTime = Date.now();

    try {
      // Dynamically import the parser from whisker-editor-web
      const parserPath = path.resolve(
        __dirname,
        '../../../writewhisker/whisker-editor-web/packages/parser/dist/index.js'
      );

      let parse: (source: string) => { ast: unknown; errors: Array<{ message: string }> };

      try {
        const parserModule = await import(parserPath);
        parse = parserModule.parse;
      } catch {
        // Fallback: try to use the source directly
        const srcPath = path.resolve(
          __dirname,
          '../../../writewhisker/whisker-editor-web/packages/parser/src/parser.ts'
        );
        throw new Error(`Parser not built. Run 'pnpm --filter @writewhisker/parser build' first. Looking for: ${parserPath}`);
      }

      const result = parse(test.input);
      const duration = Date.now() - startTime;

      // Extract results
      const actual: TestResult['actual'] = {
        passages: result.ast ? (result.ast as { passages: unknown[] }).passages?.length : 0,
        valid: result.errors.length === 0,
        error: result.errors.length > 0 ? result.errors[0].message : null
      };

      // Compare with expected
      let passed = true;

      if (test.expected.passages !== undefined) {
        if (actual.passages !== test.expected.passages) {
          passed = false;
        }
      }

      if (test.expected.valid !== undefined) {
        if (actual.valid !== test.expected.valid) {
          passed = false;
        }
      }

      if (test.expected.error !== undefined && test.expected.error !== null) {
        // Error test - check if we got an error
        if (actual.valid === true) {
          passed = false;
        } else if (actual.error && !actual.error.toLowerCase().includes(test.expected.error.toLowerCase().split(' ')[0])) {
          // Flexible error message matching
          passed = false;
        }
      }

      return {
        name: test.name,
        passed,
        expected: test.expected,
        actual,
        duration
      };
    } catch (err) {
      const duration = Date.now() - startTime;
      return {
        name: test.name,
        passed: false,
        expected: test.expected,
        actual: { valid: false, error: String(err) },
        error: String(err),
        duration
      };
    }
  }

  /**
   * Run tests on whisker-core (placeholder for future)
   */
  async runOnCore(test: TestCase): Promise<TestResult> {
    // TODO: Implement when whisker-core is available
    return {
      name: test.name,
      passed: false,
      expected: test.expected,
      actual: { valid: false, error: 'whisker-core not yet implemented' },
      error: 'Platform not available',
      duration: 0
    };
  }

  /**
   * Run all tests on a platform
   */
  async runPlatform(
    platform: 'editor' | 'core',
    corpus: Map<string, TestCase[]>
  ): Promise<PlatformResults> {
    const runTest = platform === 'editor' ? this.runOnEditor.bind(this) : this.runOnCore.bind(this);
    const categories: CategoryResults[] = [];
    let totalTests = 0;
    let totalPassed = 0;

    for (const [category, tests] of corpus) {
      console.log(`  Running ${category} (${tests.length} tests)...`);
      const results: TestResult[] = [];
      let passed = 0;

      for (const test of tests) {
        const result = await runTest(test);
        results.push(result);
        if (result.passed) passed++;
      }

      categories.push({
        category,
        total: tests.length,
        passed,
        failed: tests.length - passed,
        tests: results
      });

      totalTests += tests.length;
      totalPassed += passed;
    }

    return {
      platform: platform === 'editor' ? 'whisker-editor-web' : 'whisker-core',
      timestamp: new Date().toISOString(),
      categories,
      summary: {
        total: totalTests,
        passed: totalPassed,
        failed: totalTests - totalPassed,
        passRate: `${((totalPassed / totalTests) * 100).toFixed(1)}%`
      }
    };
  }

  /**
   * Compare results between platforms
   */
  compareResults(
    editorResults: PlatformResults,
    coreResults: PlatformResults
  ): CrossPlatformReport['comparison'] {
    const differences: CrossPlatformReport['comparison']['differences'] = [];
    let identical = 0;
    let different = 0;

    // Create maps for lookup
    const editorTests = new Map<string, TestResult>();
    const coreTests = new Map<string, TestResult>();

    for (const cat of editorResults.categories) {
      for (const test of cat.tests) {
        editorTests.set(test.name, test);
      }
    }

    for (const cat of coreResults.categories) {
      for (const test of cat.tests) {
        coreTests.set(test.name, test);
      }
    }

    // Compare
    for (const [name, editorTest] of editorTests) {
      const coreTest = coreTests.get(name);
      if (coreTest) {
        if (editorTest.passed === coreTest.passed) {
          identical++;
        } else {
          different++;
          differences.push({
            test: name,
            platforms: {
              editor: editorTest,
              core: coreTest
            }
          });
        }
      }
    }

    return { identical, different, differences };
  }

  /**
   * Generate full report
   */
  async generateReport(platforms: ('editor' | 'core')[]): Promise<CrossPlatformReport> {
    console.log('Loading test corpus...');
    const corpus = this.loadCorpus();

    let totalTests = 0;
    for (const tests of corpus.values()) {
      totalTests += tests.length;
    }
    console.log(`Loaded ${totalTests} tests from ${corpus.size} categories`);

    const report: CrossPlatformReport = {
      timestamp: new Date().toISOString(),
      corpusVersion: '1.0',
      platforms: []
    };

    for (const platform of platforms) {
      console.log(`\nRunning on ${platform}...`);
      const results = await this.runPlatform(platform, corpus);
      report.platforms.push(results);
      console.log(`  ${results.summary.passed}/${results.summary.total} passed (${results.summary.passRate})`);
    }

    // Compare if both platforms ran
    if (platforms.includes('editor') && platforms.includes('core')) {
      const editorResults = report.platforms.find(p => p.platform === 'whisker-editor-web');
      const coreResults = report.platforms.find(p => p.platform === 'whisker-core');
      if (editorResults && coreResults) {
        report.comparison = this.compareResults(editorResults, coreResults);
      }
    }

    return report;
  }

  /**
   * Save report to file
   */
  saveReport(report: CrossPlatformReport, filename: string): void {
    const outputFile = path.join(this.outputPath, filename);
    fs.writeFileSync(outputFile, JSON.stringify(report, null, 2));
    console.log(`\nReport saved to: ${outputFile}`);
  }

  /**
   * Print summary to console
   */
  printSummary(report: CrossPlatformReport): void {
    console.log('\n' + '='.repeat(60));
    console.log('WLS Test Corpus Results');
    console.log('='.repeat(60));

    for (const platform of report.platforms) {
      console.log(`\n${platform.platform}:`);
      console.log(`  Total: ${platform.summary.total}`);
      console.log(`  Passed: ${platform.summary.passed}`);
      console.log(`  Failed: ${platform.summary.failed}`);
      console.log(`  Pass Rate: ${platform.summary.passRate}`);

      console.log('\n  By Category:');
      for (const cat of platform.categories) {
        const status = cat.failed === 0 ? '✓' : '✗';
        console.log(`    ${status} ${cat.category}: ${cat.passed}/${cat.total}`);
      }
    }

    if (report.comparison) {
      console.log('\nCross-Platform Comparison:');
      console.log(`  Identical: ${report.comparison.identical}`);
      console.log(`  Different: ${report.comparison.different}`);

      if (report.comparison.differences.length > 0) {
        console.log('\n  Differences:');
        for (const diff of report.comparison.differences.slice(0, 10)) {
          console.log(`    - ${diff.test}`);
        }
        if (report.comparison.differences.length > 10) {
          console.log(`    ... and ${report.comparison.differences.length - 10} more`);
        }
      }
    }

    console.log('\n' + '='.repeat(60));
  }
}

// CLI
async function main(): Promise<void> {
  const args = process.argv.slice(2);
  const platforms: ('editor' | 'core')[] = [];

  // Parse arguments
  if (args.includes('--editor') || args.includes('-e')) {
    platforms.push('editor');
  }
  if (args.includes('--core') || args.includes('-c')) {
    platforms.push('core');
  }
  if (platforms.length === 0) {
    platforms.push('editor'); // Default to editor only
  }

  const corpusPath = path.resolve(__dirname, '../test-corpus');
  const outputPath = path.resolve(__dirname, '../test-results');

  // Ensure output directory exists
  if (!fs.existsSync(outputPath)) {
    fs.mkdirSync(outputPath, { recursive: true });
  }

  const runner = new CrossPlatformRunner(corpusPath, outputPath);
  const report = await runner.generateReport(platforms);

  runner.printSummary(report);
  runner.saveReport(report, `test-results-${Date.now()}.json`);
}

// Export for testing
export { TestCase, TestResult, PlatformResults, CrossPlatformReport };

// Run if executed directly
if (process.argv[1] === __filename) {
  main().catch(console.error);
}
