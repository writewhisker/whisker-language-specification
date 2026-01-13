/**
 * WLS Performance Benchmarks
 *
 * Measures parse time and memory usage for whisker-editor-web parser
 */

import * as path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

interface BenchmarkResult {
  name: string;
  iterations: number;
  totalMs: number;
  avgMs: number;
  minMs: number;
  maxMs: number;
  opsPerSec: number;
}

interface MemoryResult {
  heapUsed: number;
  heapTotal: number;
  external: number;
}

// Generate test content
function generatePassages(count: number): string {
  const lines: string[] = [];
  for (let i = 0; i < count; i++) {
    lines.push(`:: Passage_${i}`);
    lines.push(`This is passage ${i} with some content.`);
    lines.push(`$var_${i} = ${i}`);
    if (i > 0) {
      lines.push(`+ [Go to passage ${i - 1}] -> Passage_${i - 1}`);
    }
    if (i < count - 1) {
      lines.push(`* [Go to passage ${i + 1}] -> Passage_${i + 1}`);
    }
    lines.push('');
  }
  return lines.join('\n');
}

function generateComplexContent(): string {
  return `
@title: Benchmark Story
@author: Test

:: Start
$gold = 100
$health = 50
$name = "Hero"

Welcome, $name!
You have \${$gold} gold and \${$health} health.

{$gold >= 50}
You are wealthy!
{else}
You are poor.
{/}

+ [Explore the cave] -> Cave
* [Rest at inn] -> Inn
{$health < 30} + [Visit healer] -> Healer

:: Cave
{| First visit | Returning | Back again }

You find {~| treasure | monsters | nothing }.

$gold = $gold + 10

+ [Continue deeper] -> DeepCave
+ [Return] -> Start

:: DeepCave
{!| This is your first time here. | You've been here before. | Familiar place. }

The cave {&| glows | pulses | shimmers } with magical energy.

+ [Take the crystal] -> Crystal
+ [Leave] -> Cave

:: Crystal
$crystal = true
You obtained the Crystal of Power!

+ [Return to surface] -> Start

:: Inn
$gold = $gold - 10
$health = 100

You rest and recover.

+ [Leave] -> Start

:: Healer
{$gold >= 20}
$gold = $gold - 20
$health = 100
The healer restores your health.
{else}
Not enough gold!
{/}

+ [Leave] -> Start
`;
}

async function runBenchmark(
  name: string,
  fn: () => void,
  iterations: number = 100
): Promise<BenchmarkResult> {
  // Warmup
  for (let i = 0; i < 5; i++) {
    fn();
  }

  // Collect times
  const times: number[] = [];

  for (let i = 0; i < iterations; i++) {
    const start = performance.now();
    fn();
    const end = performance.now();
    times.push(end - start);
  }

  const totalMs = times.reduce((a, b) => a + b, 0);
  const avgMs = totalMs / iterations;
  const minMs = Math.min(...times);
  const maxMs = Math.max(...times);
  const opsPerSec = 1000 / avgMs;

  return {
    name,
    iterations,
    totalMs,
    avgMs,
    minMs,
    maxMs,
    opsPerSec,
  };
}

function measureMemory(): MemoryResult {
  if (typeof global.gc === 'function') {
    global.gc();
  }
  const mem = process.memoryUsage();
  return {
    heapUsed: mem.heapUsed,
    heapTotal: mem.heapTotal,
    external: mem.external,
  };
}

function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(2)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(2)} MB`;
}

async function main(): Promise<void> {
  console.log('WLS Performance Benchmarks');
  console.log('='.repeat(60));
  console.log();

  // Load parser
  const parserPath = path.resolve(
    __dirname,
    '../../../writewhisker/whisker-editor-web/packages/parser/dist/index.js'
  );

  let parse: (source: string) => unknown;
  try {
    const parserModule = await import(parserPath);
    parse = parserModule.parse;
    console.log('Parser loaded successfully');
  } catch (err) {
    console.error('Failed to load parser:', err);
    process.exit(1);
  }

  // Generate test content
  console.log('\nGenerating test content...');
  const small = generatePassages(10);
  const medium = generatePassages(100);
  const large = generatePassages(1000);
  const complex = generateComplexContent();

  console.log(`  Small:   10 passages (${small.length} chars)`);
  console.log(`  Medium:  100 passages (${medium.length} chars)`);
  console.log(`  Large:   1000 passages (${large.length} chars)`);
  console.log(`  Complex: Mixed features (${complex.length} chars)`);

  // Run benchmarks
  console.log('\nRunning benchmarks...\n');

  const results: BenchmarkResult[] = [];

  // Parse benchmarks
  results.push(await runBenchmark('Parse small (10 passages)', () => parse(small), 1000));
  results.push(await runBenchmark('Parse medium (100 passages)', () => parse(medium), 100));
  results.push(await runBenchmark('Parse large (1000 passages)', () => parse(large), 10));
  results.push(await runBenchmark('Parse complex (features)', () => parse(complex), 500));

  // Memory benchmark
  console.log('Memory usage:');
  const memBefore = measureMemory();

  // Parse many times to measure memory impact
  for (let i = 0; i < 100; i++) {
    parse(large);
  }

  const memAfter = measureMemory();

  console.log(`  Before: ${formatBytes(memBefore.heapUsed)}`);
  console.log(`  After:  ${formatBytes(memAfter.heapUsed)}`);
  console.log(`  Diff:   ${formatBytes(memAfter.heapUsed - memBefore.heapUsed)}`);

  // Print results table
  console.log('\n' + '='.repeat(60));
  console.log('Benchmark Results');
  console.log('='.repeat(60));
  console.log();
  console.log('| Benchmark | Avg (ms) | Min (ms) | Max (ms) | ops/sec |');
  console.log('|-----------|----------|----------|----------|---------|');

  for (const r of results) {
    console.log(
      `| ${r.name.padEnd(30)} | ${r.avgMs.toFixed(3).padStart(8)} | ${r.minMs.toFixed(3).padStart(8)} | ${r.maxMs.toFixed(3).padStart(8)} | ${r.opsPerSec.toFixed(0).padStart(7)} |`
    );
  }

  // Check against targets
  console.log('\n' + '='.repeat(60));
  console.log('Target Comparison');
  console.log('='.repeat(60));
  console.log();

  const largeResult = results.find(r => r.name.includes('1000'));
  if (largeResult) {
    const target = 100; // ms
    const status = largeResult.avgMs < target ? 'PASS' : 'FAIL';
    console.log(`Parse 1000 passages: ${largeResult.avgMs.toFixed(2)}ms (target <${target}ms) [${status}]`);
  }

  const memTarget = 50 * 1024 * 1024; // 50MB
  const memStatus = memAfter.heapUsed < memTarget ? 'PASS' : 'FAIL';
  console.log(`Memory usage: ${formatBytes(memAfter.heapUsed)} (target <50MB) [${memStatus}]`);

  console.log();
}

main().catch(console.error);
