# Phase 3: Tooling Verification

## Pre-Implementation Checks

- [ ] Review existing export code in `packages/export/`
- [ ] Check CLI structure in `packages/cli/`
- [ ] Gather sample Twine stories for testing
- [ ] Gather sample Ink stories for testing

## Import Verification

### Twine Import
```bash
cd ~/code/github.com/writewhisker/whisker-editor-web

# Test Harlowe import
whisker import test-data/harlowe-story.html --from=twine
# Verify output is valid WLS

# Test SugarCube import
whisker import test-data/sugarcube-story.html --from=twine
# Verify output is valid WLS
```

**Conversion Accuracy:**
- [ ] Passages preserved
- [ ] Links converted correctly
- [ ] Variables converted
- [ ] Conditionals converted
- [ ] Macros converted (where possible)
- [ ] Metadata preserved (tags, position)

### Ink Import
```bash
whisker import test-data/ink-story.ink --from=ink
```

- [ ] Knots -> Passages
- [ ] Stitches -> Sub-passages or inline
- [ ] Choices preserved
- [ ] Variables converted
- [ ] Diverts -> Links
- [ ] Gathers -> Gather points

### ChoiceScript Import
```bash
whisker import test-data/choicescript/ --from=choicescript
```

- [ ] Scenes -> Passages
- [ ] Choices preserved
- [ ] Stats -> Variables
- [ ] `*if` -> Conditionals

## Export Verification

### HTML Export
```bash
whisker export story.ws --to=html --output=story.html

# Open in browser
open story.html
```

**Verify:**
- [ ] Single self-contained file
- [ ] Story plays correctly
- [ ] Styling applied
- [ ] No external dependencies
- [ ] Works offline

### PWA Export
```bash
whisker export story.ws --to=pwa --output=pwa-dist/

# Serve and test
cd pwa-dist && python -m http.server 8000
```

**Verify:**
- [ ] manifest.json present
- [ ] Service worker registered
- [ ] Installable on mobile
- [ ] Works offline
- [ ] Updates when changed

### ePub Export
```bash
whisker export story.ws --to=epub --output=story.epub

# Validate ePub
epubcheck story.epub
```

**Verify:**
- [ ] Valid ePub 3 structure
- [ ] Readable in ebook readers
- [ ] Interactive elements work (where supported)
- [ ] Fallback for non-interactive readers

## CLI Verification

### Build Command
```bash
# Watch mode
whisker build --watch &
# Modify story file
echo ":: NewPassage" >> story.ws
# Verify rebuild triggered
kill %1

# Minified output
whisker build --minify --output=dist/
ls -la dist/
# Verify smaller file size
```

### Publish Command
```bash
# Dry run
whisker publish --platform=ifdb --dry-run
# Verify metadata prepared correctly

# Actual publish (requires credentials)
whisker publish --platform=itch
```

## Round-Trip Testing

Import a story, export it back, compare:

```bash
# Twine round-trip
whisker import original.html --from=twine --output=story.ws
whisker export story.ws --to=html --output=exported.html
# Compare key features manually

# Ink round-trip (limited)
whisker import original.ink --from=ink --output=story.ws
# Export doesn't go back to Ink, but verify WLS is valid
```

## Cross-Platform Parity

### TypeScript CLI
```bash
cd ~/code/github.com/writewhisker/whisker-editor-web
npx whisker import test.html --from=twine > /tmp/ts-import.ws
```

### Lua CLI
```bash
cd ~/code/github.com/writewhisker/whisker-core
lua bin/whisker import test.html --from=twine > /tmp/lua-import.ws
```

### Compare
```bash
diff /tmp/ts-import.ws /tmp/lua-import.ws
# Expected: identical or semantically equivalent
```

## Acceptance Criteria

1. **Twine Import**
   - [ ] Harlowe 3.x supported
   - [ ] SugarCube 2.x supported
   - [ ] Common macros converted
   - [ ] Round-trip maintains story integrity

2. **Ink Import**
   - [ ] Basic story structure preserved
   - [ ] Variables and logic converted
   - [ ] Complex features flagged for manual review

3. **HTML Export**
   - [ ] Self-contained file
   - [ ] All themes work
   - [ ] Mobile responsive

4. **PWA Export**
   - [ ] Installable
   - [ ] Offline capable
   - [ ] Lighthouse score > 90

5. **CLI Tools**
   - [ ] All commands implemented
   - [ ] Help text complete
   - [ ] Error messages helpful
   - [ ] Exit codes correct

## Test Corpus

Required test files:
- [ ] `test-corpus/import/harlowe-basic.html`
- [ ] `test-corpus/import/harlowe-advanced.html`
- [ ] `test-corpus/import/sugarcube-basic.html`
- [ ] `test-corpus/import/sugarcube-advanced.html`
- [ ] `test-corpus/import/ink-basic.ink`
- [ ] `test-corpus/import/ink-advanced.ink`
- [ ] `test-corpus/export/expected-html/`
- [ ] `test-corpus/export/expected-pwa/`

## Error Handling

- [ ] Invalid Twine archive: clear error message
- [ ] Unsupported macro: warning with location
- [ ] Missing passage: error with suggestions
- [ ] Export failure: rollback partial output
