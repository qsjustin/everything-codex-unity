#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-.}"
PROJECT_DIR=$(cd "$PROJECT_DIR" && pwd)

UNITY_VERSION="unknown"
if [ -f "$PROJECT_DIR/ProjectSettings/ProjectVersion.txt" ]; then
    UNITY_VERSION=$(grep 'm_EditorVersion:' "$PROJECT_DIR/ProjectSettings/ProjectVersion.txt" | awk '{print $2}' || echo "unknown")
fi

RENDER_PIPELINE="Built-in"
if [ -f "$PROJECT_DIR/Packages/manifest.json" ]; then
    if grep -q "com.unity.render-pipelines.universal" "$PROJECT_DIR/Packages/manifest.json" 2>/dev/null; then
        RENDER_PIPELINE="URP"
    elif grep -q "com.unity.render-pipelines.high-definition" "$PROJECT_DIR/Packages/manifest.json" 2>/dev/null; then
        RENDER_PIPELINE="HDRP"
    fi
fi

ASMDEF_COUNT=$(find "$PROJECT_DIR/Assets" -name "*.asmdef" 2>/dev/null | wc -l | tr -d ' ')
SCENE_COUNT=$(find "$PROJECT_DIR/Assets" -name "*.unity" 2>/dev/null | wc -l | tr -d ' ')

cat <<EOF
# Codex Project Instructions

## Unity Project

- Unity Version: $UNITY_VERSION
- Render Pipeline: $RENDER_PIPELINE
- Assembly Definitions: $ASMDEF_COUNT
- Scenes: $SCENE_COUNT

## Codex Unity Toolkit

This project uses everything-codex-unity.

- Plugin manifest: \`.codex-plugin/plugin.json\`
- Skills: \`skills/**/SKILL.md\`
- Legacy references: \`.codex-legacy/\`
- Unity MCP config: \`.mcp.json\`

## Rules

Use \`unity-project-rules\` and the relevant domain skills before changing Unity code.

- Add \`[FormerlySerializedAs]\` for serialized field renames.
- Prefer \`[SerializeField] private\` fields with read-only public accessors.
- Use \`obj == null\` for \`UnityEngine.Object\` null checks.
- Keep Editor-only code guarded by \`#if UNITY_EDITOR\` or inside \`Editor/\`.
- Cache component lookups and avoid per-frame allocations.
- Prefer Unity MCP for scene, prefab, asset, console, playmode, and build operations.
EOF
