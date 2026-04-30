# Legacy Role Guide

This repository keeps the original role and command documents under `.codex-legacy/` as reference material. They are useful for understanding the intended Unity workflows, but they are not Codex plugin registration surfaces.

---

## What Codex Registers

Codex-facing behavior lives in:

- `.codex-plugin/plugin.json` for plugin metadata.
- `skills/**/SKILL.md` for triggerable skills and workflows.
- `.mcp.json` for Unity MCP configuration.

Codex skills use this frontmatter:

```yaml
---
name: skill-name
description: Clear trigger description for when Codex should use this skill.
---
```

Do not add Claude-only fields such as `model`, `tools`, `user-invocable`, `alwaysApply`, or `globs` to Codex skill frontmatter.

---

## What `.codex-legacy/agents` Contains

Files under `.codex-legacy/agents/` are preserved role references from the original Claude-oriented toolkit. They describe useful role boundaries such as coder, reviewer, verifier, scene builder, and build runner.

Use them as prose guidance when improving workflow skills. Do not expect Codex to auto-register them as custom agents.

---

## What `.codex-legacy/commands` Contains

Files under `.codex-legacy/commands/` are the original slash-command workflow documents. Their Codex-facing replacements live under `skills/workflows/`.

When adding a new workflow, create a Codex skill instead:

```text
skills/workflows/<workflow-name>/SKILL.md
```

```yaml
---
name: unity-localize
description: Use when setting up Unity localization, string tables, locale switching, RTL support, or localized assets.
---
```

The skill body should describe the workflow, any legacy role references to consult, validation steps, and expected final summary.

---

## Migration Rule

If a legacy agent or command contains useful instructions, migrate the instructions into a Codex skill body or a reference file loaded by that skill. Keep the Codex skill frontmatter limited to `name` and `description`.
