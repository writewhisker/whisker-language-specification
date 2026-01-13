# Advanced Features Test Corpus

> **Note**: The `wls-2.0/` directory name is historical. WLS is now a **unified specification** with no version distinctions. These tests cover advanced features that are all part of the single WLS specification.

This directory contains the comprehensive test corpus for advanced WLS features.

## Test Categories

### threads.yaml
Tests for parallel narrative thread execution:
- Thread spawning with `==` syntax
- Thread interleaving
- Await and synchronization
- Thread-local variables
- Priority-based scheduling

### state-machines.yaml
Tests for LIST-based state management:
- LIST definition and initialization
- State transitions (+= -= ^=)
- State queries (? !?)
- Multi-LIST interactions
- Exclusive/single-select LISTs

### timed.yaml
Tests for time-based content:
- `@delay` directive
- `@every` repeating content
- Timer pause/resume/cancel
- Nested delays
- Choice timeouts

### external.yaml
Tests for host application integration:
- `@external` function declarations
- Namespaced functions
- Type checking
- Async functions
- Error handling

### effects.yaml
Tests for text effects:
- Typewriter effect
- Fade in/out
- Shake effect
- Custom effect handlers
- Effect chaining and cancellation

### parameterized.yaml
Tests for passage parameters:
- Basic parameter passing
- Default values
- Typed parameters
- Optional and rest parameters
- Recursive passages

### audio.yaml
Tests for audio integration:
- `@audio` declarations
- Play/stop/pause
- Volume and fading
- Channels and crossfading
- Autoplay on passage entry

### migration.yaml
Tests for legacy syntax migration:
- Reserved word renaming
- Deprecated pattern detection
- Tunnel interaction warnings
- Structure preservation

## Running Tests

```bash
# Run all advanced feature tests
./tools/run-corpus.sh --category=wls-2.0

# Run specific category
./tools/run-corpus.sh wls-2.0/threads.yaml
```

## Test Format

Each test case follows this structure:

```yaml
- name: test-name
  description: Brief description
  input: |
    :: Start
    Story content...
  expected:
    valid: true
    output_contains: "expected text"
  play:
    - wait: 100
      output_contains: "after delay"
```

### Common Assertions

- `valid: true/false` - Story parses correctly
- `output_contains` - Output includes text
- `output_not_contains` - Output excludes text
- `output_sequence` - Text appears in order
- `error_code` - Expected error code
- `warning_code` - Expected warning code
- `threads` - Expected thread count
- `available_choices` - Number of available choices

### Play Sequence

For time-based tests:
- `wait: <ms>` - Wait milliseconds
- `choose: <index>` - Select choice
- `output_*` - Check output state

## Coverage Goals

- All WLS advanced syntax features
- Edge cases and error conditions
- Cross-feature interactions
- Migration scenarios

Total: 100+ test cases across all categories
