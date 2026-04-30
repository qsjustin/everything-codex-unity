# Skill Catalog

One-page reference for Codex skills in everything-codex-unity.

---

## Overview

This repository currently ships 70 Codex skills: 42 non-workflow skills
(including `unity-project-rules`) and 27 workflow skills. The project-wide
Unity rules entry point lives at `skills/unity-project-rules/SKILL.md`.

Codex discovers skills from each `SKILL.md` frontmatter. The only trigger metadata Codex relies on here is:

```yaml
---
name: skill-name
description: Clear trigger description for when Codex should use this skill.
---
```

Do not depend on Claude-only skill fields such as `alwaysApply` or `globs`.

---

## Core Skills

| Skill | Purpose |
|-------|---------|
| `assembly-definitions` | Assembly definition management, reference rules, Editor/Runtime/Test separation |
| `commit-trailers` | Structured commit trailers with architectural decision metadata |
| `deep-interview` | Ambiguity gating and structured requirements gathering |
| `event-systems` | C# events, UnityEvent, ScriptableObject event channels, static EventBus |
| `hud-statusline` | Workflow statusline state and session metrics |
| `learner` | Post-debugging knowledge extraction |
| `model-routing` | Heuristics for choosing model/effort by task complexity |
| `object-pooling` | Unity `ObjectPool<T>`, component pools, warm-up and return lifecycle |
| `scriptable-objects` | ScriptableObject architecture patterns |
| `serialization-safety` | FormerlySerializedAs, Unity null checks, SerializeReference, data-loss prevention |
| `unity-instincts` | Project-local instinct learning system |
| `unity-mcp-patterns` | Unity MCP usage patterns such as batching and console checks |

---

## Domain Skills

Gameplay:
`character-controller`, `dialogue-system`, `inventory-system`, `procedural-generation`, `save-system`, `state-machine`.

Genres:
`endless-runner`, `hyper-casual`, `idle-clicker`, `match3`, `platformer-2d`, `puzzle`, `rpg`, `topdown`.

Platform:
`mobile`.

Unity systems:
`addressables`, `animation`, `audio`, `cinemachine`, `input-system`, `navmesh`, `physics`, `shader-graph`, `ui-toolkit`, `urp-pipeline`.

Third-party:
`dotween`, `odin-inspector`, `textmeshpro`, `unitask`, `vcontainer`.

Project rules:
`unity-project-rules`.

---

## Workflow Skills

Workflow skills replace the former slash-command docs as Codex-triggerable skills:

`unity-audit`, `unity-build`, `unity-doctor`, `unity-feature`, `unity-fix`, `unity-init`, `unity-instincts-workflow`, `unity-interview`, `unity-learn`, `unity-migrate`, `unity-network`, `unity-optimize`, `unity-profile`, `unity-prototype`, `unity-ralph`, `unity-review`, `unity-scene`, `unity-session-resume`, `unity-session-save`, `unity-sessions`, `unity-shader`, `unity-skill-stocktake`, `unity-skillify`, `unity-team`, `unity-test`, `unity-ui`, `unity-workflow`.

---

## Creating a New Skill

Create a new directory and `SKILL.md` file:

```text
skills/<category>/<skill-name>/SKILL.md
```

Use Codex frontmatter only:

```yaml
---
name: skill-name
description: Specific trigger description for when Codex should use this skill.
---
```

The Markdown body contains the skill's workflow, reference guidance, examples, rules, and anti-patterns. Keep the frontmatter concise; put detailed matching guidance in the description or body rather than adding unsupported metadata.
