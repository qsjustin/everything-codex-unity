# everything-claude-unity

**The ultimate Claude Code plugin for Unity mobile game development.**

A production-ready, plug-and-play automation system that gives Claude Code deep Unity expertise for mobile games — from writing performant C# to building scenes, profiling performance, and triggering iOS/Android builds — all through natural language.

Built for **solo indie mobile game developers**. Follows the proven architecture of [everything-claude-code](https://github.com/affaan-m/everything-claude-code) (122k+ stars).

---

## What You Get

| Component | Count | Purpose |
|-----------|-------|---------|
| **Agents** | 12 | Specialized sub-agents for coding, scene building, profiling, testing, building |
| **Commands** | 15 | Slash commands like `/unity-prototype`, `/unity-review`, `/unity-build` |
| **Skills** | 34 | Knowledge modules for Unity systems, gameplay patterns, and mobile genres |
| **Hooks** | 8 | Safety net — blocks scene/meta corruption, warns on serialization mistakes |
| **Rules** | 5 | C# coding standards, performance rules, architecture patterns |
| **Scripts** | 6 | Validation tools for meta files, code quality, assembly definitions |

### The Killer Feature: `/unity-prototype`

One prompt to playable prototype. Describe a mechanic, and Claude:
1. Writes the C# scripts (player controller, physics, game logic)
2. Builds the scene via MCP (GameObjects, colliders, lighting)
3. Sets up physics layers and collision matrix
4. Configures the camera (Cinemachine follow)
5. Runs tests to verify it works

```
/unity-prototype "2D platformer with wall jumping and dash"
```

---

## Quick Start

### Prerequisites
- [Claude Code](https://claude.ai/claude-code) installed
- Unity 2021.3 LTS or later
- [unity-mcp](https://github.com/CoplayDev/unity-mcp) (optional but recommended for full pipeline)

### Install

```bash
# From your Unity project root:
git clone https://github.com/<user>/everything-claude-unity.git /tmp/ecu
/tmp/ecu/install.sh --project-dir .
rm -rf /tmp/ecu
```

Or manually:
```bash
# Clone and copy .claude/ into your project
git clone https://github.com/<user>/everything-claude-unity.git
cp -r everything-claude-unity/.claude your-unity-project/.claude
```

### Setup Unity MCP (Recommended)

The unity-mcp server gives Claude direct control over the Unity Editor — scene building, profiling, builds, and more.

1. In Unity: `Window > Package Manager > + > Add package from git URL`
2. Paste: `https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main`
3. Open `Window > MCP for Unity` and click **Start Server**
4. Claude Code auto-connects via the config in `.claude/settings.json`

### First Run

```bash
cd your-unity-project
claude

# Try these:
/unity-audit          # Full project health check
/unity-review         # Code review with Unity-specific checks
/unity-prototype      # Rapid prototype a game mechanic
```

---

## Agents

### Code Agents
| Agent | What It Does |
|-------|-------------|
| `unity-coder` | Implements features with Unity subsystem awareness, auto-loads relevant skills |
| `unity-fixer` | Diagnoses bugs using Unity-specific patterns (missing refs, execution order, coroutine lifecycle) |
| `unity-reviewer` | Code review checking serialization safety, GC in hot paths, lifecycle ordering |
| `unity-shader-dev` | HLSL/ShaderGraph development optimized for mobile GPUs, live testing via MCP |

### MCP-Powered Agents
| Agent | What It Does | Key MCP Tools |
|-------|-------------|---------------|
| `unity-scene-builder` | Builds scenes from descriptions | `manage_scene`, `manage_gameobject`, `batch_execute` |
| `unity-test-runner` | Writes + runs tests, reports results | `run_tests`, `read_console` |
| `unity-build-runner` | Configures and triggers builds | `manage_build`, `manage_packages` |
| `unity-optimizer` | Profiles and fixes performance issues | `manage_profiler`, `manage_graphics` |

### Hybrid Agents
| Agent | What It Does |
|-------|-------------|
| `unity-prototyper` | End-to-end prototyping: writes code + builds scene + sets up physics + camera |
| `unity-ui-builder` | Builds UI screens with code + visual setup via MCP |
| `unity-network-dev` | Implements multiplayer with Netcode/Mirror/Photon |
| `unity-migrator` | Unity version and render pipeline migration |

---

## Commands

### Daily Workflow
```
/unity-feature <description>    Plan + implement a feature
/unity-fix <bug or error>       Diagnose and fix a bug
/unity-prototype <mechanic>     One prompt to playable prototype
/unity-scene <description>      Build a scene via MCP
/unity-shader <description>     Create shaders with live preview
/unity-ui <screen description>  Build UI with visual setup
/unity-network <framework>      Set up multiplayer
```

### Quality Gates
```
/unity-review                   Full code review (serialization, perf, architecture)
/unity-optimize                 Profile via MCP + fix bottlenecks
/unity-test                     Write + run tests via MCP
/unity-audit                    Full project health check
/unity-profile                  Deep profiling session
```

### Project Lifecycle
```
/unity-init                     Scan project + generate CLAUDE.md
/unity-build                    Configure + trigger builds
/unity-migrate                  Plan version/pipeline migration
```

---

## Safety Hooks

These hooks prevent the most common AI mistakes in Unity projects:

### Blocking (prevents the action)
| Hook | What It Prevents |
|------|-----------------|
| `block-scene-edit` | Direct text editing of .unity/.prefab YAML (corrupts references) |
| `block-meta-edit` | Editing .meta files (breaks asset GUIDs) |
| `block-projectsettings` | Staging ProjectSettings/ via git (use MCP instead) |
| `guard-editor-runtime` | `UnityEditor` namespace in runtime code without `#if UNITY_EDITOR` |

### Warning (alerts but allows)
| Hook | What It Catches |
|------|----------------|
| `warn-serialization` | Field renamed without `[FormerlySerializedAs]` (silent data loss) |
| `warn-filename` | C# file name doesn't match class name (script won't attach) |
| `warn-platform-defines` | `#if UNITY_ANDROID` without `#else` fallback |
| `validate-commit` | Missing .meta files, code quality issues on commit |

---

## Skills

### Always-On Core (6)
- **serialization-safety** — `[FormerlySerializedAs]`, `[SerializeField]`, Unity null checks
- **scriptable-objects** — SO event channels, variable refs, runtime sets, factory pattern
- **event-systems** — C# events, UnityEvent, SO channels, zero-alloc EventBus
- **object-pooling** — `ObjectPool<T>`, warm-up, return-to-pool lifecycle
- **assembly-definitions** — When to split, reference rules, Editor/Runtime separation
- **unity-mcp-patterns** — How to use MCP tools effectively (`batch_execute`, `read_console`)

### Unity Systems (10)
URP pipeline, Input System, Addressables, Cinemachine, Animation, Audio, Physics, NavMesh, UI Toolkit, ShaderGraph

### Gameplay Patterns (6)
Character controller (2D/3D), inventory system, dialogue system, save system, state machine, procedural generation

### Genre Blueprints (7) — Mobile-Focused
Hyper-casual, Match-3, Idle/Clicker, Endless Runner, Puzzle, RPG, 2D Platformer, Top-down

### Third-Party (5)
DOTween, UniTask, VContainer, TextMeshPro, Odin Inspector

### Platform (1)
Mobile optimization (iOS + Android) — touch input, safe areas, ASTC textures, thermal throttling, battery management

---

## Coding Rules

The plugin enforces Unity best practices through 5 rules files:

- **csharp-unity** — `[SerializeField] private`, explicit types, sealed by default
- **performance** — Zero-alloc Update, cache GetComponent, pool objects, no LINQ in gameplay
- **serialization** — `[FormerlySerializedAs]` on renames, `obj == null` not `obj?.`
- **architecture** — Composition over inheritance, SO for data, events for communication
- **unity-specifics** — Editor/Runtime separation, threading, coroutine lifecycle, `?.` danger

---

## Validation Scripts

Run these to check project health:

```bash
# Check .meta file integrity (missing, orphaned, duplicate GUIDs)
./scripts/validate-meta-integrity.sh --all

# Scan C# code for performance issues
./scripts/validate-code-quality.sh

# Check assembly definition graph for circular dependencies
./scripts/validate-asmdefs.sh

# Find broken references in scenes/prefabs
./scripts/detect-missing-refs.sh

# Analyze build size from Editor.log
./scripts/analyze-build-size.sh

# Auto-generate CLAUDE.md from project scan
./scripts/generate-claude-md.sh > CLAUDE.md
```

---

## Example CLAUDE.md Files

Pre-built configurations for mobile game types:

- `examples/CLAUDE.md.hyper-casual` — One-tap controls, minimal visuals, ad monetization
- `examples/CLAUDE.md.match3` — Grid system, cascades, special tiles, lives/energy
- `examples/CLAUDE.md.idle-clicker` — Big numbers, offline progress, prestige system
- `examples/CLAUDE.md.mobile-casual` — Touch input, small build, ad integration
- `examples/CLAUDE.md.2d-platformer` — Tilemap, virtual joystick, mobile-optimized
- `examples/CLAUDE.md.rpg` — Stats, inventory, dialogue, touch controls

---

## Architecture

```
User prompt
    │
    ▼
Command (orchestrates the workflow)
    │
    ├──▶ Code Agent (writes C# scripts, loads relevant skills)
    │       │
    │       └──▶ MCP Tools (creates GameObjects, configures components)
    │
    ├──▶ Test Agent (writes + runs tests via MCP)
    │
    └──▶ Optimizer Agent (profiles via MCP, fixes bottlenecks)
```

Hooks run on every tool use, providing a safety net:
```
Claude attempts to edit PlayerController.cs
    │
    ├──▶ PreToolUse: guard-editor-runtime.sh checks for UnityEditor usage
    │
    ├──▶ [Edit happens]
    │
    └──▶ PostToolUse: warn-serialization.sh checks for field renames
                       warn-filename.sh checks file/class name match
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Key areas where contributions are welcome:
- New mobile genre skills (tower defense, racing, card/gacha, simulation)
- New system skills (ProBuilder, Spline, 2D Animation)
- Mobile platform skills (ARKit/ARCore, notifications, deep links)
- Networking framework skills for mobile (FishNet, Dark Rift)
- Bug reports and hook improvements

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

Built with Claude Code. Inspired by [everything-claude-code](https://github.com/affaan-m/everything-claude-code).
