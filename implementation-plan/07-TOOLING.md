# Gap 7: Tooling

## Problem Statement

WLS 1.0 lacks production-ready tooling for:

1. **Twine Import** - Converting Twine formats is partial
2. **IF Publishing** - No IFDB, itch.io integration
3. **Version Control** - Basic versioning, no diff/merge
4. **Build Pipeline** - No compilation, bundling, or optimization

Professional IF development needs complete tooling.

## Goals

1. Complete Twine format import/export
2. Add publishing integrations
3. Implement story diff/merge for VCS
4. Create build pipeline with optimization
5. Add project scaffolding tools

## Features Overview

### Import/Export
- Complete Twine 2 (Harlowe, SugarCube) import
- Twine archive (.html) import
- Ink (.ink) import
- Choice of Games (ChoiceScript) import
- Export to multiple web formats

### Publishing
- IFDB metadata generation
- itch.io integration
- Self-hosted deployment
- PWA generation

### Build Pipeline
- Story compilation
- Asset optimization
- Bundle generation
- Source maps

---

## Phase 7.1: Twine Import Completion

### Task 7.1.1: Analyze Twine Formats

**Objective:** Document Twine format differences.

**Steps:**
1. Document Harlowe syntax differences
2. Document SugarCube syntax differences
3. Identify common patterns
4. Identify untranslatable features
5. Create mapping document

**Deliverables:**
- `docs/TWINE_IMPORT.md`

**Estimated tokens:** ~4,000

---

### Task 7.1.2: Harlowe Parser

**Objective:** Parse Harlowe syntax.

**Steps:**
1. Parse Harlowe macros
2. Parse Harlowe hooks
3. Parse Harlowe links
4. Handle Harlowe variables
5. Add parser tests

**Code location:** `packages/import/src/formats/HarloweImporter.ts`

**Estimated tokens:** ~7,000

---

### Task 7.1.3: SugarCube Parser

**Objective:** Parse SugarCube syntax.

**Steps:**
1. Parse SugarCube macros
2. Parse SugarCube widgets
3. Parse SugarCube links
4. Handle SugarCube variables
5. Add parser tests

**Code location:** `packages/import/src/formats/SugarCubeImporter.ts`

**Estimated tokens:** ~7,000

---

### Task 7.1.4: Twine Archive Import

**Objective:** Import from .html archives.

**Steps:**
1. Parse Twine HTML format
2. Extract passage data
3. Detect story format
4. Route to appropriate parser
5. Add archive tests

**Code location:** `packages/import/src/formats/TwineArchiveImporter.ts`

**Estimated tokens:** ~5,000

---

### Task 7.1.5: Syntax Conversion

**Objective:** Convert Twine syntax to WLS.

**Steps:**
1. Map Harlowe macros to WLS
2. Map SugarCube macros to WLS
3. Convert link syntax
4. Convert variable syntax
5. Add conversion tests

**Code location:** `packages/import/src/converters/`

**Estimated tokens:** ~6,000

---

### Review Checkpoint 7.1

**Verification:**
- [ ] Harlowe imports correctly
- [ ] SugarCube imports correctly
- [ ] Archives parse
- [ ] Syntax converts
- [ ] Tests pass

---

## Phase 7.2: Additional Import Formats

### Task 7.2.1: Ink Importer

**Objective:** Import Ink (.ink) files.

**Steps:**
1. Parse Ink knots and stitches
2. Parse Ink choices
3. Parse Ink weave
4. Handle Ink variables
5. Add importer tests

**Code location:** `packages/import/src/formats/InkImporter.ts`

**Estimated tokens:** ~7,000

---

### Task 7.2.2: ChoiceScript Importer

**Objective:** Import ChoiceScript format.

**Steps:**
1. Parse ChoiceScript scenes
2. Parse *choice blocks
3. Parse *if/*else conditions
4. Handle stats/variables
5. Add importer tests

**Code location:** `packages/import/src/formats/ChoiceScriptImporter.ts`

**Estimated tokens:** ~7,000

---

### Task 7.2.3: Import CLI Tool

**Objective:** Create CLI import tool.

**Steps:**
1. Create `bin/whisker-import`
2. Auto-detect input format
3. Handle batch import
4. Output conversion report
5. Add CLI tests

**Code location:** `whisker-core/bin/whisker-import`

**Estimated tokens:** ~4,000

---

### Review Checkpoint 7.2

**Verification:**
- [ ] Ink imports correctly
- [ ] ChoiceScript imports correctly
- [ ] CLI tool works
- [ ] Format detection works

---

## Phase 7.3: Export Formats

### Task 7.3.1: Static HTML Export

**Objective:** Generate standalone HTML.

**Steps:**
1. Embed player runtime
2. Bundle story data
3. Embed assets (base64 or inline)
4. Apply theme
5. Add export tests

**Code location:** `packages/export/src/formats/StaticHTMLExporter.ts`

**Estimated tokens:** ~6,000

---

### Task 7.3.2: Web App Export

**Objective:** Generate deployable web app.

**Steps:**
1. Create index.html
2. Generate asset manifest
3. Create service worker
4. Generate PWA manifest
5. Add export tests

**Code location:** `packages/export/src/formats/WebAppExporter.ts`

**Estimated tokens:** ~6,000

---

### Task 7.3.3: ePub Export

**Objective:** Generate ePub format.

**Steps:**
1. Generate ePub structure
2. Convert passages to XHTML
3. Handle choice linearization
4. Include metadata
5. Add export tests

**Code location:** `packages/export/src/formats/EPubExporter.ts`

**Estimated tokens:** ~7,000

---

### Task 7.3.4: PDF Export

**Objective:** Generate printable PDF.

**Steps:**
1. Create PDF structure
2. Handle branching (numbered sections)
3. Generate table of contents
4. Include passage references
5. Add export tests

**Code location:** `packages/export/src/formats/PDFExporter.ts`

**Estimated tokens:** ~7,000

---

### Review Checkpoint 7.3

**Verification:**
- [ ] HTML export works standalone
- [ ] Web app deploys correctly
- [ ] ePub validates
- [ ] PDF generates
- [ ] All exports tested

---

## Phase 7.4: Publishing Integration

### Task 7.4.1: IFDB Integration

**Objective:** Generate IFDB-compatible metadata.

**Steps:**
1. Create IFID generator
2. Generate Treaty of Babel metadata
3. Create iFiction XML
4. Add IFDB upload instructions
5. Add metadata tests

**Code location:** `packages/export/src/publishing/IFDBPublisher.ts`

**Estimated tokens:** ~5,000

---

### Task 7.4.2: itch.io Integration

**Objective:** Prepare for itch.io publishing.

**Steps:**
1. Generate itch.io game page metadata
2. Create butler-compatible archive
3. Handle versioning
4. Add itch.io manifest
5. Document publishing process

**Code location:** `packages/export/src/publishing/ItchPublisher.ts`

**Estimated tokens:** ~5,000

---

### Task 7.4.3: GitHub Pages Deployment

**Objective:** Enable GitHub Pages publishing.

**Steps:**
1. Generate GitHub Actions workflow
2. Configure for GitHub Pages
3. Handle custom domains
4. Add deployment documentation
5. Create template repository

**Deliverables:**
- `.github/workflows/deploy.yml` template
- Deployment documentation

**Estimated tokens:** ~4,000

---

### Task 7.4.4: Publish CLI

**Objective:** Create CLI publish tool.

**Steps:**
1. Create `bin/whisker-publish`
2. Support multiple targets
3. Handle authentication
4. Show publish progress
5. Add CLI tests

**Code location:** `whisker-core/bin/whisker-publish`

**Estimated tokens:** ~4,000

---

### Review Checkpoint 7.4

**Verification:**
- [ ] IFDB metadata generates
- [ ] itch.io publishing works
- [ ] GitHub Pages deploys
- [ ] CLI tool functional

---

## Phase 7.5: Build Pipeline

### Task 7.5.1: Story Compiler

**Objective:** Compile WLS to optimized format.

**Steps:**
1. Create compilation pipeline
2. Resolve includes
3. Validate complete story
4. Generate compiled output
5. Add compiler tests

**Code location:** `packages/export/src/compiler/`

**Estimated tokens:** ~6,000

---

### Task 7.5.2: Asset Optimizer

**Objective:** Optimize story assets.

**Steps:**
1. Optimize images (resize, compress)
2. Optimize audio (transcode, compress)
3. Generate asset manifest
4. Support lazy loading
5. Add optimizer tests

**Code location:** `packages/export/src/optimizer/`

**Estimated tokens:** ~5,000

---

### Task 7.5.3: Bundle Generator

**Objective:** Create distributable bundles.

**Steps:**
1. Bundle story + runtime
2. Tree-shake unused code
3. Minify JavaScript
4. Generate source maps
5. Add bundler tests

**Code location:** `packages/export/src/bundler/`

**Estimated tokens:** ~5,000

---

### Task 7.5.4: Build CLI

**Objective:** Create CLI build tool.

**Steps:**
1. Create `bin/whisker-build`
2. Support build configurations
3. Add watch mode
4. Add development server
5. Add CLI tests

**Code location:** `whisker-core/bin/whisker-build`

**Estimated tokens:** ~5,000

---

### Review Checkpoint 7.5

**Verification:**
- [ ] Compilation works
- [ ] Assets optimized
- [ ] Bundles generated
- [ ] CLI tool works
- [ ] Development workflow complete

---

## Phase 7.6: VCS Integration

### Task 7.6.1: Story Diff Tool

**Objective:** Generate meaningful diffs.

**Steps:**
1. Parse stories for comparison
2. Compare passages structurally
3. Highlight content changes
4. Handle moved passages
5. Add diff tests

**Code location:** `packages/export/src/vcs/differ.ts`

**Estimated tokens:** ~5,000

---

### Task 7.6.2: Story Merge Tool

**Objective:** Merge story branches.

**Steps:**
1. Implement three-way merge
2. Handle passage conflicts
3. Handle variable conflicts
4. Generate merge report
5. Add merge tests

**Code location:** `packages/export/src/vcs/merger.ts`

**Estimated tokens:** ~6,000

---

### Task 7.6.3: Git Integration

**Objective:** Integrate with git workflows.

**Steps:**
1. Create git diff driver
2. Create git merge driver
3. Add .gitattributes template
4. Document git setup
5. Add integration tests

**Deliverables:**
- Git driver scripts
- `.gitattributes` template

**Estimated tokens:** ~4,000

---

### Task 7.6.4: Project Scaffolding

**Objective:** Create project templates.

**Steps:**
1. Create `whisker-init` command
2. Generate project structure
3. Create starter templates
4. Add git initialization
5. Document templates

**Code location:** `whisker-core/bin/whisker-init`

**Estimated tokens:** ~4,000

---

### Review Checkpoint 7.6 (Gap 7 Complete)

**Verification:**
- [ ] Twine import complete
- [ ] Ink/ChoiceScript import works
- [ ] All export formats work
- [ ] Publishing integration ready
- [ ] Build pipeline functional
- [ ] VCS tools work

**Final metrics:**
| Metric | Before | After |
|--------|--------|-------|
| Import formats | 2 (Twine partial) | 5 (full) |
| Export formats | 2 | 5+ |
| Publishing targets | 0 | 3 |
| CLI tools | 2 | 8 |

**CLI Tools Created:**
- `whisker-import` - Format import
- `whisker-build` - Build pipeline
- `whisker-publish` - Publishing
- `whisker-init` - Project scaffolding

**Sign-off requirements:**
- Complete import/export ecosystem
- Publishing workflow ready
- Ready for Gap 8
