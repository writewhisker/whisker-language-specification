# Gap 5: Presentation Layer

## Context

Add rich content presentation: markdown formatting, CSS classes, media embedding, and theming.

## Repositories

- **whisker-core**: `/Users/jims/code/github.com/writewhisker/whisker-core`
- **whisker-editor-web**: `/Users/jims/code/github.com/writewhisker/whisker-editor-web`
- **specification**: `/Users/jims/code/github.com/whisker-language-specification-1.0`

## Syntax to Implement

### Rich Text (Markdown Subset)
```whisker
**Bold** and *italic* text.
> Blockquote for dialogue.
- Bulleted list
1. Numbered list
```

### CSS Classes
```whisker
.warning {
The bridge looks unstable.
}

+ [.dangerous Accept] -> BadEnd
```

### Media Embedding
```whisker
![Forest](images/forest.png){width:100px}
[audio](sounds/ambient.mp3){loop autoplay}
[video](cutscenes/intro.mp4){controls}
```

### Theming
```whisker
THEME "dark-fantasy"

STYLE {
  --bg-color: #1a1a2e;
  --text-color: #eee;
}
```

## Key Files to Modify

### Lua (whisker-core)
- `lib/whisker/parser/ws_parser.lua` - Parse markdown/media/classes
- `lib/whisker/core/content.lua` - (NEW) Content renderer
- `lib/whisker/validators/presentation.lua` - (NEW)

### TypeScript (whisker-editor-web)
- `packages/parser/src/parser.ts` - Parsing
- `packages/story-player/src/ContentRenderer.ts` - Rendering
- `packages/player-ui/src/components/` - UI components
- `packages/player-ui/src/themes/` - (NEW) Built-in themes
- `packages/export/src/formats/` - Theme export

## Commands

```bash
# Run TypeScript tests
cd /Users/jims/code/github.com/writewhisker/whisker-editor-web
pnpm --filter @writewhisker/parser test -- --run
pnpm --filter @writewhisker/story-player test -- --run
pnpm --filter @writewhisker/player-ui test -- --run
```

## New Error Codes

- `WLS-PRS-001`: invalid_markdown
- `WLS-PRS-002`: invalid_css_class
- `WLS-PRS-003`: missing_media_asset
- `WLS-PRS-004`: invalid_theme

## Implementation Notes

- Define clear markdown subset (not full CommonMark)
- CSS classes should be sanitized for security
- Media paths need resolution rules (relative vs absolute)
- Themes should use CSS custom properties
- Audio autoplay may be blocked by browsers

## Built-in Themes to Create

- `default` - Clean, readable
- `dark` - Dark mode
- `classic` - Twine-like appearance
- `minimal` - Distraction-free

## Success Criteria

- Markdown renders consistently
- CSS classes apply correctly
- Media embeds work (images, audio, video)
- Themes can be applied and customized
- Exports include theme styling
