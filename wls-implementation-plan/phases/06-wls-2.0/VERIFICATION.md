# Phase 6: WLS 2.0 Verification

## Pre-Implementation Checks

- [ ] WLS 1.1 complete and stable
- [ ] Migration tool specification ready
- [ ] Breaking changes documented
- [ ] Community feedback collected

## Feature Verification

### Threads

**Parser:**
```bash
# Test thread syntax
echo ':: Main
-> Background
Content
== Background
Loop content
-> Background' | whisker parse
```

**Runtime:**
```bash
# Test thread execution
pnpm --filter @writewhisker/story-player test -- --grep "thread"
busted spec/runtime/thread_spec.lua
```

**Verification:**
- [ ] Thread creation works
- [ ] Content interleaving correct
- [ ] Thread-local variables isolated
- [ ] Synchronization works
- [ ] Thread termination clean

### LIST State Machines

**Parser:**
```bash
echo 'LIST state = (a), b, c
{state += b}
{state ? a}' | whisker parse
```

**Verification:**
- [ ] `+=` adds state
- [ ] `-=` removes state
- [ ] `?` checks containment
- [ ] `>=` checks superset
- [ ] Multi-value states work

### Timed Content

**Parser:**
```bash
echo '@delay 2s {
Content after delay
}' | whisker parse
```

**Runtime:**
```bash
# Test timing
pnpm --filter @writewhisker/story-player test -- --grep "delay"
```

**Verification:**
- [ ] Delay triggers after time
- [ ] Multiple delays queue
- [ ] Pause/resume works
- [ ] Choices appear on time

### External Functions

**Registration:**
```typescript
player.registerExternal('playSound', (id) => {
  // Play sound
});
```

**Verification:**
- [ ] Functions callable from story
- [ ] Parameters pass correctly
- [ ] Return values work
- [ ] Errors handled gracefully
- [ ] Sandboxing in web context

### Audio/Media API

**Verification:**
- [ ] Audio loads
- [ ] Play/pause works
- [ ] Volume control
- [ ] Crossfade works
- [ ] Preloading
- [ ] Multiple channels

### Text Effects

**Verification:**
- [ ] Fade-in transition
- [ ] Typewriter effect
- [ ] Shake effect
- [ ] Custom CSS works
- [ ] Graceful degradation

### Hooks System

**Verification:**
- [ ] Hook declaration
- [ ] Replace operation
- [ ] Append operation
- [ ] Show/hide
- [ ] Hook transitions

### Parameterized Passages

**Verification:**
- [ ] Parameters pass correctly
- [ ] Default values work
- [ ] Type hints respected
- [ ] Works with tunnels

## Migration Tool Verification

### Automatic Migration
```bash
# Migrate 1.x story
whisker migrate story-1x.ws --to=2.0 --output=story-2x.ws

# Verify output valid
whisker validate story-2x.ws

# Compare behavior
./tools/compare-versions.sh story-1x.ws story-2x.ws
```

**Verification:**
- [ ] Valid 1.x stories migrate
- [ ] Warnings for manual review
- [ ] No behavior changes (unless documented)
- [ ] Reserved word conflicts detected

### Compatibility Mode
```bash
# Run 1.x story without migration
whisker play story-1x.ws --compat=1.x
```

- [ ] 1.x stories run unchanged
- [ ] Feature detection works
- [ ] Warning for deprecated syntax

## Cross-Platform Parity

### All Features Match
For each 2.0 feature:
- [ ] TypeScript implementation complete
- [ ] Lua implementation complete
- [ ] Behavior identical
- [ ] Error messages match

### Performance Comparison
```bash
# Benchmark threads
./tools/benchmark.sh threads

# Compare platforms
./tools/compare-performance.sh
```

## Acceptance Criteria

### Threads
- [ ] Thread scheduler works
- [ ] 10+ concurrent threads stable
- [ ] No memory leaks
- [ ] Deterministic interleaving

### State Machines
- [ ] All operators work
- [ ] Complex state transitions
- [ ] Performance acceptable

### Timing
- [ ] Accurate timing (±50ms)
- [ ] Works in all environments
- [ ] Save/load preserves timers

### External Functions
- [ ] Type-safe registration
- [ ] Async functions work
- [ ] Sandboxing secure

### Media
- [ ] Audio works in browsers
- [ ] Mobile compatible
- [ ] Fallbacks for no-audio

### Effects
- [ ] Smooth animations
- [ ] Accessible alternatives
- [ ] Performance ok

### Migration
- [ ] 95%+ auto-migration success
- [ ] Clear manual steps for rest
- [ ] Rollback possible

## Test Corpus Additions

Required for 2.0:
- [ ] `test-corpus/threads/`
- [ ] `test-corpus/state-machines/`
- [ ] `test-corpus/timed-content/`
- [ ] `test-corpus/external-functions/`
- [ ] `test-corpus/audio-media/`
- [ ] `test-corpus/text-effects/`
- [ ] `test-corpus/hooks/`
- [ ] `test-corpus/parameterized/`
- [ ] `test-corpus/migration/`

## Success Metrics

| Metric | WLS 1.1 | WLS 2.0 Target | Actual |
|--------|---------|----------------|--------|
| Ink parity | 70% | 95% | |
| Harlowe parity | 80% | 90% | |
| SugarCube parity | 75% | 85% | |
| Thread support | None | Full | |
| Media API | Basic | Complete | |
| External functions | None | Full | |

## Risk Verification

- [ ] Thread complexity manageable
- [ ] Breaking changes minimal
- [ ] Performance acceptable
- [ ] Migration path clear
- [ ] Documentation complete
