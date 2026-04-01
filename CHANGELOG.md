# Changelog

All notable changes to everything-claude-unity will be documented in this file.

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
