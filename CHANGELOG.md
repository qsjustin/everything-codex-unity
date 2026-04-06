# Changelog

All notable changes to everything-claude-unity will be documented in this file.

## [1.1.0] — 2026-04-06

### Added

**New Commands (2)**
- `/unity-workflow` — full development pipeline: clarify → plan → execute → verify
- `/unity-doctor` — diagnostic health check (MCP connectivity, .claude/ integrity, hook registration, project structure, skill/package alignment)

**New Agents (3)**
- `unity-verifier` — verify-fix loop agent: reviews changes, auto-fixes safe issues, re-verifies up to 3 iterations
- `unity-coder-lite` — sonnet-tier lightweight coder for simple feature additions
- `unity-fixer-lite` — sonnet-tier lightweight fixer for obvious bugs

**New Hook (1)**
- `suggest-verify` — advisory hook that suggests running `/unity-review` after 5+ C# files modified

**New Templates (5)**
- `Model.cs.template` — pure C# data class with ReactiveProperty (MVS architecture)
- `System.cs.template` — plain C# class with VContainer injection and IDisposable
- `View.cs.template` — MonoBehaviour observing Model via Subscribe, VContainer method injection
- `LifetimeScope.cs.template` — VContainer composition root with Model/System/View/MessagePipe registration
- `Message.cs.template` — readonly struct for MessagePipe (zero allocation)

**New Validation Scripts (2)**
- `validate-serialization.sh` — detects serialized field renames missing `[FormerlySerializedAs]`
- `validate-architecture.sh` — checks MVS pattern compliance (dependency direction, no singletons, no coroutines, injection patterns)

**New Lifecycle Scripts (2)**
- `upgrade.sh` — upgrade existing installation with version detection, backup, and customization preservation
- `uninstall.sh` — clean removal with backup, .gitignore cleanup, and optional settings preservation

**New Documentation (1)**
- `docs/MODEL-ROUTING.md` — guide to agent model assignments, `--quick`/`--thorough` flags, and cost/latency trade-offs

**Hook Kill Switch System**
- Shared `_lib.sh` library sourced by all hooks
- `DISABLE_UNITY_HOOKS=1` — bypass all hooks
- `UNITY_HOOK_MODE=warn` — downgrade blocking hooks to warnings
- `DISABLE_HOOK_<NAME>=1` — disable individual hooks
- Version tracking via `.claude/VERSION`

### Changed

- `/unity-feature` — added optional verification phase (Phase 4) and `--quick` routing to `unity-coder-lite`
- `/unity-fix` — added `--quick` routing to `unity-fixer-lite`
- `/unity-review` — added `--thorough` routing to opus model
- `/unity-prototype` — added optional verification phase (Step 6)
- `block-meta-edit.sh` — uncommented and activated (was disabled in v1.0.0)
- All 8 hooks now source `_lib.sh` for kill switch support
- `settings.local.json.template` — added kill switch environment variable documentation
- `settings.json` — registered `suggest-verify.sh` hook

---

## [1.0.0] — 2026-04-01

### Added

**Agents (12)**
- `unity-coder` — general feature implementation with Unity subsystem awareness
- `unity-fixer` — bug diagnosis with Unity-specific patterns
- `unity-reviewer` — code review with serialization, performance, and architecture checks
- `unity-shader-dev` — HLSL/ShaderGraph development with live MCP testing
- `unity-scene-builder` — scene construction entirely via MCP
- `unity-test-runner` — test writing and execution via MCP
- `unity-build-runner` — build configuration and execution via MCP
- `unity-optimizer` — profiling and performance optimization via MCP
- `unity-prototyper` — rapid end-to-end prototyping (code + scene + physics + camera)
- `unity-ui-builder` — UI screen building with code and visual setup
- `unity-network-dev` — multiplayer implementation (Netcode/Mirror/Photon/Fish-Net)
- `unity-migrator` — Unity version and render pipeline migration

**Commands (15)**
- `/unity-init` — project setup and CLAUDE.md generation
- `/unity-feature` — plan and implement features
- `/unity-fix` — diagnose and fix bugs
- `/unity-prototype` — one prompt to playable prototype
- `/unity-review` — full Unity-aware code review
- `/unity-test` — write and run tests via MCP
- `/unity-build` — configure and trigger builds
- `/unity-scene` — build scenes via MCP
- `/unity-shader` — create shaders with live preview
- `/unity-ui` — build UI screens
- `/unity-network` — set up multiplayer
- `/unity-optimize` — profile and fix performance
- `/unity-audit` — full project health check
- `/unity-profile` — deep profiling session
- `/unity-migrate` — version and pipeline migration

**Skills (35)**
- 6 core (always-on): serialization-safety, scriptable-objects, event-systems, object-pooling, assembly-definitions, unity-mcp-patterns
- 11 systems: urp-pipeline, input-system, addressables, cinemachine, animation, audio, physics, navmesh, ui-toolkit, shader-graph, vfx-graph
- 6 gameplay: character-controller, inventory-system, dialogue-system, save-system, state-machine, procedural-generation
- 4 genre: fps, rpg, platformer-2d, topdown
- 5 third-party: dotween, unitask, vcontainer, textmeshpro, odin-inspector
- 3 platform: mobile, webgl, console

**Hooks (8)**
- 4 blocking: block-scene-edit, block-meta-edit, block-projectsettings, guard-editor-runtime
- 4 warning: warn-serialization, warn-filename, warn-platform-defines, validate-commit

**Rules (5)**
- csharp-unity, performance, serialization, architecture, unity-specifics

**Scripts (6)**
- generate-claude-md, validate-meta-integrity, validate-code-quality, validate-asmdefs, detect-missing-refs, analyze-build-size

**Templates (5)**
- MonoBehaviour, ScriptableObject, EditModeTest, PlayModeTest, AssemblyDefinition

**Examples (5)**
- CLAUDE.md templates for: 2D platformer, FPS, RPG, mobile casual, VR experience

**Infrastructure**
- One-command installer (`install.sh`)
- Unity MCP integration (CoplayDev/unity-mcp)
- Settings.json with full hook + MCP configuration
- Comprehensive documentation (Getting Started, Architecture, Agent Guide, MCP Setup)
