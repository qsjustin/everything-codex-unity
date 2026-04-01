# Agent Guide

How to use, customize, and create agents for everything-claude-unity.

---

## All 12 Agents at a Glance

| Agent | Model | Description |
|-------|-------|-------------|
| `unity-coder` | opus | Implements gameplay systems, components, and managers with correct asmdef placement |
| `unity-prototyper` | opus | End-to-end rapid prototyping -- one prompt to playable prototype |
| `unity-scene-builder` | opus | Builds scenes from natural language descriptions entirely via MCP |
| `unity-fixer` | opus | Diagnoses and fixes bugs using console errors and live API inspection |
| `unity-optimizer` | opus | Profiles performance and fixes CPU/GPU bottlenecks, GC spikes, draw calls |
| `unity-shader-dev` | opus | Creates HLSL/ShaderLab shaders, ShaderGraph nodes, compute shaders |
| `unity-network-dev` | opus | Implements multiplayer networking (Netcode, Mirror, Photon, Fish-Net) |
| `unity-ui-builder` | opus | Builds UI with UGUI Canvas or UI Toolkit, handles safe areas and responsive layouts |
| `unity-reviewer` | sonnet | Reviews code for correctness, performance, serialization safety, and Unity pitfalls |
| `unity-test-runner` | sonnet | Writes and runs EditMode/PlayMode tests, reports results |
| `unity-build-runner` | sonnet | Configures builds, platform switching, player settings, Addressables |
| `unity-migrator` | sonnet | Handles Unity version upgrades, render pipeline migration, deprecated API updates |

---

## When to Use Each Agent

```
What do you need?
|
+-- Write new gameplay code?
|     +-- From scratch with a scene? ---------> unity-prototyper
|     +-- Just the C# scripts? ---------------> unity-coder
|     +-- Multiplayer/networking? -------------> unity-network-dev
|     +-- UI screens? -------------------------> unity-ui-builder
|     +-- Shaders? ----------------------------> unity-shader-dev
|
+-- Build or modify a scene?
|     +-- Scene layout from description? ------> unity-scene-builder
|
+-- Fix or improve existing code?
|     +-- Bug / error in console? -------------> unity-fixer
|     +-- Performance issue? ------------------> unity-optimizer
|     +-- Code review? ------------------------> unity-reviewer
|
+-- Test or build?
|     +-- Write and run tests? ----------------> unity-test-runner
|     +-- Build for a platform? ---------------> unity-build-runner
|
+-- Upgrade or migrate?
      +-- Unity version, pipeline, APIs? ------> unity-migrator
```

---

## How Agents Are Selected

Agents are invoked in two ways:

1. **By commands** -- when you run `/unity-prototype`, the command delegates to the `unity-prototyper` agent automatically.
2. **Manually** -- you can ask Claude to use a specific agent: "Use the unity-reviewer agent to check this file."

Most users interact through commands and never need to name agents directly. The command layer handles agent selection based on the task.

---

## Agent Frontmatter Reference

Every agent is a Markdown file in `.claude/agents/` with YAML frontmatter:

```yaml
---
name: unity-coder                    # Unique identifier
description: "Implements features"   # One-line summary
model: opus                          # opus | sonnet | haiku
color: green                         # Terminal display color
tools: Read, Write, Edit, Glob, Grep, Bash, mcp__unityMCP__*
---
```

### Field Details

**name** -- Must be unique across all agents. Used by commands to reference the agent.

**description** -- Displayed when listing agents. Keep it under 120 characters.

**model** -- Controls which Claude model runs the agent:
- `opus` -- best reasoning, creative implementation, complex debugging
- `sonnet` -- fast and capable, good for review, analysis, and structured tasks
- `haiku` -- fastest and cheapest, suitable for simple lookups and formatting

**color** -- Visual indicator in the terminal. Options: red, green, yellow, blue, magenta, cyan.

**tools** -- Comma-separated list of allowed tools. Common values:
- `Read, Glob, Grep` -- read-only access (reviewers, analyzers)
- `Read, Write, Edit, Glob, Grep, Bash` -- full code access
- `mcp__unityMCP__*` -- all unity-mcp tools (wildcard)
- `Agent` -- ability to spawn sub-agents

---

## Customizing Agents

### Changing the Model

If an agent is too slow or too expensive for your needs, change the `model` field:

```yaml
# Make the reviewer use haiku for faster, cheaper reviews
model: haiku
```

Trade-off: cheaper models may miss subtle Unity-specific issues.

### Adding or Removing Tools

To give the reviewer write access for auto-fixing:

```yaml
# Before
tools: Read, Glob, Grep

# After
tools: Read, Write, Edit, Glob, Grep
```

To remove MCP access from an agent (if you do not use unity-mcp):

```yaml
# Before
tools: Read, Write, Edit, Glob, Grep, Bash, Agent, mcp__unityMCP__*

# After
tools: Read, Write, Edit, Glob, Grep, Bash, Agent
```

### Editing Instructions

The Markdown body below the frontmatter contains the agent's instructions. You can:

- Add project-specific conventions
- Remove checklist items that do not apply
- Add new checks relevant to your codebase
- Reference additional skills to load

---

## Creating a New Agent

### Step 1: Create the File

Create a new `.md` file in `.claude/agents/`:

```bash
touch .claude/agents/unity-localization.md
```

### Step 2: Write the Frontmatter

```yaml
---
name: unity-localization
description: "Manages localization — string tables, font assets, RTL support, locale switching, and Unity Localization package integration."
model: sonnet
color: cyan
tools: Read, Write, Edit, Glob, Grep, Bash
---
```

### Step 3: Write the Instructions

```markdown
# Unity Localization Agent

You manage localization for Unity projects using the Unity Localization package.

## Before Making Changes

1. Check if Unity Localization package is installed in Packages/manifest.json
2. Identify existing string tables in Assets/Localization/
3. Check the current locale setup in ProjectSettings

## Tasks You Handle

- Creating and populating string tables
- Setting up locale selectors (system language, player prefs, command line)
- Configuring font assets for different scripts (CJK, Arabic, Devanagari)
- RTL layout support
- Smart strings with pluralization and gender
- Addressable asset tables for localized sprites/audio

## Rules

- Always use table references, never hardcoded strings
- String table entries use snake_case keys: `menu_start_game`, `dialog_npc_greeting_01`
- Every user-facing string must go through the localization system
- Provide fallback locale (English) for every entry
```

### Step 4: Create a Command (Optional)

To make your agent accessible via a slash command, create `.claude/commands/unity-localize.md`:

```yaml
---
name: unity-localize
description: "Manage project localization"
user-invocable: true
args: task_description
---

# /unity-localize

Use the `unity-localization` agent to handle: **$ARGUMENTS**
```

---

## Model Selection Guide

| Use Case | Recommended Model | Reasoning |
|----------|-------------------|-----------|
| Implement a new gameplay system | opus | Needs to understand architecture, write correct code, wire up components |
| Build a scene from description | opus | Creative interpretation, complex MCP tool orchestration |
| Debug a subtle issue | opus | Needs deep reasoning about Unity lifecycle, serialization, threading |
| Write shaders | opus | HLSL requires precise understanding of GPU pipelines |
| Review code | sonnet | Structured checklist, pattern matching, faster turnaround |
| Write unit tests | sonnet | Test patterns are well-defined, speed matters for iteration |
| Run a build | sonnet | Mostly configuration and tool invocation |
| Migrate deprecated APIs | sonnet | Mapping old API to new API is well-documented |
| Format or rename files | haiku | Simple mechanical task |

---

## Tips for Effective Agent Prompts

1. **Be specific about the scope.** "Add a health system to the player" is better than "improve the player."

2. **Name the Unity subsystems involved.** "Use the Input System and Cinemachine" helps the agent load the right skills.

3. **Reference existing code.** "Follow the pattern in EnemyController.cs" gives the agent a concrete example.

4. **State constraints up front.** "Must support mobile (no compute shaders)" prevents wasted work.

5. **For prototypes, describe the feel.** "Tight, responsive controls like Celeste" conveys more than a feature list.

6. **Let the agent ask questions.** If you give a vague prompt, a good agent will ask for clarification rather than guess.
