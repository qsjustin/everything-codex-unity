#!/usr/bin/env bash
# Upgrade an installed everything-codex-unity copy in a Unity project.

set -euo pipefail

PROJECT_DIR="."
PROJECT_DIR_SET=0
MARKETPLACE_SET=0
MODE_SET=0
UPGRADE_PROJECT=0
UPGRADE_MARKETPLACE=0
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project-dir)
            PROJECT_DIR="$2"; PROJECT_DIR_SET=1; MODE_SET=1; UPGRADE_PROJECT=1; UPGRADE_MARKETPLACE=0; shift 2 ;;
        --codex-marketplace)
            MARKETPLACE_SET=1; MODE_SET=1; UPGRADE_MARKETPLACE=1; UPGRADE_PROJECT=0; shift ;;
        --codex-home)
            CODEX_HOME="$2"; shift 2 ;;
        --dry-run)
            DRY_RUN=1; shift ;;
        --help|-h)
            echo "Usage: upgrade.sh [--project-dir <path> | --codex-marketplace] [--codex-home <path>] [--dry-run]"
            echo ""
            echo "If no mode is provided, the script auto-detects a project install in the current Unity project,"
            echo "then falls back to a Codex Desktop marketplace install."
            echo ""
            echo "Note: --project-dir and --codex-marketplace are mutually exclusive."
            exit 0 ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1 ;;
    esac
done

if [ "$MARKETPLACE_SET" -eq 1 ] && [ "$PROJECT_DIR_SET" -eq 1 ]; then
    echo "--project-dir and --codex-marketplace are mutually exclusive." >&2
    exit 1
fi

if [ "$UPGRADE_MARKETPLACE" -eq 0 ]; then
    PROJECT_DIR=$(cd "$PROJECT_DIR" && pwd)
fi
if [ "$UPGRADE_MARKETPLACE" -eq 1 ]; then
    CODEX_HOME=$(mkdir -p "$CODEX_HOME" && cd "$CODEX_HOME" && pwd)
fi
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/scripts/codex-marketplace.sh"
STAMP=$(date +%Y%m%d%H%M%S)
BACKUP_DIR="$PROJECT_DIR/.codex-unity-upgrade-backup-$STAMP"

has_project_install() {
    [ -f "$PROJECT_DIR/.codex-plugin/plugin.json" ] && grep -q '"name"[[:space:]]*:[[:space:]]*"everything-codex-unity"' "$PROJECT_DIR/.codex-plugin/plugin.json" 2>/dev/null && return 0
    [ -f "$PROJECT_DIR/skills/workflows/unity-workflow/SKILL.md" ] && grep -q '^name:[[:space:]]*unity-workflow' "$PROJECT_DIR/skills/workflows/unity-workflow/SKILL.md" 2>/dev/null && return 0
    [ -f "$PROJECT_DIR/skills/unity-project-rules/SKILL.md" ] && grep -q '^name:[[:space:]]*unity-project-rules' "$PROJECT_DIR/skills/unity-project-rules/SKILL.md" 2>/dev/null && return 0
    [ -f "$PROJECT_DIR/.codex-legacy/commands/unity-workflow.md" ] && return 0
    [ -f "$PROJECT_DIR/.codex-unity/scripts/generate-agents-md.sh" ] && return 0
    [ -f "$PROJECT_DIR/AGENTS.md" ] && grep -q "everything-codex-unity" "$PROJECT_DIR/AGENTS.md" 2>/dev/null && return 0
    return 1
}

is_unity_project() {
    [ -d "$PROJECT_DIR/Assets" ] && [ -d "$PROJECT_DIR/ProjectSettings" ]
}

has_marketplace_install() {
    local marketplace_json="$HOME/.agents/plugins/marketplace.json"
    local config_file="$CODEX_HOME/config.toml"

    [ -d "$HOME/plugins/$ECU_PLUGIN_NAME" ] && return 0
    [ -f "$config_file" ] && grep -q "everything-codex-unity@everything-codex-unity" "$config_file" 2>/dev/null && return 0
    if [ -f "$marketplace_json" ] && command -v python3 >/dev/null 2>&1; then
        python3 - "$marketplace_json" <<'PY' && return 0
import json
import sys
from pathlib import Path

try:
    data = json.loads(Path(sys.argv[1]).read_text())
except Exception:
    sys.exit(1)
for plugin in data.get("plugins", []):
    if plugin.get("name") == "everything-codex-unity":
        sys.exit(0)
sys.exit(1)
PY
    fi
    return 1
}

if [ "$MODE_SET" -eq 0 ]; then
    if is_unity_project && has_project_install; then
        UPGRADE_PROJECT=1
        echo "Auto-detected project install in $PROJECT_DIR"
    elif has_marketplace_install; then
        UPGRADE_MARKETPLACE=1
        UPGRADE_PROJECT=0
        CODEX_HOME=$(mkdir -p "$CODEX_HOME" && cd "$CODEX_HOME" && pwd)
        echo "Auto-detected Codex marketplace install"
    else
        echo "No everything-codex-unity install detected." >&2
        echo "Run upgrade.sh --project-dir <UnityProject> or upgrade.sh --codex-marketplace." >&2
        exit 1
    fi
fi

if [ "$UPGRADE_MARKETPLACE" -eq 1 ]; then
    if [ ! -d "$HOME/plugins/$ECU_PLUGIN_NAME" ]; then
        echo "No Codex marketplace install found at $HOME/plugins/$ECU_PLUGIN_NAME." >&2
        echo "Run install.sh --codex-marketplace first." >&2
        exit 1
    fi
    ecu_install_marketplace "$SCRIPT_DIR" "$CODEX_HOME" "$DRY_RUN"
    echo "everything-codex-unity marketplace upgrade complete."
    exit 0
fi

if ! has_project_install; then
    echo "No everything-codex-unity project install found in $PROJECT_DIR." >&2
    echo "Run install.sh --project-dir \"$PROJECT_DIR\" first." >&2
    exit 1
fi

copy_dir() {
    local src="$1"
    local dst="$2"
    local label="$3"
    [ -d "$src" ] || return 0
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "Would upgrade $label -> $dst"
        return 0
    fi
    mkdir -p "$BACKUP_DIR"
    if [ -e "$dst" ]; then
        mv "$dst" "$BACKUP_DIR/$(basename "$dst")"
    fi
    cp -R "$src" "$dst"
    echo "Upgraded $label"
}

copy_file() {
    local src="$1"
    local dst="$2"
    local label="$3"
    [ -f "$src" ] || return 0
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "Would upgrade $label -> $dst"
        return 0
    fi
    mkdir -p "$BACKUP_DIR"
    if [ -e "$dst" ]; then
        mv "$dst" "$BACKUP_DIR/$(basename "$dst")"
    fi
    cp "$src" "$dst"
    echo "Upgraded $label"
}

copy_dir "$SCRIPT_DIR/.codex-plugin" "$PROJECT_DIR/.codex-plugin" ".codex-plugin"
copy_dir "$SCRIPT_DIR/skills" "$PROJECT_DIR/skills" "skills"
copy_dir "$SCRIPT_DIR/.codex-legacy" "$PROJECT_DIR/.codex-legacy" "legacy references"
copy_file "$SCRIPT_DIR/.mcp.json" "$PROJECT_DIR/.mcp.json" ".mcp.json"

if [ "$DRY_RUN" -eq 1 ]; then
    [ -d "$SCRIPT_DIR/templates" ] && echo "Would upgrade templates -> $PROJECT_DIR/.codex-unity/templates"
    [ -d "$SCRIPT_DIR/scripts" ] && echo "Would upgrade scripts -> $PROJECT_DIR/.codex-unity/scripts"
    [ -d "$SCRIPT_DIR/tests" ] && echo "Would upgrade tests -> $PROJECT_DIR/.codex-unity/tests"
else
    mkdir -p "$PROJECT_DIR/.codex-unity/templates" "$PROJECT_DIR/.codex-unity/scripts" "$PROJECT_DIR/.codex-unity/tests"
    cp "$SCRIPT_DIR/templates/"* "$PROJECT_DIR/.codex-unity/templates/" 2>/dev/null || true
    cp "$SCRIPT_DIR/scripts/"*.sh "$PROJECT_DIR/.codex-unity/scripts/" 2>/dev/null || true
    cp "$SCRIPT_DIR/tests/"*.sh "$PROJECT_DIR/.codex-unity/tests/" 2>/dev/null || true
    chmod +x "$PROJECT_DIR/.codex-unity/scripts/"*.sh "$PROJECT_DIR/.codex-unity/tests/"*.sh 2>/dev/null || true
    echo "Upgraded .codex-unity support files"
fi

if [ -f "$SCRIPT_DIR/scripts/generate-agents-md.sh" ] && [ "$DRY_RUN" -eq 0 ]; then
    bash "$SCRIPT_DIR/scripts/generate-agents-md.sh" "$PROJECT_DIR" > "$PROJECT_DIR/AGENTS.md.generated"
    echo "Generated AGENTS.md.generated for review"
fi

if [ "$DRY_RUN" -eq 0 ]; then
    chmod +x "$PROJECT_DIR/.codex-legacy/hooks/"*.sh 2>/dev/null || true
    echo "Backup written to: $BACKUP_DIR"
fi

echo "everything-codex-unity upgrade complete."
