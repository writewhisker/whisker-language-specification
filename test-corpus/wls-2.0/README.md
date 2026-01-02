# WLS 2.0 Test Corpus

This directory contains test cases for all WLS 2.0 features.

## Test Categories

| File | Description | Tests |
|------|-------------|-------|
| `threads.yaml` | Thread spawning and parallel execution | 11 |
| `state-machines.yaml` | LIST state machine operations | 13 |
| `timed.yaml` | Timed content and scheduling | 14 |
| `external.yaml` | External function binding | 14 |
| `parameterized.yaml` | Parameterized passages | 14 |
| `audio.yaml` | Audio/media API | 18 |
| `text-effects.yaml` | Text effects and transitions | 17 |

**Total: 101 tests**

## WLS 2.0 Features Covered

### Threads (threads.yaml)
- Thread passage declaration (`==` syntax)
- Thread spawning from main narrative
- Thread content interleaving
- Await/spawn expressions
- Thread priorities
- Thread lifecycle management

### LIST State Machines (state-machines.yaml)
- Add state (`+=`)
- Remove state (`-=`)
- Check state (`?`)
- Superset (`>=`) and subset (`<=`) checks
- Equality (`==`)
- Multiple active states
- State machine patterns

### Timed Content (timed.yaml)
- `@delay` directive
- `@every` repeating timer
- Timer cancellation
- Pause/resume
- Multiple simultaneous timers
- Time string parsing (ms, s, m, h)

### External Functions (external.yaml)
- EXTERNAL declarations
- Function calls with parameters
- Type checking (string, number, boolean, any)
- Optional parameters
- Async functions
- Error handling

### Parameterized Passages (parameterized.yaml)
- Passage parameters
- Default values
- Multiple parameters
- Parameter type handling
- Tunnel calls with parameters
- Choice links with parameters
- Variable scope isolation

### Audio API (audio.yaml)
- Audio declarations
- Playback control (play, stop, pause)
- Volume control
- Fade effects (fadeIn, fadeOut, crossfade)
- Channel management (bgm, sfx, voice, ambient)
- Master/channel volume

### Text Effects (text-effects.yaml)
- Transitions (fade-in, slide-*)
- Text effects (typewriter, shake, pulse, glitch)
- Effect options (speed, delay, easing)
- Custom styles
- Progressive reveal

## Running Tests

```bash
cd /path/to/whisker-language-specification
./tools/run-corpus.sh --category=wls-2.0
```

## Test Format

Each test case follows this structure:

```yaml
- name: test-name
  description: Human-readable description
  input: |
    WLS source code
  expected:
    valid: true/false
    output_contains: "text"
    output_sequence:
      - "first"
      - "second"
```

## Version

WLS 2.0
