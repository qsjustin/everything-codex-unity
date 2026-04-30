# Everything Codex Unity

This repository is the Codex migration of `everything-claude-unity`.

## Codex Plugin

- Plugin manifest: `.codex-plugin/plugin.json`
- Skills: `skills/**/SKILL.md`
- Unity MCP config: `.mcp.json`
- Legacy reference material: `.codex-legacy/`

## How Codex Should Work In Unity Projects

- Use `skills/unity-project-rules/SKILL.md` for project-wide Unity rules.
- Use the specific system/gameplay/genre skill when a task matches it.
- Use workflow skills under `skills/workflows/` for former slash-command flows such as `unity-workflow`, `unity-review`, `unity-test`, `unity-build`, and `unity-prototype`.
- Prefer Unity MCP for scene, prefab, asset, console, playmode, profiling, and build operations when available.
- Do not text-edit `.unity`, `.prefab`, `.asset`, or `.meta` files unless the user explicitly requests a YAML-level edit.

## High-Risk Unity Rules

- Add `[FormerlySerializedAs]` for any serialized field rename.
- Use `[SerializeField] private` plus read-only public accessors instead of public mutable fields.
- Use `obj == null`, not `obj is null`, `?.`, or `??` on `UnityEngine.Object` references.
- Keep Editor-only APIs inside `Editor/` folders or `#if UNITY_EDITOR`.
- Cache `GetComponent`, `Camera.main`, and allocations outside hot paths.
