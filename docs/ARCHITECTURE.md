# Architecture

Technical documentation for the everything-claude-unity system.

---

## Design Philosophy

This project follows the architecture established by [everything-claude-code](https://github.com/affaan-m/everything-claude-code), adapted for Unity game development:

- **Convention over configuration** -- drop `.claude/` into any Unity project and it works.
- **Safety by default** -- hooks block destructive operations (scene file edits, meta file corruption) before they happen.
- **MCP as the bridge** -- code changes go through normal file editing; scene/editor changes go through unity-mcp tools.
- **Composable knowledge** -- skills are modular and loaded on demand, not bundled into one massive prompt.
- **Agent specialization** -- each agent has a focused role, specific model selection, and limited tool access.

---

## Component Overview

```
.claude/
  settings.json      Configuration: permissions, MCP servers, hook definitions
  agents/            12 agent definitions (.md files with frontmatter)
  commands/          15 user-invocable slash commands
  hooks/              8 shell scripts for pre/post tool validation
  rules/              5 always-loaded coding standards
  skills/            35 knowledge modules in 6 categories
```

Supporting files outside `.claude/`:

```
scripts/             Shell scripts for validation (meta integrity, code quality)
install.sh           One-command installer
templates/           Template files for project scaffolding
```

---

## How Agents Work

Agents are Markdown files in `.claude/agents/` with YAML frontmatter that controls their behavior.

### Frontmatter Fields

| Field | Purpose | Example |
|-------|---------|---------|
| `name` | Identifier used by commands | `unity-coder` |
| `description` | One-line summary shown in agent selection | `"Implements Unity features..."` |
| `model` | Which Claude model to use | `opus`, `sonnet`, `haiku` |
| `color` | Terminal display color | `green`, `blue`, `yellow` |
| `tools` | Allowed tool access list | `Read, Write, Edit, Glob, Grep, Bash, mcp__unityMCP__*` |
| `skills` | Skills to preload | Listed in the agent body or loaded by commands |

### Model Selection

- **Opus** -- complex implementation, creative prototyping, debugging, shader writing (8 agents)
- **Sonnet** -- code review, test writing, migration analysis, build configuration (4 agents)
- **Haiku** -- not currently used, suitable for simple formatting or lookup tasks

### Tool Access

Agents only have access to the tools listed in their frontmatter. This enforces boundaries:

- `unity-reviewer` has `Read, Glob, Grep` only -- it cannot modify files.
- `unity-scene-builder` has `Read, Glob, Grep, mcp__unityMCP__*` -- it controls the editor but does not write code.
- `unity-coder` has full access including `Write, Edit, Bash` and MCP tools.

---

## How Commands Work

Commands are Markdown files in `.claude/commands/` with `user-invocable: true` in frontmatter. Users invoke them with `/command-name` in Claude Code.

Commands are orchestration entry points. They:

1. Accept user arguments (via `$ARGUMENTS`)
2. Define a multi-step workflow
3. Delegate to one or more agents
4. Coordinate the overall task

Example flow for `/unity-prototype`:
```
User: /unity-prototype "2D platformer with wall jumping"
  -> Command: unity-prototype.md (decomposes the task)
    -> Agent: unity-prototyper (writes scripts, builds scene via MCP)
      -> Tools: Write (C# files), mcp__unityMCP__* (scene setup)
```

---

## How Skills Work

Skills are knowledge modules in `.claude/skills/`, organized into categories:

```
skills/
  core/              Fundamentals: assembly defs, events, pooling, MCP patterns
  gameplay/          Game systems: character controller, inventory, dialogue, save
  genre/             Genre patterns: FPS, platformer, RPG
  platform/          Platform specifics: mobile, console, VR
  systems/           Unity subsystems: Input System, Cinemachine, Addressables
  third-party/       Third-party: DOTween, UniTask, VContainer
```

### Discovery

Claude Code discovers skills via glob patterns. Agents reference skills by category path, and the system loads matching `.md` files.

### Always-Apply Skills

Skills with `alwaysApply: true` in frontmatter (like `unity-mcp-patterns`) are loaded for every agent that has MCP tool access. These contain critical patterns that should never be skipped.

---

## How Hooks Work

Hooks are shell scripts in `.claude/hooks/` configured in `settings.json`. They run automatically before or after tool invocations.

### PreToolUse (Blocking)

These run BEFORE a tool executes. Exit codes:
- `0` -- allow the operation
- `2` -- block the operation (Claude sees the error message)

| Hook | Matcher | Purpose |
|------|---------|---------|
| `block-scene-edit.sh` | Edit\|Write | Prevents direct editing of .unity/.prefab/.asset files |
| `block-meta-edit.sh` | Edit\|Write | Prevents editing .meta files |
| `guard-editor-runtime.sh` | Edit\|Write | Prevents UnityEditor code without #if guards |
| `block-projectsettings.sh` | Bash | Prevents manual ProjectSettings changes |

### PostToolUse (Warning)

These run AFTER a tool executes. They warn but do not block:

| Hook | Matcher | Purpose |
|------|---------|---------|
| `warn-serialization.sh` | Edit\|Write | Warns if serialized fields renamed without FormerlySerializedAs |
| `warn-filename.sh` | Edit\|Write | Warns if file name does not match class name |
| `warn-platform-defines.sh` | Edit\|Write | Warns about platform defines without fallback |
| `validate-commit.sh` | Bash | Validates commit messages and checks for common issues |

### Hook Input

Hooks receive JSON on stdin with the tool invocation details (`tool_name`, `tool_input`). They use `jq` to parse and inspect the operation.

---

## How Rules Work

Rules are Markdown files in `.claude/rules/` that are always loaded as context for every conversation. They define coding standards that Claude follows:

| Rule | Content |
|------|---------|
| `csharp-unity.md` | Field naming (m_, s_, k_), explicit types, sealed by default, structure ordering |
| `performance.md` | Zero allocations in Update, cache GetComponent, NonAlloc physics, object pooling |
| `serialization.md` | FormerlySerializedAs on renames, field exposure, Unity null checks |
| `architecture.md` | Composition over inheritance, ScriptableObject data, event channels, no god objects |
| `unity-specifics.md` | Editor vs runtime guards, lifecycle order, threading, coroutine gotchas |

Rules are not optional. They represent hard constraints that every agent follows.

---

## The MCP Integration

The unity-mcp bridge connects Claude Code to the Unity Editor via HTTP. It exposes tools for:

- **Scene management** -- create, load, save, modify scenes
- **GameObject operations** -- create, parent, position, configure
- **Component management** -- add, remove, configure components
- **Prefab operations** -- create, edit, instantiate prefabs
- **Physics** -- layers, collision matrix, raycasts
- **Graphics** -- materials, lighting, rendering settings
- **Profiler** -- frame timing, memory snapshots, rendering stats
- **Build** -- platform switching, player settings, trigger builds
- **Tests** -- run EditMode/PlayMode tests, get results

### The batch_execute Pattern

Individual MCP calls have network overhead. The `batch_execute` tool bundles multiple operations into a single HTTP request, providing 10-100x speedup for multi-step scene construction.

```
batch_execute([
  { "tool": "manage_gameobject", "params": { "action": "create", "name": "Player" } },
  { "tool": "manage_components", "params": { "action": "add", "gameobject": "Player", "component": "Rigidbody" } },
  { "tool": "manage_components", "params": { "action": "add", "gameobject": "Player", "component": "CapsuleCollider" } }
])
```

---

## Agent Interaction Pattern

The standard flow through the system:

```
User Input
  |
  v
Command (orchestration)        <- .claude/commands/
  |
  v
Agent (specialized executor)   <- .claude/agents/
  |                  |
  v                  v
File Tools         MCP Tools
(Read/Write/Edit)  (mcp__unityMCP__*)
  |                  |
  v                  v
C# Source Files    Unity Editor
```

### Three Agent Categories

1. **Code Agents** -- write/edit C# files only, no MCP access
   - `unity-reviewer`, `unity-migrator`

2. **MCP-Powered Agents** -- control Unity Editor only, no file writing
   - `unity-scene-builder`, `unity-build-runner`, `unity-test-runner`

3. **Hybrid Agents** -- both code and MCP access
   - `unity-coder`, `unity-prototyper`, `unity-fixer`, `unity-optimizer`, `unity-shader-dev`, `unity-network-dev`, `unity-ui-builder`

---

## Settings.json Structure

```json
{
  "permissions": {
    "defaultMode": "allowEdits"      // Claude can edit files without asking
  },
  "mcpServers": {
    "unityMCP": {
      "url": "http://localhost:8080/mcp"  // unity-mcp bridge endpoint
    }
  },
  "hooks": {
    "PreToolUse": [ ... ],           // Blocking hooks
    "PostToolUse": [ ... ]           // Warning hooks
  }
}
```

The `settings.local.json.template` provides a starting point for per-developer overrides.

---

## File Organization

This structure follows Claude Code's discovery conventions:

- **agents/** -- auto-discovered by name when referenced by commands or the user
- **commands/** -- auto-discovered and exposed as `/slash-commands`
- **skills/** -- discovered via glob patterns, loaded on demand
- **hooks/** -- referenced by path in `settings.json`, executed by Claude Code runtime
- **rules/** -- all files in this directory are loaded as context automatically

Each component is a standalone Markdown file. No build step, no compilation, no registration. Drop files in the right directory and they work.
