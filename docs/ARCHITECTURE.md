# Architecture

Technical documentation for the everything-codex-unity system.

---

## Design Philosophy

This project is a Codex-native migration of the original Unity assistant toolkit.

- **Convention over configuration** -- install the Codex plugin manifest, skills, MCP config, and legacy references into any Unity project.
- **Safety by default** -- reusable validation scripts flag destructive operations (scene file edits, meta file corruption) before they happen.
- **MCP as the bridge** -- code changes go through normal file editing; scene/editor changes go through unity-mcp tools.
- **Composable knowledge** -- skills are modular and loaded on demand, not bundled into one massive prompt.
- **Agent specialization** -- each agent has a focused role, specific model selection, and limited tool access.

---

## Component Overview

```
.codex-legacy/
  agents/            20 legacy role references
  commands/          27 legacy command references
  hooks/             27 reusable shell scripts + _lib.sh (safety, quality, session, learning)
  rules/              5 always-loaded coding standards
skills/              70 Codex skills, including 27 workflow skills
.codex-plugin/       Codex plugin manifest
.mcp.json            Unity MCP server configuration
.codex-unity/state/  Session state directory (session.json, tracking files)
```

Supporting files outside `.codex-legacy/`:

```
scripts/             Shell scripts for validation (meta, code quality, serialization, architecture)
install.sh           One-command installer
upgrade.sh           Version-aware upgrade with backup and customization preservation
uninstall.sh         Clean removal with backup option
templates/           C# templates for MVS pattern (Model, View, System, LifetimeScope, Message)
benchmarks/          Structural correctness benchmarks for agent output
```

---

## How Agents Work

Agents are Markdown files in `.codex-legacy/agents/` with YAML frontmatter that controls their behavior.

### Frontmatter Fields

| Field | Purpose | Example |
|-------|---------|---------|
| `name` | Identifier used by commands | `unity-coder` |
| `description` | One-line summary shown in agent selection | `"Implements Unity features..."` |
| `model` | Which Codex model to use | `opus`, `sonnet`, `haiku` |
| `color` | Terminal display color | `green`, `blue`, `yellow` |
| `tools` | Allowed tool access list | `Read, Write, Edit, Glob, Grep, Bash, mcp__unityMCP__*` |
| `skills` | Skills to preload | Listed in the agent body or loaded by commands |

### Model Selection

- **Opus** -- complex implementation, creative prototyping, debugging, shader writing, plan critique, verification (10 agents)
- **Sonnet** -- code review, test writing, migration, builds, git operations, security audit, and lite variants (8 agents)
- **Haiku** -- fastest and cheapest, used for read-only exploration and quick validation (2 agents: `unity-scout`, `unity-linter`)

Some commands support `--quick` (routes to sonnet-tier lite agent) and `--thorough` (routes to opus) flags. See `docs/MODEL-ROUTING.md` for the full routing table.

### Tool Access

Agents only have access to the tools listed in their frontmatter. This enforces boundaries:

- `unity-reviewer` has `Read, Glob, Grep` only -- it cannot modify files.
- `unity-scene-builder` has `Read, Glob, Grep, mcp__unityMCP__*` -- it controls the editor but does not write code.
- `unity-coder` has full access including `Write, Edit, Bash` and MCP tools.

---

## How Commands Work

Commands are Markdown files in `.codex-legacy/commands/` with `user-invocable: true` in frontmatter. Users invoke them with `/command-name` in Codex.

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

Skills are knowledge modules in `skills/`, organized into categories:

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

Codex discovers skills via glob patterns. Agents reference skills by category path, and the system loads matching `.md` files.

### Always-Apply Skills

Skills with `alwaysApply: true` in frontmatter (like `unity-mcp-patterns`) are loaded for every agent that has MCP tool access. These contain critical patterns that should never be skipped.

---

## How Legacy Hook Scripts Work

Hook scripts are preserved in `.codex-legacy/hooks/` as reusable safety and validation utilities. Codex does not automatically consume the old hook lifecycle manifest; future plugin hook integration should adapt payloads and exit semantics explicitly.

All 22 hooks source a shared library (`_lib.sh`) that provides kill switches, profile filtering, and utility functions. Hooks are organized into three **profile levels** -- `minimal` (5 hooks), `standard` (18 cumulative), and `strict` (22 cumulative). Set the active profile via `UNITY_HOOK_PROFILE=standard`.

### Event Types

| Event | When | Hook Types |
|-------|------|------------|
| PreToolUse | Before a tool executes | Blocking (exit 2) or allow (exit 0) |
| PostToolUse | After a tool executes | Advisory warnings and tracking (exit 0) |
| PreCompact | Before context compaction | State preservation (exit 0) |
| SessionStart | When a conversation begins | State restoration (exit 0) |
| Stop | When the agent stops | Validation, persistence, learning, notifications (exit 0) |

### Hook Summary

| Hook | Event | Matcher | Profile | Type |
|------|-------|---------|---------|------|
| `block-scene-edit` | PreToolUse | Edit\|Write | minimal | Blocking |
| `block-meta-edit` | PreToolUse | Edit\|Write | minimal | Blocking |
| `guard-editor-runtime` | PreToolUse | Edit\|Write | minimal | Blocking |
| `guard-project-config` | PreToolUse | Edit\|Write | standard | Blocking |
| `gateguard` | PreToolUse | Edit\|Write | strict | Blocking |
| `block-projectsettings` | PreToolUse | Bash | minimal | Blocking |
| `track-reads` | PostToolUse | Read | strict | Advisory |
| `warn-serialization` | PostToolUse | Edit\|Write | standard | Advisory |
| `warn-filename` | PostToolUse | Edit\|Write | standard | Advisory |
| `warn-platform-defines` | PostToolUse | Edit\|Write | standard | Advisory |
| `quality-gate` | PostToolUse | Edit\|Write | standard | Advisory |
| `track-edits` | PostToolUse | Edit\|Write | standard | Advisory |
| `suggest-verify` | PostToolUse | Edit\|Write | standard | Advisory |
| `validate-commit` | PostToolUse | Bash | standard | Advisory |
| `build-analyze` | PostToolUse | Bash | strict | Advisory |
| `cost-tracker` | PostToolUse | (all) | strict | Advisory |
| `pre-compact` | PreCompact | (all) | minimal | Advisory |
| `session-restore` | SessionStart | (all) | standard | Advisory |
| `stop-validate` | Stop | (all) | standard | Advisory |
| `session-save` | Stop | (all) | standard | Advisory |
| `auto-learn` | Stop | (all) | strict | Advisory |
| `notify` | Stop | (all) | standard | Advisory |

### Hook Input

Hooks receive JSON on stdin with the tool invocation details (`tool_name`, `tool_input`). They use `jq` to parse and inspect the operation.

For the full hook catalog with detailed descriptions, environment variables, and configuration, see [HOOK-REFERENCE.md](HOOK-REFERENCE.md).

---

## How Rules Work

Rules are Markdown files in `.codex-legacy/rules/` that are always loaded as context for every conversation. They define coding standards that Codex follows:

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

The unity-mcp bridge connects Codex to the Unity Editor via HTTP. It exposes tools for:

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
Command (orchestration)        <- .codex-legacy/commands/
  |
  v
Agent (specialized executor)   <- .codex-legacy/agents/
  |                  |
  v                  v
File Tools         MCP Tools
(Read/Write/Edit)  (mcp__unityMCP__*)
  |                  |
  v                  v
C# Source Files    Unity Editor
```

### Four Agent Categories

1. **Read-Only Agents** -- read and analyze only, no file modification or MCP access
   - `unity-reviewer`, `unity-scout`, `unity-linter`, `unity-security-reviewer`, `unity-critic`

2. **Code Agents** -- write/edit C# files, may run git commands, no MCP access
   - `unity-migrator`, `unity-git-master`

3. **MCP-Powered Agents** -- control Unity Editor only, no file writing
   - `unity-scene-builder`, `unity-build-runner`, `unity-test-runner`

4. **Hybrid Agents** -- both code and MCP access
   - `unity-coder`, `unity-coder-lite`, `unity-prototyper`, `unity-fixer`, `unity-fixer-lite`, `unity-optimizer`, `unity-shader-dev`, `unity-network-dev`, `unity-ui-builder`, `unity-verifier`

---

## MCP Configuration

```json
{
  "mcpServers": {
    "unityMCP": {
      "url": "http://localhost:8080/mcp"  // unity-mcp bridge endpoint
    }
  },
}
```

The file lives at `.mcp.json` in the project root. Legacy hook scripts are not registered here.

---

## File Organization

This structure follows Codex's discovery conventions:

- **skills/** -- discovered via glob patterns, loaded on demand
- **.codex-plugin/plugin.json** -- declares plugin metadata and skill/MCP paths
- **.mcp.json** -- configures Unity MCP
- **.codex-legacy/** -- reference roles, command workflows, rules, and reusable scripts
- **.codex-unity/state/** -- runtime session state (session.json, tracking files), git-ignored

Each component is a standalone Markdown file. No build step, no compilation, no registration. Drop files in the right directory and they work.

---

## Hook Kill Switch System

All hooks source a shared library (`.codex-legacy/hooks/_lib.sh`) that provides environment variable overrides:

```
DISABLE_UNITY_HOOKS=1              All hooks exit 0 immediately
DISABLE_HOOK_<NAME>=1              Specific hook exits 0 (name derived from filename, uppercased, hyphens→underscores)
UNITY_HOOK_MODE=warn               Blocking hooks (exit 2) downgraded to warnings (exit 0)
```

The `unity_hook_block()` function replaces direct `exit 2` calls in blocking hooks. It respects `UNITY_HOOK_MODE=warn`, printing the block message as a warning instead.

Configure overrides through environment variables so they do not affect the team.

---

## State Management

Session state is persisted in the `.codex-unity/state/` directory (falls back to `/tmp/unity-codex-hooks` if the directory does not exist). This enables conversation continuity across sessions and context compaction.

### session.json Schema

```json
{
  "schema_version": 1,
  "branch": "feature/player-movement",
  "workflow_phase": "Execute",
  "modified_files": ["Assets/Scripts/PlayerSystem.cs", "Assets/Scripts/PlayerModel.cs"],
  "recent_commits": ["abc1234 Add PlayerSystem with movement"],
  "session_duration": "12m 34s",
  "tool_calls": 47,
  "warnings_count": 3,
  "saved_at": "2024-01-15T14:30:22Z",
  "plan": {
    "description": "Implement player movement",
    "steps": [
      { "name": "Write PlayerModel", "status": "done" },
      { "name": "Write PlayerSystem", "status": "in-progress" }
    ]
  },
  "verification": {
    "last_iteration": 2
  },
  "agent_context": {
    "last_agent": "unity-coder"
  }
}
```

### Tracking Files

| File | Purpose | Written By |
|------|---------|------------|
| `session.json` | Full session state for restore | `session-save.sh` |
| `session-start-time` | Epoch timestamp for duration calculation | `session-restore.sh` |
| `gateguard-reads.txt` | Files read during session (for GateGuard) | `track-reads.sh` |
| `session-edits.txt` | Files edited during session | `track-edits.sh` |
| `session-cost.jsonl` | Tool call log (tool name + timestamp) | `cost-tracker.sh` |
| `learnings.jsonl` | Extracted session patterns | `auto-learn.sh` |
| `session-warnings.txt` | Hook warnings for analytics | Various hooks |
| `precompact-state.md` | Git state snapshot before compaction | `pre-compact.sh` |

### Session TTL

Sessions expire after a configurable time-to-live. Set via `UNITY_SESSION_TTL_HOURS` (default: 4 hours). The `session-restore.sh` hook checks the `saved_at` timestamp and discards stale sessions.

---

## Workflow Pipeline

The `/unity-workflow` command implements a staged pipeline inspired by modern AI coding orchestrators:

```
Clarify → Plan → Execute → Verify
```

1. **Clarify** -- interview the user about requirements, constraints, and acceptance criteria
2. **Plan** -- analyze the project, identify subsystems, choose agents, present an implementation plan
3. **Execute** -- route to appropriate agent(s) (coder, prototyper, UI builder, etc.)
4. **Verify** -- invoke the `unity-verifier` agent for an automated verify-fix loop

### Verify-Fix Loop

The `unity-verifier` agent runs a bounded loop (max 3 iterations):

```
Review changes → Classify issues → Auto-fix safe issues → Run tests → Re-verify
```

Auto-fixable issues include: missing `[FormerlySerializedAs]`, `?.` on Unity objects, uncached `GetComponent` in Update, `tag ==` instead of `CompareTag`, missing `#if UNITY_EDITOR` guards.

Issues requiring human judgment (architecture, design patterns, ambiguous trade-offs) are reported but not auto-fixed.

---

## Benchmarking

The `benchmarks/` directory contains structural correctness benchmarks for agent output. Each benchmark scenario defines a prompt, expected files, required patterns, and forbidden patterns.

Benchmarks do not invoke Codex directly. The workflow is:

1. Run Codex manually with a scenario prompt in a scratch Unity project.
2. Run `bash benchmarks/run-benchmarks.sh --workdir /path/to/output` to score the result.
3. Use `--compare` to diff against a previous run and detect regressions.

Results are written to `benchmarks/results/` as timestamped JSON files. Use benchmarks to validate that changes to agents, skills, or rules do not degrade output quality.

See [BENCHMARK-GUIDE.md](BENCHMARK-GUIDE.md) for the full reference.

---

## Version Management

The `.codex-plugin/plugin.json` `version` field tracks the installed version. The `upgrade.sh` script creates backups of replaced Codex plugin paths and regenerates `AGENTS.md.generated` for review.
