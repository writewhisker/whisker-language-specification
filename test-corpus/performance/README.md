# Performance Test Corpus

This directory contains performance benchmarks for WLS parsing and validation.

## Test Files

### parse-benchmarks.yaml
Parser performance benchmarks:
- Small file benchmarks (10 passages)
- Medium file benchmarks (50 passages)
- Large file benchmarks (200 passages)
- Stress tests (500+ passages, deep nesting)
- Feature-specific benchmarks (unicode, expressions, alternatives)

### validation-benchmarks.yaml
Validator performance benchmarks:
- Structure validation (reachability, cycles, orphans)
- Link validation
- Variable validation
- Expression validation
- Collection validation
- Full validation suite
- Stress tests (many errors, cyclic references)

## Performance Thresholds

### Parser
| Size   | Max Time | Max Memory |
|--------|----------|------------|
| Small  | 50ms     | 10MB       |
| Medium | 200ms    | 50MB       |
| Large  | 1000ms   | 100MB      |
| Stress | 5000ms   | 500MB      |

### Per-Passage Metrics
- Parse time: < 10ms per passage
- Validation time: < 5ms per passage

## Running Benchmarks

### TypeScript
```bash
pnpm benchmark:parse
pnpm benchmark:validate
```

### Lua
```bash
lua tools/benchmark.lua parse
lua tools/benchmark.lua validate
```

## Interpreting Results

Each benchmark outputs:
- `time_ms`: Actual execution time
- `memory_mb`: Peak memory usage
- `passes_threshold`: Whether performance is acceptable
- `per_unit_time`: Time per passage/validator/expression

## Adding New Benchmarks

```yaml
- id: benchmark_name
  description: What this benchmarks
  size: small|medium|large|stress
  passages: 50
  expected_time_ms: 100
  generator:
    passages: 50
    content_lines: 10
    choices_per_passage: 3
```

## Baseline Documentation

Performance baselines are tracked in:
- `baseline-typescript.json`: TypeScript reference measurements
- `baseline-lua.json`: Lua reference measurements

These are updated on each release to track performance regressions.
