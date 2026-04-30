---
name: unity-project-rules
description: Unity project-wide coding rules migrated for Codex. Use for Unity C# architecture, serialization safety, performance, Editor/runtime boundaries, prefab/scene safety, and mobile game implementation.
---

# Unity Project Rules

Use this skill whenever changing or reviewing Unity project code.

## Core Rules

- Read the relevant rule files under `.codex-legacy/rules/` when a task touches that area:
  - `csharp-unity.md` for C# style and Unity idioms.
  - `serialization.md` for `[SerializeField]`, `[FormerlySerializedAs]`, `SerializeReference`, and data-loss prevention.
  - `performance.md` for allocations, Update loops, pooling, physics, mobile budgets, and profiling.
  - `architecture.md` for MVS, VContainer, MessagePipe, ScriptableObjects, and assembly boundaries.
  - `unity-specifics.md` for scenes, prefabs, editor/runtime guards, coroutines, threading, and platform rules.
- Never text-edit `.unity`, `.prefab`, `.asset`, or `.meta` files unless the user explicitly asks and the change is intentionally YAML-level.
- Prefer Unity MCP or Unity Editor workflows for scene, prefab, and asset operations.
- Treat serialized field renames as data migrations: keep `[FormerlySerializedAs]` permanently.
- Use `obj == null` / `obj != null` for `UnityEngine.Object` references.
- Cache component lookups outside hot paths.

## Codex Migration Notes

- Legacy legacy agents and commands are preserved under `.codex-legacy/` as reference material.
- Codex does not register legacy custom agents or slash commands directly; use the workflow skills under `skills/workflows/` instead.
- Hook scripts are preserved as reusable shell scripts, but their legacy lifecycle payload semantics are not assumed to apply automatically in Codex.
