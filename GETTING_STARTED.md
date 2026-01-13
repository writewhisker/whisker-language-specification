# Getting Started: Executing the WLS Process

This guide explains how to execute the Whisker Language Specification implementation using Claude.

## Overview

The process is designed to be executed in **Claude sessions** (like this one). Each prompt file contains instructions that you give to Claude to generate outputs.

## Method 1: Using Claude Code CLI (Recommended)

If you're using Claude Code (this CLI), you can execute prompts directly:

### Step 1: Start Phase 0

```bash
# Navigate to the project
cd /Users/jims/code/github.com/whisker-language-specification-1.0

# Read the first prompt and execute it
cat phase-0-research/prompts/01-twine-analysis.md
```

Then tell Claude:
```
Please execute the task described in phase-0-research/prompts/01-twine-analysis.md
Output the result to phase-0-research/outputs/TWINE_ANALYSIS.md
```

### Step 2: Continue Through Tasks

After each task completes:

1. **Update state:**
   ```
   Please update phase-0-research/STATE.md to mark task 0.1 as complete
   ```

2. **Move to next task:**
   ```
   Please execute phase-0-research/prompts/02-ink-analysis.md
   Output to phase-0-research/outputs/INK_ANALYSIS.md
   ```

### Step 3: Complete Each Phase

Repeat until all 9 Phase 0 tasks are done, then move to Phase 1.

---

## Method 2: Copy-Paste Prompts

If using Claude web interface or API:

### Step 1: Copy the Prompt

Open the prompt file and copy its contents:
```bash
cat phase-0-research/prompts/01-twine-analysis.md
```

### Step 2: Paste into Claude

Paste the prompt content into a new Claude conversation.

### Step 3: Save the Output

Copy Claude's response and save it:
```bash
# Create the output file manually or ask Claude to write it
```

---

## Quick Start Commands

### Execute Phase 0 (Research)

```
I'm starting the WLS project, Phase 0: Research & Design.

Please read:
- whisker-language-specification-1.0/CLAUDE.md
- whisker-language-specification-1.0/phase-0-research/CLAUDE.md
- whisker-language-specification-1.0/phase-0-research/PLAN.md

Then execute task 0.1 from phase-0-research/prompts/01-twine-analysis.md
Write output to phase-0-research/outputs/TWINE_ANALYSIS.md
```

### Continue a Session

```
Resuming WLS Phase 0.
Last completed: Task 0.1 (Twine Analysis)
Next task: 0.2 (Ink Analysis)

Please read phase-0-research/STATE.md for current status,
then execute prompts/02-ink-analysis.md
```

### End a Session

```
Please update phase-0-research/STATE.md with:
- Mark task 0.2 as complete
- Add session notes
- Create compact handoff state for next session
```

---

## Execution Checklist by Phase

### Phase 0: Research (9 sessions, ~2 weeks)

```
Session 1:
[ ] Execute 01-twine-analysis.md → TWINE_ANALYSIS.md
[ ] Update STATE.md

Session 2:
[ ] Execute 02-ink-analysis.md → INK_ANALYSIS.md
[ ] Update STATE.md

Session 3:
[ ] Execute 03-whisker-core-audit.md → WHISKER_CORE_CURRENT.md
[ ] Execute 04-whisker-editor-audit.md → WHISKER_EDITOR_CURRENT.md
[ ] Update STATE.md

Session 4:
[ ] Execute 05-enhancement-proposals.md → ENHANCEMENT_PROPOSALS.md
[ ] Update STATE.md

Session 5:
[ ] Execute 06-design-decisions.md → WLS_DESIGN_DECISIONS.md
[ ] Update STATE.md

Session 6:
[ ] Execute 07-feature-matrix.md → FEATURE_MATRIX.md
[ ] Execute 08-success-criteria.md → SUCCESS_CRITERIA.md
[ ] Update STATE.md

Session 7:
[ ] Execute 09-phase-summary.md → PHASE_0_SUMMARY.md
[ ] Review all outputs
[ ] Mark Phase 0 complete
```

### Phase 1: Specification (15 sessions, ~3 weeks)

```
[ ] 1.1 Introduction → spec/01-INTRODUCTION.md
[ ] 1.2 Core Concepts → spec/02-CORE_CONCEPTS.md
[ ] 1.3 Syntax → spec/03-SYNTAX.md
[ ] 1.4 Variables → spec/04-VARIABLES.md
[ ] 1.5 Control Flow → spec/05-CONTROL_FLOW.md
[ ] 1.6 Choices → spec/06-CHOICES.md
[ ] 1.7 Lua API → spec/07-LUA_API.md
[ ] 1.8 File Formats → spec/08-FILE_FORMATS.md
[ ] 1.9 EBNF Grammar → GRAMMAR.ebnf
[ ] 1.10 JSON Schema → shared/schemas/wls.schema.json
[ ] 1.11 Examples → spec/09-EXAMPLES.md
[ ] 1.12 Best Practices → spec/10-BEST_PRACTICES.md
[ ] 1.13 Test Corpus → test-corpus/
[ ] 1.14 Appendices → spec/APPENDICES.md
[ ] 1.15 Compile Spec → spec/WLS-COMPLETE.md
```

### Phase 2 & 3: Implementation (parallel, ~7 weeks)

These involve actual code changes to:
- `writewhisker/whisker-core`
- `writewhisker/whisker-editor-web`

### Phase 4: Validation (~2 weeks)

Cross-platform testing and final documentation.

---

## Example Full Session

Here's what a complete session looks like:

**You say:**
```
I'm working on WLS Phase 0, Task 0.1.

Please:
1. Read phase-0-research/prompts/01-twine-analysis.md
2. Research Twine story formats (Harlowe, SugarCube, Chapbook)
3. Write the analysis to phase-0-research/outputs/TWINE_ANALYSIS.md
4. Update phase-0-research/STATE.md to mark 0.1 as complete
```

**Claude does:**
- Reads the prompt
- Researches Twine (may use web search)
- Writes TWINE_ANALYSIS.md
- Updates STATE.md

**You verify:**
```
cat phase-0-research/outputs/TWINE_ANALYSIS.md
cat phase-0-research/STATE.md
```

**You continue:**
```
Great! Now execute task 0.2: phase-0-research/prompts/02-ink-analysis.md
```

---

## Tips for Efficient Execution

### 1. Batch Related Tasks
```
Please execute tasks 0.3 and 0.4 together since they're both audits.
Write outputs to:
- phase-0-research/outputs/WHISKER_CORE_CURRENT.md
- phase-0-research/outputs/WHISKER_EDITOR_CURRENT.md
```

### 2. Reference Previous Outputs
```
For task 0.5 (Enhancement Proposals), please reference:
- phase-0-research/outputs/TWINE_ANALYSIS.md
- phase-0-research/outputs/INK_ANALYSIS.md
Then write ENHANCEMENT_PROPOSALS.md
```

### 3. Use State for Context
```
Read phase-0-research/STATE.md for context on what's been decided,
then continue with task 0.6.
```

### 4. Verify Before Proceeding
```
Before starting Phase 1, please:
1. List all files in phase-0-research/outputs/
2. Verify all 9 deliverables exist
3. Summarize the key decisions from WLS_DESIGN_DECISIONS.md
```

---

## Starting Right Now

To begin immediately, say:

```
Let's start the WLS project.

Please:
1. Read whisker-language-specification-1.0/phase-0-research/CLAUDE.md
2. Execute task 0.1 from prompts/01-twine-analysis.md
3. Write output to phase-0-research/outputs/TWINE_ANALYSIS.md
4. Update STATE.md when complete
```

This will kick off the first task of the project!
