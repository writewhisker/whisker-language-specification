# Gap 7: Tooling

## Context

Complete the import/export ecosystem, add publishing integrations, and create a build pipeline.

## Repositories

- **whisker-core**: `/Users/jims/code/github.com/writewhisker/whisker-core`
- **whisker-editor-web**: `/Users/jims/code/github.com/writewhisker/whisker-editor-web`
- **specification**: `/Users/jims/code/github.com/whisker-language-specification-1.0`

## Import Formats to Complete

| Format | Status | Files |
|--------|--------|-------|
| Twine (Harlowe) | Partial | `HarloweImporter.ts` |
| Twine (SugarCube) | Partial | `SugarCubeImporter.ts` |
| Twine Archive (.html) | New | `TwineArchiveImporter.ts` |
| Ink (.ink) | New | `InkImporter.ts` |
| ChoiceScript | New | `ChoiceScriptImporter.ts` |

## Export Formats to Add

| Format | Purpose | Files |
|--------|---------|-------|
| Static HTML | Single file, offline | `StaticHTMLExporter.ts` |
| Web App | Deployable PWA | `WebAppExporter.ts` |
| ePub | E-readers | `EPubExporter.ts` |
| PDF | Print/archive | `PDFExporter.ts` |

## Publishing Integrations

- **IFDB**: Generate iFiction XML, Treaty of Babel metadata
- **itch.io**: Butler-compatible archives, metadata
- **GitHub Pages**: Workflow templates

## CLI Tools to Create (whisker-core)

- `bin/whisker-import` - Format import
- `bin/whisker-build` - Build pipeline
- `bin/whisker-publish` - Publishing
- `bin/whisker-init` - Project scaffolding

## Key Files to Modify/Create

### TypeScript (whisker-editor-web)
```
packages/import/src/formats/
├── HarloweImporter.ts      # Complete
├── SugarCubeImporter.ts    # Complete
├── TwineArchiveImporter.ts # New
├── InkImporter.ts          # New
└── ChoiceScriptImporter.ts # New

packages/export/src/
├── formats/
│   ├── StaticHTMLExporter.ts
│   ├── WebAppExporter.ts
│   ├── EPubExporter.ts
│   └── PDFExporter.ts
├── publishing/
│   ├── IFDBPublisher.ts
│   └── ItchPublisher.ts
├── compiler/               # New
├── optimizer/              # New
└── bundler/                # New
```

## Commands

```bash
# Run import tests
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/import test -- --run

# Run export tests
pnpm --filter @writewhisker/export test -- --run

# Test CLI tools
cd /Users/jims/code/github.com/writewhisker/whisker-core
lua bin/whisker-import --help
```

## Build Pipeline Features

1. **Compiler**: Resolve includes, validate, optimize
2. **Asset Optimizer**: Compress images, transcode audio
3. **Bundler**: Combine story + runtime, tree-shake, minify
4. **Source Maps**: Debug production builds

## VCS Integration

- Story diff tool (structural comparison)
- Story merge tool (three-way merge)
- Git diff/merge drivers
- `.gitattributes` template

## Success Criteria

- All import formats work correctly
- All export formats produce valid output
- Publishing integrations documented
- Build pipeline optimizes output
- VCS tools enable collaboration
