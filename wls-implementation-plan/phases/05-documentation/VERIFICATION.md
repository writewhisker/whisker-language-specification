# Phase 5: Documentation Verification

## Pre-Implementation Checks

- [ ] Review existing documentation
- [ ] Set up documentation tooling
- [ ] Create documentation templates
- [ ] Plan information architecture

## API Reference Verification

### TypeScript API Docs
```bash
cd ~/code/github.com/writewhisker/whisker-editor-web

# Generate docs
pnpm typedoc

# Check coverage
pnpm typedoc --validation.notDocumented
# Should report 0 undocumented exports
```

**Verification:**
- [ ] All public exports documented
- [ ] All parameters described
- [ ] Return types documented
- [ ] Examples provided
- [ ] Links to related APIs

### Lua API Docs
```bash
cd ~/code/github.com/writewhisker/whisker-core

# Generate docs
ldoc .

# Open and review
open doc/index.html
```

**Verification:**
- [ ] All modules documented
- [ ] Function signatures correct
- [ ] Examples runnable
- [ ] Cross-references work

## Tutorial Verification

### Tutorial Checklist
For each tutorial:
- [ ] Learning objectives clear
- [ ] Prerequisites listed
- [ ] Steps are numbered
- [ ] Code examples work
- [ ] Exercises have solutions
- [ ] Next steps provided

### Tutorial Count
```bash
ls docs/tutorials/beginner/ | wc -l  # Target: 5
ls docs/tutorials/intermediate/ | wc -l  # Target: 5
ls docs/tutorials/advanced/ | wc -l  # Target: 5
```

### Code Example Validation
```bash
# Extract and run all code examples
./tools/validate-docs.sh

# Check for broken examples
grep -r "```whisker" docs/ | wc -l
# All should be valid WLS
```

## Migration Guide Verification

### Twine Migration
- [ ] Harlowe syntax table complete
- [ ] SugarCube syntax table complete
- [ ] Common macros covered
- [ ] Gotchas documented
- [ ] Automated import referenced

### Ink Migration
- [ ] Knot/stitch mapping clear
- [ ] Variable syntax covered
- [ ] Tunnel explanation
- [ ] Gather explanation
- [ ] Limitations noted

### ChoiceScript Migration
- [ ] Scene mapping explained
- [ ] Choice syntax covered
- [ ] Stats conversion
- [ ] Fairmath note

## Examples Verification

### Example Count
```bash
find examples/ -name "*.ws" | wc -l
# Target: 50+
```

### Example Categories
- [ ] `basic/` has 10+ examples
- [ ] `intermediate/` has 15+ examples
- [ ] `advanced/` has 15+ examples
- [ ] `showcase/` has 3+ complete games

### Example Validation
```bash
# Validate all examples
for f in examples/**/*.ws; do
  whisker validate "$f" || echo "FAIL: $f"
done
```

## Documentation Site Verification

### Site Build
```bash
cd docs
pnpm build
# Should complete without errors
```

### Link Checking
```bash
# Check for broken links
pnpm check-links
# Should report 0 broken links
```

### Search Function
- [ ] Search indexes correctly
- [ ] Results are relevant
- [ ] Code snippets searchable

### Mobile Responsiveness
- [ ] Readable on mobile
- [ ] Navigation works
- [ ] Code blocks scroll

## Quality Checks

### Writing Quality
- [ ] Consistent terminology
- [ ] Active voice preferred
- [ ] Concise sentences
- [ ] Technical terms defined

### Accessibility
- [ ] Alt text on images
- [ ] Proper heading hierarchy
- [ ] Sufficient color contrast
- [ ] Screen reader compatible

### Versioning
- [ ] Version selector works
- [ ] URLs include version
- [ ] Old versions accessible

## Acceptance Criteria

1. **API Reference**
   - [ ] 100% public API coverage
   - [ ] TypeScript and Lua complete
   - [ ] Searchable

2. **Tutorials**
   - [ ] 15 tutorials minimum
   - [ ] All code examples valid
   - [ ] Progressive difficulty

3. **Migration Guides**
   - [ ] Twine (Harlowe + SugarCube)
   - [ ] Ink
   - [ ] ChoiceScript
   - [ ] Syntax tables complete

4. **Examples**
   - [ ] 50+ examples
   - [ ] All validated
   - [ ] Categories covered

5. **Documentation Site**
   - [ ] Builds successfully
   - [ ] No broken links
   - [ ] Search works
   - [ ] Mobile friendly

## Documentation Files Checklist

### Getting Started
- [ ] `docs/getting-started/installation.md`
- [ ] `docs/getting-started/quick-start.md`
- [ ] `docs/getting-started/editor-setup.md`
- [ ] `docs/getting-started/first-story.md`

### Reference
- [ ] `docs/reference/syntax.md`
- [ ] `docs/reference/error-codes.md`
- [ ] `docs/reference/cli.md`
- [ ] `docs/reference/configuration.md`

### Migration
- [ ] `docs/migration/from-twine.md`
- [ ] `docs/migration/from-ink.md`
- [ ] `docs/migration/from-choicescript.md`

### Contributing
- [ ] `docs/community/contributing.md`
- [ ] `docs/community/code-of-conduct.md`
- [ ] `docs/community/resources.md`
