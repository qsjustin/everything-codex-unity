---
name: unity-doctor
description: "Diagnostic health check — verifies Codex plugin files, MCP connectivity, migrated skills, legacy reference material, and Unity project structure."
---

# /unity-doctor — Diagnostic Health Check

Run a comprehensive diagnostic check on the everything-codex-unity installation and the Unity project. Report each check as **PASS**, **WARNING**, or **ERROR** with actionable fixes.

## Check 1: Unity MCP Server Connectivity

1. Attempt to call `project_info` via MCP to get Unity version and project state.
2. If it succeeds: report Unity version, platform, and play mode state → **PASS**
3. If it fails: report the error → **ERROR** with suggestions:
   - Is the unity-mcp package installed in Unity?
   - Is the Unity Editor running and the project open?
   - Is the MCP server running on the expected port?
   - Check `.mcp.json` → `mcpServers.unityMCP.url`

## Check 2: Codex Plugin Integrity

1. Verify `.codex-plugin/plugin.json` exists and is valid JSON.
2. Verify the manifest `skills` path exists and points to `skills/`.
3. Verify `.mcp.json` exists and is valid JSON.
4. Verify `skills/**/SKILL.md` files have Codex frontmatter with `name` and `description`.
5. Verify skill names are unique.
6. Report counts: X Codex skills, Y workflow skills.
7. Any missing required path or duplicate skill name → **ERROR**; invalid frontmatter → **WARNING**; all good → **PASS**.

## Check 3: Legacy Reference Integrity

1. Verify `.codex-legacy/agents`, `.codex-legacy/commands`, `.codex-legacy/hooks`, and `.codex-legacy/rules` exist.
2. For each hook in `.codex-legacy/hooks/`: check the file exists and is executable (`-x` permission).
3. Report counts: X legacy commands, Y legacy agents, Z hook scripts, V rules.
4. Do not expect Codex to auto-register these legacy agents, commands, or hooks. They are reference material and reusable scripts.
5. Missing legacy directories → **WARNING** unless the current task needs them; non-executable hook scripts → **WARNING**.

## Check 4: Unity Project Structure

1. Check for `Assets/` directory → **ERROR** if missing
2. Check for `ProjectSettings/` directory → **ERROR** if missing
3. Check for `Packages/manifest.json` → **WARNING** if missing
4. Check for `AGENTS.md` in project root → **WARNING** if missing, suggest `/unity-init`
5. Search for `.asmdef` files in `Assets/` → **WARNING** if none found
6. Search for test assembly definitions (`*Tests*.asmdef`) → **WARNING** if none, suggest `/unity-test`
7. All present → **PASS**

## Check 5: Skill/Package Alignment

1. Read `Packages/manifest.json` to detect installed Unity packages
2. Cross-reference with available skills in `skills/`:

| Package | Expected Skill |
|---------|---------------|
| `com.unity.inputsystem` | `systems/input-system` |
| `com.unity.addressables` | `systems/addressables` |
| `com.unity.cinemachine` | `systems/cinemachine` |
| `com.unity.render-pipelines.universal` | `systems/urp-pipeline` |
| `com.unity.textmeshpro` | `third-party/textmeshpro` |
| `com.unity.timeline` | — (no skill yet) |

3. Also check for third-party packages in `Assets/`:
   - `DOTween` → `third-party/dotween`
   - `UniTask` → `third-party/unitask`
   - `VContainer` → `third-party/vcontainer`
   - `Odin` → `third-party/odin-inspector`

4. Report packages without matching skills → **WARNING** (capability gap)
5. All aligned → **PASS**

## Output Format

Present a summary report:

```
=== Unity Doctor Report ===

MCP Server:        PASS  (Unity 2022.3.20f1, StandaloneWindows64)
Codex Plugin:        PASS  (70 skills, 27 workflows)
Legacy References:   PASS  (27 commands, 20 agents, 27 hooks, 5 rules)
Project Structure:  WARNING — no test assembly definitions found
Skill Alignment:    WARNING — DOTween detected but no matching skill loaded

Overall: 2 warnings, 0 errors
```

For each WARNING or ERROR, include the actionable fix immediately after the line.
