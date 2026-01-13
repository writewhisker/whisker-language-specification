# Chapter 13: Presentation Layer

This chapter specifies WLS's presentation features including rich text formatting, CSS classes for styling, media embedding, and theming.

## 13.1 Rich Text (Markdown Subset)

WLS supports a carefully selected subset of Markdown for rich text formatting. This subset is designed to be easy to write, unambiguous to parse, and suitable for interactive fiction.

### 13.1.1 Inline Formatting

| Syntax | Result | Notes |
|--------|--------|-------|
| `**text**` | **Bold** | Strong emphasis |
| `*text*` | *Italic* | Emphasis |
| `***text***` | ***Bold Italic*** | Combined emphasis |
| `` `code` `` | `code` | Inline code/monospace |
| `~~text~~` | ~~Strikethrough~~ | Deleted text |

**Escaping:** Use backslash to escape formatting characters:
```whisker
\*not italic\* displays as *not italic*
\`not code\` displays as `not code`
```

**Nesting Rules:**
- Bold can contain italic: `**bold and *italic* text**`
- Italic can contain bold: `*italic and **bold** text*`
- Code cannot contain other formatting (displayed literally)

### 13.1.2 Block Elements

#### Paragraphs

Paragraphs are separated by blank lines:

```whisker
:: Example
This is the first paragraph.

This is the second paragraph.
```

#### Blockquotes

Blockquotes use the `>` prefix, ideal for dialogue or emphasis:

```whisker
:: Dialogue
The merchant speaks:

> "Welcome, traveler! I have wares if you have coin."

You consider your options.
```

Nested blockquotes are supported:

```whisker
> First level
> > Nested quote
> > > Deeply nested
```

#### Lists

**Unordered lists** use `-`, `*`, or `+`:

```whisker
Your inventory:
- Rusty sword
- Leather armor
- 10 gold coins
```

**Ordered lists** use numbers followed by `.`:

```whisker
Your objectives:
1. Find the lost amulet
2. Return it to the wizard
3. Claim your reward
```

**Nested lists** use indentation (2 or 4 spaces):

```whisker
Equipment:
- Weapons
  - Sword
  - Bow
- Armor
  - Helmet
  - Shield
```

#### Horizontal Rules

Three or more dashes, asterisks, or underscores create a horizontal rule:

```whisker
The first act ends here.

---

Act II: The Journey Continues
```

### 13.1.3 What Is NOT Supported

The following Markdown features are intentionally NOT supported to keep the language simple and unambiguous:

- **Headers** (`#`, `##`, etc.) - Use passage titles instead
- **Links** (`[text](url)`) - Conflicts with choice syntax
- **Images in Markdown** - Use WLS media syntax instead
- **Tables** - Use structured content or external assets
- **HTML** - Security concern, use styling system instead
- **Footnotes** - Not suitable for IF
- **Task lists** - Use variables for tracking

## 13.2 CSS Classes for Styling

WLS provides a CSS class system for applying custom styles to content without embedding raw CSS.

### 13.2.1 Block-Level Classes

Apply classes to content blocks using `.class { content }`:

```whisker
:: Warning
.warning {
The bridge looks unstable. Proceed with caution.
}

.success {
You made it across safely!
}
```

**Multiple classes** can be applied by chaining:

```whisker
.dialog.merchant {
"I have just what you need!"
}
```

### 13.2.2 Inline Classes

Apply classes to inline content using `[.class content]`:

```whisker
:: Combat
You deal [.damage 15 damage] to the goblin.
The goblin's health drops to [.health 35/50].
```

### 13.2.3 Choice Classes

Apply classes to choices for visual distinction:

```whisker
:: Crossroads
+ [.safe Go around the mountain] -> SafePath
+ [.dangerous Cross the bridge] -> DangerPath
+ [.locked Enter the castle] {$hasKey} -> Castle
```

### 13.2.4 Class Naming Rules

Valid class names must:
- Start with a letter (a-z, A-Z) or hyphen
- Contain only letters, numbers, hyphens, and underscores
- Not start with a number

```
Valid:   warning, my-class, dialog_box, _hidden
Invalid: 123class, .nested, class name
```

### 13.2.5 Reserved Classes

The following class names have predefined meanings:

| Class | Purpose |
|-------|---------|
| `.error` | Error message styling |
| `.warning` | Warning message styling |
| `.success` | Success message styling |
| `.info` | Informational message styling |
| `.dialog` | Dialogue/speech styling |
| `.narrator` | Narrator text styling |
| `.hidden` | Visually hidden (for screen readers) |
| `.centered` | Centered text |
| `.right` | Right-aligned text |
| `.small` | Smaller text |
| `.large` | Larger text |

## 13.3 Media Embedding

WLS supports embedding images, audio, video, and external content.

### 13.3.1 Images

Basic image syntax:

```whisker
![Alt text](path/to/image.png)
```

With attributes:

```whisker
![Portrait](characters/hero.png){width:100px height:100px}
![Scene](backgrounds/forest.png){align:center}
![Icon](ui/coin.png){width:32px align:right}
```

**Supported attributes:**
| Attribute | Values | Default |
|-----------|--------|---------|
| `width` | pixels, percentage | auto |
| `height` | pixels, percentage | auto |
| `align` | left, center, right | left |
| `class` | CSS class name | none |

### 13.3.2 Audio

```whisker
[audio](path/to/sound.mp3)
```

With attributes:

```whisker
[audio](music/ambient.mp3){loop autoplay volume:0.5}
[audio](sfx/explosion.wav){volume:0.8}
```

**Supported attributes:**
| Attribute | Values | Default |
|-----------|--------|---------|
| `loop` | (flag) | false |
| `autoplay` | (flag) | false |
| `controls` | (flag) | true |
| `volume` | 0.0 - 1.0 | 1.0 |
| `id` | identifier | auto |

**Note:** Browser autoplay restrictions may prevent autoplay without user interaction.

### 13.3.3 Video

```whisker
[video](path/to/video.mp4)
```

With attributes:

```whisker
[video](cutscenes/intro.mp4){controls autoplay muted}
[video](tutorials/combat.webm){width:640px height:360px}
```

**Supported attributes:**
| Attribute | Values | Default |
|-----------|--------|---------|
| `controls` | (flag) | true |
| `autoplay` | (flag) | false |
| `muted` | (flag) | false |
| `loop` | (flag) | false |
| `width` | pixels, percentage | auto |
| `height` | pixels, percentage | auto |
| `poster` | image path | none |

### 13.3.4 Embedded Content

For interactive widgets or external content:

```whisker
[embed](widgets/map.html){width:100% height:400px}
[embed](https://example.com/widget){sandbox}
```

**Supported attributes:**
| Attribute | Values | Default |
|-----------|--------|---------|
| `width` | pixels, percentage | 100% |
| `height` | pixels, percentage | 300px |
| `sandbox` | (flag) | true |
| `allow` | permission list | none |

**Security Note:** Embedded content runs in a sandboxed iframe by default.

### 13.3.5 Path Resolution

Media paths are resolved relative to the story file:

```
story.ws
assets/
  images/
    hero.png
  audio/
    music.mp3

In story.ws:
![Hero](assets/images/hero.png)
[audio](assets/audio/music.mp3)
```

Absolute URLs are also supported:

```whisker
![Logo](https://example.com/logo.png)
```

## 13.4 Theming System

WLS includes a theming system for consistent visual styling.

### 13.4.1 THEME Directive

Select a built-in or custom theme:

```whisker
THEME "dark"
```

Built-in themes:
| Theme | Description |
|-------|-------------|
| `default` | Light theme with neutral colors |
| `dark` | Dark theme with light text |
| `classic` | Classic IF styling (Twine-inspired) |
| `minimal` | Clean, minimal styling |
| `sepia` | Warm, book-like appearance |

### 13.4.2 STYLE Block

Define custom CSS properties:

```whisker
STYLE {
  --bg-color: #1a1a2e;
  --text-color: #eee;
  --accent-color: #e94560;
  --link-color: #4ecdc4;
  --choice-bg: #16213e;
  --choice-hover: #0f3460;
}
```

### 13.4.3 Theme Variables

Standard theme variables that can be customized:

**Colors:**
```
--bg-color          Background color
--text-color        Primary text color
--accent-color      Accent/highlight color
--link-color        Link and choice text color
--choice-bg         Choice button background
--choice-hover      Choice button hover state
--error-color       Error message color
--warning-color     Warning message color
--success-color     Success message color
```

**Typography:**
```
--font-family       Primary font family
--font-size         Base font size
--line-height       Line height
--heading-font      Heading font family
```

**Spacing:**
```
--passage-padding   Passage content padding
--choice-gap        Gap between choices
--paragraph-margin  Margin between paragraphs
```

### 13.4.4 Complete Theme Example

```whisker
@title: Dark Fantasy Adventure
@theme: custom

STYLE {
  --bg-color: #0d0d0d;
  --text-color: #c9c9c9;
  --accent-color: #8b0000;
  --link-color: #cd853f;
  --choice-bg: #1a1a1a;
  --choice-hover: #2d2d2d;
  --font-family: "Crimson Text", Georgia, serif;
  --heading-font: "Cinzel", serif;
  --font-size: 18px;
  --line-height: 1.7;
  --passage-padding: 2rem;
}

:: Start
# The Dark Tower

*You stand before the obsidian gates...*
```

## 13.5 Presentation AST Nodes

### 13.5.1 Rich Text Nodes

```
FormattedTextNode {
  type: "formatted_text"
  format: "bold" | "italic" | "bold_italic" | "code" | "strikethrough"
  content: ContentNode[]
}

BlockquoteNode {
  type: "blockquote"
  content: ContentNode[]
  depth: number
}

ListNode {
  type: "list"
  ordered: boolean
  items: ListItemNode[]
}

ListItemNode {
  type: "list_item"
  content: ContentNode[]
  children: ListNode | null  // For nested lists
}

HorizontalRuleNode {
  type: "horizontal_rule"
}
```

### 13.5.2 Styling Nodes

```
ClassedBlockNode {
  type: "classed_block"
  classes: string[]
  content: ContentNode[]
}

ClassedInlineNode {
  type: "classed_inline"
  classes: string[]
  content: ContentNode[]
}
```

### 13.5.3 Media Nodes

```
ImageNode {
  type: "image"
  alt: string
  src: string
  attributes: MediaAttributes
}

AudioNode {
  type: "audio"
  src: string
  attributes: AudioAttributes
}

VideoNode {
  type: "video"
  src: string
  attributes: VideoAttributes
}

EmbedNode {
  type: "embed"
  src: string
  attributes: EmbedAttributes
}
```

### 13.5.4 Theme Nodes

```
ThemeDirectiveNode {
  type: "theme_directive"
  themeName: string
}

StyleBlockNode {
  type: "style_block"
  properties: Map<string, string>
}
```

## 13.6 Error Codes

| Code | Name | Severity | Description |
|------|------|----------|-------------|
| WLS-PRS-001 | invalid_markdown | error | Malformed markdown syntax |
| WLS-PRS-002 | invalid_css_class | error | Invalid CSS class name |
| WLS-PRS-003 | missing_media_asset | warning | Referenced media file not found |
| WLS-PRS-004 | invalid_theme | error | Unknown or invalid theme name |
| WLS-PRS-005 | invalid_media_attribute | warning | Unknown media attribute |
| WLS-PRS-006 | unclosed_formatting | error | Unclosed formatting (e.g., missing `**`) |
| WLS-PRS-007 | invalid_style_property | warning | Unknown CSS custom property |
| WLS-PRS-008 | nested_blockquote_depth | warning | Blockquote nesting exceeds limit |

## 13.7 Best Practices

### 13.7.1 Accessibility

- Always provide alt text for images
- Use semantic classes (`.warning`, `.error`) not visual ones (`.red`)
- Ensure sufficient color contrast in custom themes
- Provide audio controls (avoid autoplay)
- Include text alternatives for audio/video content

### 13.7.2 Performance

- Optimize image sizes before embedding
- Use appropriate formats (WebP for images, MP3/OGG for audio)
- Preload critical assets
- Consider lazy loading for non-essential media

### 13.7.3 Cross-Platform

- Test themes on multiple browsers
- Use relative paths for portability
- Provide fallback fonts in font stacks
- Test with and without JavaScript enabled
