#!/usr/bin/env bash
# Upgrade an installed everything-codex-unity copy in a Unity project.

set -euo pipefail

PROJECT_DIR="."
PROJECT_DIR_SET=0
UPGRADE_PROJECT=1
UPGRADE_MARKETPLACE=0
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project-dir)
            PROJECT_DIR="$2"; PROJECT_DIR_SET=1; shift 2 ;;
        --codex-marketplace)
            UPGRADE_MARKETPLACE=1; UPGRADE_PROJECT=0; shift ;;
        --codex-home)
            CODEX_HOME="$2"; shift 2 ;;
        --dry-run)
            DRY_RUN=1; shift ;;
        --help|-h)
            echo "Usage: upgrade.sh [--project-dir <path> | --codex-marketplace] [--codex-home <path>] [--dry-run]"
            echo ""
            echo "Note: --project-dir and --codex-marketplace are mutually exclusive."
            exit 0 ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1 ;;
    esac
done

if [ "$UPGRADE_MARKETPLACE" -eq 1 ] && [ "$PROJECT_DIR_SET" -eq 1 ]; then
    echo "--project-dir and --codex-marketplace are mutually exclusive." >&2
    exit 1
fi

if [ "$UPGRADE_PROJECT" -eq 1 ]; then
    PROJECT_DIR=$(cd "$PROJECT_DIR" && pwd)
fi
if [ "$UPGRADE_MARKETPLACE" -eq 1 ]; then
    CODEX_HOME=$(mkdir -p "$CODEX_HOME" && cd "$CODEX_HOME" && pwd)
fi
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/scripts/codex-marketplace.sh"
STAMP=$(date +%Y%m%d%H%M%S)
BACKUP_DIR="$PROJECT_DIR/.codex-unity-upgrade-backup-$STAMP"

if [ "$UPGRADE_MARKETPLACE" -eq 1 ]; then
    ecu_install_marketplace "$SCRIPT_DIR" "$CODEX_HOME" "$DRY_RUN"
    echo "everything-codex-unity marketplace upgrade complete."
    exit 0
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
