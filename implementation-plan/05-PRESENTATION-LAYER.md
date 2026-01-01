# Gap 5: Presentation Layer

## Problem Statement

WLS 1.0 has limited support for content presentation and styling:

1. **Rich Text** - Basic markdown but no full specification
2. **Custom Styling** - No CSS-in-WLS mechanism
3. **Media Embedding** - Partial image support, no audio/video
4. **Theming** - No format-wide styling system

Interactive fiction benefits from rich, customizable presentation.

## Goals

1. Formalize rich text/markdown subset
2. Implement CSS class system for styling
3. Add comprehensive media embedding
4. Create theming system for stories
5. Ensure cross-platform rendering consistency

## Syntax Reference

### Rich Text (Markdown Subset)
```whisker
:: FormattedPassage
**Bold text** and *italic text* and ***bold italic***.

> This is a blockquote for spoken dialogue.

A horizontal rule:
---

- Bulleted list item
- Another item

1. Numbered list
2. Second item

`inline code` for technical terms.
```

### Custom Styling
```whisker
:: StyledPassage
.warning {
The bridge looks unstable.
}

.character-dialog.merchant {
"Welcome to my shop!"
}

+ [.dangerous Accept the deal] -> BadEnd
```

### Media Embedding
```whisker
:: MediaPassage
![Forest scene](images/forest.png)
![Portrait](characters/hero.png){width:100px align:right}

[audio](sounds/ambient.mp3){loop autoplay volume:0.5}
[video](cutscenes/intro.mp4){controls}

[embed](widgets/map.html){width:100% height:400px}
```

### Theming
```whisker
THEME "dark-fantasy"

STYLE {
  --bg-color: #1a1a2e;
  --text-color: #eee;
  --accent: #e94560;
  passage-font: "Garamond", serif;
  choice-style: bordered;
}
```

## Affected Files

### whisker-core
- `lib/whisker/parser/ws_parser.lua`
- `lib/whisker/core/content.lua` (new)
- `lib/whisker/core/renderer.lua` (new)

### whisker-editor-web
- `packages/parser/src/parser.ts`
- `packages/parser/src/ast.ts`
- `packages/story-player/src/ContentRenderer.ts`
- `packages/player-ui/src/components/`
- `packages/export/src/formats/`

### whisker-language-specification
- `spec/09-PRESENTATION.md` (new)
- `test-corpus/presentation/`

---

## Phase 5.1: Rich Text Specification

### Task 5.1.1: Define Markdown Subset

**Objective:** Formalize supported markdown syntax.

**Steps:**
1. Document supported inline formatting (bold, italic, code)
2. Document block elements (paragraphs, blockquotes, lists)
3. Define horizontal rules
4. Specify escaping rules
5. Document what is NOT supported

**Deliverables:**
- New `spec/09-PRESENTATION.md` section 9.1

**Estimated tokens:** ~4,000

---

### Task 5.1.2: Define CSS Class Syntax

**Objective:** Specify class application syntax.

**Steps:**
1. Define block class syntax `.class { content }`
2. Define inline class syntax `[.class text]`
3. Define choice class syntax `+ [.class Choice text]`
4. Specify multiple class application
5. Document class naming rules

**Deliverables:**
- Updated `spec/09-PRESENTATION.md` section 9.2

**Estimated tokens:** ~4,000

---

### Task 5.1.3: Define Media Embedding Syntax

**Objective:** Formalize media element syntax.

**Steps:**
1. Define image syntax with attributes
2. Define audio syntax with controls
3. Define video syntax with options
4. Define iframe/embed syntax
5. Specify path resolution rules

**Deliverables:**
- Updated `spec/09-PRESENTATION.md` section 9.3

**Estimated tokens:** ~4,000

---

### Task 5.1.4: Define Theming System

**Objective:** Specify theme configuration.

**Steps:**
1. Define THEME directive
2. Define STYLE block syntax
3. Specify CSS custom properties
4. Document built-in theme variables
5. Specify theme inheritance

**Deliverables:**
- Updated `spec/09-PRESENTATION.md` section 9.4

**Estimated tokens:** ~4,000

---

### Task 5.1.5: Create Test Corpus Cases

**Objective:** Define presentation test cases.

**Steps:**
1. Create `test-corpus/presentation/markdown-tests.yaml`
2. Create `test-corpus/presentation/styling-tests.yaml`
3. Create `test-corpus/presentation/media-tests.yaml`
4. Create `test-corpus/presentation/theme-tests.yaml`
5. Include edge cases

**Deliverables:**
- 40+ presentation test cases

**Estimated tokens:** ~5,000

---

### Review Checkpoint 5.1

**Verification:**
- [ ] Markdown subset fully specified
- [ ] CSS class syntax defined
- [ ] Media embedding complete
- [ ] Theming system specified
- [ ] Test cases comprehensive

**Criteria for proceeding:**
- Specification approved
- Clear rendering expectations
- Path resolution documented

---

## Phase 5.2: Parser Updates

### Task 5.2.1: Markdown Parsing (Lua)

**Objective:** Parse markdown into AST.

**Steps:**
1. Create `parse_inline_formatting()` for bold/italic
2. Create `parse_blockquote()` function
3. Create `parse_list()` function
4. Handle nested formatting
5. Add parser tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~6,000

---

### Task 5.2.2: Markdown Parsing (TypeScript)

**Objective:** Parse markdown in TypeScript.

**Steps:**
1. Implement inline formatting parser
2. Implement block element parser
3. Create AST nodes for each element
4. Handle edge cases
5. Add parser tests

**Code location:** `packages/parser/src/parser.ts`

**Estimated tokens:** ~6,000

---

### Task 5.2.3: CSS Class Parsing (Lua)

**Objective:** Parse CSS class syntax.

**Steps:**
1. Implement `.class { }` block parsing
2. Implement inline class parsing
3. Implement choice class parsing
4. Create `ClassedContentNode`
5. Add parser tests

**Code location:** `lib/whisker/parser/ws_parser.lua`

**Estimated tokens:** ~5,000

---

### Task 5.2.4: CSS Class Parsing (TypeScript)

**Objective:** Parse CSS classes in TypeScript.

**Steps:**
1. Mirror Lua implementation
2. Handle multiple classes
3. Validate class names
4. Add parser tests

**Code location:** `packages/parser/src/parser.ts`

**Estimated tokens:** ~5,000

---

### Task 5.2.5: Media Embedding Parsing

**Objective:** Parse media elements.

**Steps:**
1. Parse image syntax with attributes
2. Parse audio/video elements
3. Parse embed elements
4. Extract attribute key-value pairs
5. Add parser tests

**Code locations:**
- `lib/whisker/parser/ws_parser.lua`
- `packages/parser/src/parser.ts`

**Estimated tokens:** ~6,000

---

### Task 5.2.6: Theme Directive Parsing

**Objective:** Parse THEME and STYLE blocks.

**Steps:**
1. Parse THEME directive
2. Parse STYLE block with CSS
3. Store in story metadata
4. Add parser tests

**Code locations:**
- `lib/whisker/parser/ws_parser.lua`
- `packages/parser/src/parser.ts`

**Estimated tokens:** ~4,000

---

### Review Checkpoint 5.2

**Verification:**
- [ ] Markdown parses correctly
- [ ] CSS classes parsed
- [ ] Media elements parsed
- [ ] Theme directives parsed
- [ ] Parser tests pass

**Criteria for proceeding:**
- All presentation syntax parses
- AST represents all elements

---

## Phase 5.3: Content Renderer Implementation

### Task 5.3.1: Content Renderer (Lua)

**Objective:** Render AST to output format.

**Steps:**
1. Create `lib/whisker/core/content.lua`
2. Implement markdown-to-HTML conversion
3. Handle CSS class wrapping
4. Generate media element HTML
5. Add renderer tests

**Code location:** `lib/whisker/core/content.lua`

**Estimated tokens:** ~6,000

---

### Task 5.3.2: Content Renderer (TypeScript)

**Objective:** Render content in story player.

**Steps:**
1. Update `ContentRenderer.ts`
2. Implement markdown rendering
3. Apply CSS classes
4. Generate media elements
5. Add renderer tests

**Code location:** `packages/story-player/src/ContentRenderer.ts`

**Estimated tokens:** ~6,000

---

### Task 5.3.3: Media Asset Handling

**Objective:** Load and manage media assets.

**Steps:**
1. Implement asset path resolution
2. Handle relative/absolute paths
3. Add asset preloading
4. Handle missing asset errors
5. Add asset tests

**Code locations:**
- `lib/whisker/core/content.lua`
- `packages/story-player/src/StoryPlayer.ts`

**Estimated tokens:** ~5,000

---

### Task 5.3.4: Audio Controller

**Objective:** Manage audio playback.

**Steps:**
1. Implement audio play/pause/stop
2. Handle volume control
3. Implement loop support
4. Handle autoplay restrictions
5. Add audio tests

**Code location:** `packages/player-ui/src/components/`

**Estimated tokens:** ~5,000

---

### Review Checkpoint 5.3

**Verification:**
- [ ] Markdown renders correctly
- [ ] CSS classes apply
- [ ] Media elements display
- [ ] Audio controls work
- [ ] Asset loading works

---

## Phase 5.4: Theming System

### Task 5.4.1: Theme Manager (TypeScript)

**Objective:** Implement theme system.

**Steps:**
1. Create `ThemeManager` class
2. Load theme from story metadata
3. Apply CSS custom properties
4. Handle theme switching
5. Add theme tests

**Code location:** `packages/player-ui/src/components/ThemeManager.ts`

**Estimated tokens:** ~5,000

---

### Task 5.4.2: Built-in Themes

**Objective:** Create default themes.

**Steps:**
1. Create "default" theme
2. Create "dark" theme
3. Create "classic" theme (Twine-like)
4. Create "minimal" theme
5. Document theme customization

**Code location:** `packages/player-ui/src/themes/`

**Estimated tokens:** ~4,000

---

### Task 5.4.3: Theme Export Support

**Objective:** Include themes in exports.

**Steps:**
1. Update HTML export for themes
2. Embed theme CSS in output
3. Handle custom fonts
4. Add export tests

**Code location:** `packages/export/src/formats/`

**Estimated tokens:** ~4,000

---

### Review Checkpoint 5.4

**Verification:**
- [ ] Theme manager works
- [ ] Built-in themes available
- [ ] Custom properties apply
- [ ] Export includes themes
- [ ] Tests pass

---

## Phase 5.5: Validators and Integration

### Task 5.5.1: Presentation Validators

**Objective:** Validate presentation syntax.

**Steps:**
1. Add `WLS-PRS-001: invalid_markdown`
2. Add `WLS-PRS-002: invalid_css_class`
3. Add `WLS-PRS-003: missing_media_asset`
4. Add `WLS-PRS-004: invalid_theme`
5. Add validator tests

**Code locations:**
- `lib/whisker/validators/presentation.lua`
- `packages/story-validation/src/validators/PresentationValidator.ts`

**Estimated tokens:** ~5,000

---

### Task 5.5.2: Asset Validator

**Objective:** Validate media assets exist.

**Steps:**
1. Check image paths
2. Check audio/video paths
3. Warn on missing assets
4. Validate path formats
5. Add validator tests

**Code location:** `packages/story-validation/src/validators/ValidateAssetsValidator.ts`

**Estimated tokens:** ~4,000

---

### Task 5.5.3: Corpus Test Execution

**Objective:** Run all presentation tests.

**Steps:**
1. Run Lua corpus tests
2. Run TypeScript corpus tests
3. Compare rendering output
4. Fix any failures
5. Document coverage

**Estimated tokens:** ~3,000

---

### Task 5.5.4: Update Examples

**Objective:** Add presentation examples.

**Steps:**
1. Create `examples/advanced/21-rich-text.ws`
2. Create `examples/advanced/22-styling.ws`
3. Create `examples/advanced/23-media.ws`
4. Create `examples/advanced/24-theming.ws`
5. Update example index

**Estimated tokens:** ~5,000

---

### Review Checkpoint 5.5 (Gap 5 Complete)

**Verification:**
- [ ] Rich text renders properly
- [ ] CSS classes work
- [ ] Media embeds correctly
- [ ] Theming system functional
- [ ] Validators catch issues
- [ ] Examples work

**Final metrics:**
| Metric | Before | After |
|--------|--------|-------|
| Markdown support | Basic | Full subset |
| CSS classes | None | Full support |
| Media types | Images only | Images, audio, video |
| Theme support | None | Built-in + custom |
| New error codes | 68 | 72 |
| New examples | 20 | 24 |

**New error codes:**
- WLS-PRS-001: invalid_markdown
- WLS-PRS-002: invalid_css_class
- WLS-PRS-003: missing_media_asset
- WLS-PRS-004: invalid_theme

**Sign-off requirements:**
- Presentation layer complete
- Cross-platform parity verified
- Ready for Gap 6
