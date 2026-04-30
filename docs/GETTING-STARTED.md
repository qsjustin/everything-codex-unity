# Getting Started

A step-by-step guide to setting up everything-codex-unity in your Unity project.

---

## Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| **Codex** | Latest | [Install guide](https://openai.com/codex) |
| **Unity** | 2021.3 LTS+ | Any render pipeline (Built-in, URP, HDRP) |
| **Python** | 3.10+ | Only needed for unity-mcp integration |
| **uv** | Latest | Python package manager, only needed for unity-mcp |

Codex is the only hard requirement. Python and uv are only needed if you want the MCP bridge for direct Unity Editor control.

---

## Installation

### Option A: One-Command Install (Recommended)

From your Unity project root:

```bash
git clone https://github.com/<user>/everything-codex-unity.git /tmp/ecu
/tmp/ecu/install.sh --project-dir .
rm -rf /tmp/ecu
```

The installer copies the `.codex-legacy/` directory into your project and validates the structure.

### Option B: Manual Copy

```bash
git clone https://github.com/<user>/everything-codex-unity.git
cp -r everything-codex-unity/.codex-plugin everything-codex-unity/skills everything-codex-unity/.mcp.json everything-codex-unity/.codex-legacy your-unity-project/
```

Make sure the hooks are executable:

```bash
chmod +x your-unity-project/.codex-legacy/hooks/*.sh
```

---

## First Run

1. Open a terminal in your Unity project root (the folder containing `Assets/`).
2. Run `codex` to start Codex.
3. Try your first command:

```
/unity-audit
```

This runs a full project health check: meta file integrity, missing references, assembly definition graph, and code quality scan. It is a safe, read-only operation and a good way to verify everything is working.

---

## Understanding the .codex-legacy/ Directory

After installation, your project contains:

```
.codex-plugin/
  plugin.json       Codex plugin manifest
skills/             Codex-discoverable skills and workflows
.mcp.json           Unity MCP server configuration
.codex-legacy/
  agents/          Legacy role references
  commands/        Legacy command references
  hooks/           Reusable hook scripts + _lib.sh
  rules/           Unity coding standards referenced by skills
.codex-unity/
  state/           Runtime session state
  scripts/         Validation scripts
  templates/       C# templates
```

---

## Configuring AGENTS.md for Your Project

Run `/unity-init` to auto-generate a `AGENTS.md` tailored to your project. It scans:

- Unity version and active platform
- Installed packages (render pipeline, Input System, Addressables, etc.)
- Networking stack (Netcode, Mirror, Photon, Fish-Net)
- Third-party packages (DOTween, UniTask, VContainer, Zenject, Odin)
- Assembly definition structure

You can then customize the generated `AGENTS.md` to add:

- Project-specific conventions (naming, folder structure)
- Which skills to always load
- Which features are in active development
- Any team-specific rules or constraints

---

## Setting Up unity-mcp (Optional but Recommended)

The MCP bridge gives Codex direct control over the Unity Editor: creating GameObjects, building scenes, running tests, profiling performance.

1. In Unity: **Window > Package Manager > Add package from git URL**
   ```
   https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main
   ```

2. In Unity: **Window > MCP for Unity > Start Server**

3. Verify the server is running on `localhost:8080`

4. The `.mcp.json` file is already configured to connect:
   ```json
   "mcpServers": {
     "unityMCP": {
       "url": "http://localhost:8080/mcp"
     }
   }
   ```

5. Start Codex and test the connection by asking Codex to list objects in the scene.

See [MCP-SETUP.md](MCP-SETUP.md) for detailed setup and troubleshooting.

---

## Common First Commands

| Command | What It Does |
|---------|-------------|
| `/unity-doctor` | Diagnostic health check — verify MCP, hooks, project structure are all working |
| `/unity-init` | Scans your project and generates a tailored AGENTS.md |
| `/unity-audit` | Full project health check (meta files, missing refs, code quality) |
| `/unity-review` | Reviews your C# code for Unity-specific issues |
| `/unity-prototype "description"` | Creates a playable prototype from a text description |
| `/unity-workflow "description"` | Full pipeline: clarify requirements → plan → execute → verify |
| `/unity-fix` | Diagnoses and fixes bugs using console errors |
| `/unity-scene "description"` | Builds a scene from a natural language description |
| `/unity-build` | Configures and triggers a build |
| `/unity-test` | Writes and runs EditMode/PlayMode tests |

Start with `/unity-init`, then `/unity-audit` to get a baseline. From there, try `/unity-review` on existing code or `/unity-prototype` to see the full pipeline in action.

---

## Troubleshooting

### Quick Diagnostic

Run `/unity-doctor` as a first troubleshooting step. It checks MCP connectivity, Codex plugin integrity, legacy reference files, project structure, and skill/package alignment — and provides actionable fixes for any issues found.

### Legacy Hook Scripts

- Verify hooks are executable: `ls -la .codex-legacy/hooks/*.sh`
- If not: `chmod +x .codex-legacy/hooks/*.sh`
- Codex does not auto-register the legacy Claude hook lifecycle; these scripts are preserved for manual validation, tests, or future hook integration.
- Hooks require `jq` installed on your system for JSON parsing
- To temporarily disable hooks: set `DISABLE_UNITY_HOOKS=1` in your environment
- To downgrade blocking hooks to warnings: set `UNITY_HOOK_MODE=warn`

### MCP Not Connecting

- Confirm the server is running: check Unity's MCP for Unity window
- Verify `localhost:8080` is reachable: `curl http://localhost:8080/mcp`
- Check for port conflicts: another service on 8080
- Ensure `.mcp.json` has the correct `mcpServers` block
- See [MCP-SETUP.md](MCP-SETUP.md) for detailed troubleshooting

### Permission Issues

- On macOS/Linux, hooks need execute permission: `chmod +x .codex-legacy/hooks/*.sh`
- The `install.sh` script handles this automatically

### Workflow Skills Not Triggering

- Workflow skills must be under `skills/**/SKILL.md`.
- They need valid Codex frontmatter with `name` and `description`.
- The `description` should clearly say when Codex should use the workflow.
- Restart Codex after adding or renaming skills.

### Codex Does Not Know About Unity

- Run `/unity-init` to generate the project-specific AGENTS.md
- Verify that `skills/unity-project-rules/SKILL.md` exists and references `.codex-legacy/rules/`.
- Skills are loaded by Codex as needed; they do not need manual activation.
