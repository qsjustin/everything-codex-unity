# Unity MCP Setup

How to install, configure, and troubleshoot the unity-mcp bridge between Claude Code and the Unity Editor.

---

## What Is unity-mcp?

unity-mcp is a Model Context Protocol server that runs inside Unity and exposes Editor functionality as tools. It lets Claude Code:

- Create and modify GameObjects, components, and prefabs
- Build and organize scenes
- Read console logs and errors
- Run EditMode and PlayMode tests
- Profile performance (frame timing, memory, rendering stats)
- Trigger builds and switch platforms
- Query project state (packages, assets, settings)

Without unity-mcp, Claude Code can still write C# scripts, run hooks, apply rules, and use all code-focused agents. MCP adds direct Unity Editor control on top of that.

---

## Prerequisites

| Requirement | Version | How to Check |
|-------------|---------|-------------|
| Unity | 2021.3 LTS+ | Unity Hub or `Help > About Unity` |
| Python | 3.10+ | `python3 --version` |
| uv | Latest | `uv --version` (install: `curl -LsSf https://astral.sh/uv/install.sh \| sh`) |

---

## Installation

### Step 1: Install the Unity Package

In the Unity Editor:

1. Open **Window > Package Manager**
2. Click the **+** button in the top-left corner
3. Select **Add package from git URL...**
4. Paste this URL:
   ```
   https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main
   ```
5. Click **Add** and wait for import to complete

### Step 2: Start the MCP Server

1. In Unity, go to **Window > MCP for Unity**
2. Click **Start Server**
3. The server starts on `localhost:8080` by default
4. The window shows a green status indicator when the server is running

### Step 3: Verify the Server

Open a browser or terminal and check:

```bash
curl http://localhost:8080/mcp
```

You should get a JSON response confirming the MCP endpoint is active.

### Step 4: Confirm settings.json

The `settings.json` in your `.claude/` directory is already configured:

```json
{
  "mcpServers": {
    "unityMCP": {
      "url": "http://localhost:8080/mcp"
    }
  }
}
```

No changes needed unless you are using a custom port.

---

## Verifying the Connection

Start Claude Code in your Unity project directory and try:

```
Ask Claude: "What objects are in the current scene?"
```

If MCP is working, Claude will use `manage_scene` to query the active scene and list its contents. If MCP is not connected, Claude will tell you the tool is unavailable.

You can also ask Claude to create a test object:

```
"Create an empty GameObject called MCPTest in the scene, then delete it."
```

---

## Available Tools

Unity MCP exposes tools organized by category:

### Scene Management
- `manage_scene` -- create, load, save, list scenes
- `manage_gameobject` -- create, find, modify, delete GameObjects
- `manage_components` -- add, remove, configure components on GameObjects
- `manage_prefabs` -- create, edit, instantiate prefabs

### Physics and Collision
- `manage_physics` -- physics layers, collision matrix, rigidbody settings
- Raycasting and overlap queries

### Graphics and Rendering
- `manage_material` -- create/edit materials, set shader properties
- `manage_lighting` -- configure lights, lightmaps, environment lighting
- Rendering stats and GPU profiling

### Asset Management
- `manage_asset` -- import, find, move assets
- `manage_scriptable_object` -- create/edit ScriptableObjects
- Resource and Addressable queries

### Profiling
- Frame timing and CPU/GPU breakdown
- Memory snapshots and allocation tracking
- Rendering stats (draw calls, triangles, batches)

### Build
- Platform switching
- Player settings configuration
- Build triggers and progress monitoring

### Testing
- `run_tests` -- execute EditMode/PlayMode tests
- Test results and failure details

### Project State
- `project_info` -- Unity version, platform, packages
- `read_console` -- read Editor console logs and errors
- `set_active_instance` -- target a specific Unity instance (multi-instance setups)

---

## The batch_execute Pattern

Individual MCP calls have HTTP overhead. When you need to perform multiple operations, `batch_execute` bundles them into a single request.

### Why It Matters

Creating a simple scene (10 GameObjects, 20 components) would require 30+ individual MCP calls. With `batch_execute`, that becomes 1-3 calls with 10x-100x better performance.

### How It Works

```json
{
  "tool": "batch_execute",
  "params": {
    "operations": [
      { "tool": "manage_gameobject", "params": { "action": "create", "name": "Player" } },
      { "tool": "manage_components", "params": { "action": "add", "gameobject": "Player", "component": "Rigidbody" } },
      { "tool": "manage_components", "params": { "action": "add", "gameobject": "Player", "component": "CapsuleCollider" } },
      { "tool": "manage_gameobject", "params": { "action": "create", "name": "Ground" } },
      { "tool": "manage_components", "params": { "action": "add", "gameobject": "Ground", "component": "BoxCollider" } }
    ]
  }
}
```

The `unity-mcp-patterns` skill (always loaded for MCP agents) teaches Claude to use `batch_execute` by default. You should not need to ask for it explicitly.

---

## Troubleshooting

### Server Will Not Start

**Check Python installation:**
```bash
python3 --version   # Must be 3.10+
uv --version        # Must be installed
```

**Check for port conflicts:**
```bash
lsof -i :8080       # See what is using port 8080
```

If port 8080 is taken, configure a different port in the MCP for Unity window and update `settings.json`:
```json
"url": "http://localhost:YOUR_PORT/mcp"
```

**Reinstall the package:** Remove the MCP for Unity package from Package Manager and re-add it.

### Claude Cannot Connect

**Verify settings.json:**
```json
"mcpServers": {
  "unityMCP": {
    "url": "http://localhost:8080/mcp"
  }
}
```

**Check firewall:** Ensure localhost connections are not blocked. The server only listens on the loopback interface.

**Restart Claude Code:** After starting the MCP server, restart Claude Code so it picks up the connection.

**Check server status:** The MCP for Unity window in Unity should show a green indicator. If red, click Start Server again.

### Operations Fail Silently

**Check Unity console:** Open **Window > Console** and look for errors. MCP operations that fail will log details there.

**Play mode conflicts:** Some operations (scene manipulation, prefab editing) do not work while Play mode is active. Stop the game before running scene-building commands.

**Missing references:** If an operation references a GameObject by name that does not exist, it will fail. Ask Claude to list scene objects first.

### Multiple Unity Instances

If you have multiple Unity projects open, MCP may connect to the wrong one. Use `set_active_instance` to target the correct Unity instance by its project path.

---

## Security

### Loopback Only

The MCP server binds to `localhost` (127.0.0.1) by default. It is not accessible from other machines on your network.

### Telemetry

unity-mcp may include telemetry. Check the package documentation for opt-out options in the MCP for Unity settings window.

### What MCP Can Do

MCP has full Editor access. It can create, modify, and delete any asset or GameObject in your project. The hooks in `.claude/hooks/` provide guardrails (blocking scene file edits, meta file corruption), but MCP operations bypass file-level hooks since they go through the Unity API, not the filesystem.

---

## Without MCP

If you choose not to install unity-mcp, the following still works:

| Component | Status |
|-----------|--------|
| All 5 rules | Fully functional |
| All 8 hooks | Fully functional |
| All 35 skills | Fully functional (MCP-specific patterns are skipped) |
| Code agents (coder, reviewer, migrator) | Fully functional |
| Scene/build/test agents | Limited -- cannot control the Editor directly |
| `/unity-prototype` | Writes scripts but cannot build the scene or wire components |
| `/unity-audit` | Code checks work, scene hierarchy audit skipped |
| `/unity-build` | Cannot trigger builds, but can configure build scripts |

The system degrades gracefully. Code quality, reviews, and C# implementation work identically with or without MCP. You lose direct Editor manipulation, which means scene building and live testing require manual steps in the Unity Editor.
