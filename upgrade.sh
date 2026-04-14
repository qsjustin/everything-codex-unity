#!/usr/bin/env bash
# ============================================================================
# everything-claude-unity upgrade script
# Updates an existing installation to the latest version while preserving
# user customizations (settings.local.json, custom agents/commands/skills).
#
# Usage:
#   ./upgrade.sh [--project-dir <path>] [--dry-run] [--force]
# ============================================================================

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────────────
if [ -t 1 ] && command -v tput &>/dev/null; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    CYAN=$(tput setaf 6)
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    RED="" GREEN="" YELLOW="" BLUE="" CYAN="" BOLD="" RESET=""
fi

info()  { echo "${BLUE}[INFO]${RESET} $*"; }
ok()    { echo "${GREEN}[OK]${RESET}   $*"; }
warn()  { echo "${YELLOW}[WARN]${RESET} $*"; }
error() { echo "${RED}[ERR]${RESET}  $*" >&2; }

# ── Parse Arguments ─────────────────────────────────────────────────────────
PROJECT_DIR="."
DRY_RUN=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project-dir) PROJECT_DIR="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --force) FORCE=true; shift ;;
        -h|--help)
            cat <<EOF
${BOLD}upgrade.sh${RESET} — Update everything-claude-unity to the latest version.

${BOLD}Usage:${RESET}
  ./upgrade.sh [OPTIONS]

${BOLD}Options:${RESET}
  --project-dir <path>  Target Unity project directory (default: current dir)
  --dry-run             Show what would change without making modifications
  --force               Upgrade even if versions match
  -h, --help            Show this help

${BOLD}What it does:${RESET}
  1. Detects current and source versions
  2. Backs up existing .claude/ directory
  3. Copies new files while preserving settings.local.json and custom additions
  4. Reports what changed (added, modified, removed files)
  5. Sets correct permissions on hook and script files
EOF
            exit 0
            ;;
        *) error "Unknown option: $1"; exit 1 ;;
    esac
done

# ── Resolve Paths ──────────────────────────────────────────────────────────
PROJECT_DIR=$(cd "$PROJECT_DIR" && pwd)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Validate ───────────────────────────────────────────────────────────────
if [ ! -d "$PROJECT_DIR/.claude" ]; then
    error "No .claude/ directory found in $PROJECT_DIR"
    error "Run install.sh first to install everything-claude-unity."
    exit 1
fi

if [ ! -d "$PROJECT_DIR/Assets" ] || [ ! -d "$PROJECT_DIR/ProjectSettings" ]; then
    error "Not a Unity project (missing Assets/ or ProjectSettings/)"
    exit 1
fi

# ── Version Detection ──────────────────────────────────────────────────────
CURRENT_VERSION="unknown"
if [ -f "$PROJECT_DIR/.claude/VERSION" ]; then
    CURRENT_VERSION=$(cat "$PROJECT_DIR/.claude/VERSION" | tr -d '[:space:]')
fi

SOURCE_VERSION="unknown"
if [ -f "$SCRIPT_DIR/.claude/VERSION" ]; then
    SOURCE_VERSION=$(cat "$SCRIPT_DIR/.claude/VERSION" | tr -d '[:space:]')
fi

info "Current version: ${BOLD}$CURRENT_VERSION${RESET}"
info "Source version:  ${BOLD}$SOURCE_VERSION${RESET}"

if [ "$CURRENT_VERSION" = "$SOURCE_VERSION" ] && ! $FORCE; then
    ok "Already up to date (v$CURRENT_VERSION). Use --force to upgrade anyway."
    exit 0
fi

if $DRY_RUN; then
    info "${YELLOW}DRY RUN — no changes will be made${RESET}"
    echo ""
fi

# ── Backup ─────────────────────────────────────────────────────────────────
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$PROJECT_DIR/.claude.backup.$TIMESTAMP"

if ! $DRY_RUN; then
    info "Backing up .claude/ to .claude.backup.$TIMESTAMP/"
    cp -r "$PROJECT_DIR/.claude" "$BACKUP_DIR"
    ok "Backup created"
else
    info "Would backup .claude/ to .claude.backup.$TIMESTAMP/"
fi

# ── Preserve User Customizations ───────────────────────────────────────────
PRESERVED_FILES=()

# Preserve settings.local.json
if [ -f "$PROJECT_DIR/.claude/settings.local.json" ]; then
    PRESERVED_FILES+=("settings.local.json")
    if ! $DRY_RUN; then
        cp "$PROJECT_DIR/.claude/settings.local.json" "/tmp/unity-claude-settings-local-$TIMESTAMP.json"
    fi
    info "Preserving settings.local.json"
fi

# ── Detect Custom Files ────────────────────────────────────────────────────
# Files in the target that don't exist in the source are considered custom
CUSTOM_FILES=()
for DIR in agents commands skills; do
    if [ -d "$PROJECT_DIR/.claude/$DIR" ]; then
        while IFS= read -r -d '' FILE; do
            REL_PATH="${FILE#$PROJECT_DIR/.claude/}"
            if [ ! -f "$SCRIPT_DIR/.claude/$REL_PATH" ]; then
                CUSTOM_FILES+=("$REL_PATH")
            fi
        done < <(find "$PROJECT_DIR/.claude/$DIR" -name "*.md" -print0 2>/dev/null || true)
    fi
done

if [ ${#CUSTOM_FILES[@]} -gt 0 ]; then
    info "Found ${#CUSTOM_FILES[@]} custom file(s) — these will be preserved:"
    for CF in "${CUSTOM_FILES[@]}"; do
        echo "    $CF"
    done
fi

# ── Copy New Files ─────────────────────────────────────────────────────────
ADDED=0
MODIFIED=0

info "Updating .claude/ directory..."

# Copy .claude/ contents
while IFS= read -r -d '' SRC_FILE; do
    REL_PATH="${SRC_FILE#$SCRIPT_DIR/.claude/}"
    DEST_FILE="$PROJECT_DIR/.claude/$REL_PATH"

    if [ ! -f "$DEST_FILE" ]; then
        if ! $DRY_RUN; then
            mkdir -p "$(dirname "$DEST_FILE")"
            cp "$SRC_FILE" "$DEST_FILE"
        fi
        echo "  ${GREEN}+${RESET} $REL_PATH"
        ADDED=$((ADDED + 1))
    elif ! diff -q "$SRC_FILE" "$DEST_FILE" > /dev/null 2>&1; then
        if ! $DRY_RUN; then
            cp "$SRC_FILE" "$DEST_FILE"
        fi
        echo "  ${YELLOW}~${RESET} $REL_PATH"
        MODIFIED=$((MODIFIED + 1))
    fi
done < <(find "$SCRIPT_DIR/.claude" -type f -print0 2>/dev/null || true)

# Copy scripts/
if [ -d "$SCRIPT_DIR/scripts" ]; then
    while IFS= read -r -d '' SRC_FILE; do
        REL_PATH="${SRC_FILE#$SCRIPT_DIR/}"
        DEST_FILE="$PROJECT_DIR/.claude/$REL_PATH"
        if [ ! -f "$DEST_FILE" ] || ! diff -q "$SRC_FILE" "$DEST_FILE" > /dev/null 2>&1; then
            if ! $DRY_RUN; then
                mkdir -p "$(dirname "$DEST_FILE")"
                cp "$SRC_FILE" "$DEST_FILE"
            fi
            if [ ! -f "$DEST_FILE" ]; then
                echo "  ${GREEN}+${RESET} $REL_PATH"
                ADDED=$((ADDED + 1))
            else
                echo "  ${YELLOW}~${RESET} $REL_PATH"
                MODIFIED=$((MODIFIED + 1))
            fi
        fi
    done < <(find "$SCRIPT_DIR/scripts" -type f -print0 2>/dev/null || true)
fi

# Copy tests/
if [ -d "$SCRIPT_DIR/tests" ]; then
    while IFS= read -r -d '' SRC_FILE; do
        REL_PATH="${SRC_FILE#$SCRIPT_DIR/}"
        DEST_FILE="$PROJECT_DIR/.claude/$REL_PATH"
        if [ ! -f "$DEST_FILE" ] || ! diff -q "$SRC_FILE" "$DEST_FILE" > /dev/null 2>&1; then
            if ! $DRY_RUN; then
                mkdir -p "$(dirname "$DEST_FILE")"
                cp "$SRC_FILE" "$DEST_FILE"
            fi
            if [ ! -f "$DEST_FILE" ]; then
                echo "  ${GREEN}+${RESET} $REL_PATH"
                ADDED=$((ADDED + 1))
            else
                echo "  ${YELLOW}~${RESET} $REL_PATH"
                MODIFIED=$((MODIFIED + 1))
            fi
        fi
    done < <(find "$SCRIPT_DIR/tests" -type f -print0 2>/dev/null || true)
fi

# Copy templates/
if [ -d "$SCRIPT_DIR/templates" ]; then
    while IFS= read -r -d '' SRC_FILE; do
        REL_PATH="${SRC_FILE#$SCRIPT_DIR/}"
        DEST_FILE="$PROJECT_DIR/$REL_PATH"
        if [ ! -f "$DEST_FILE" ] || ! diff -q "$SRC_FILE" "$DEST_FILE" > /dev/null 2>&1; then
            if ! $DRY_RUN; then
                mkdir -p "$(dirname "$DEST_FILE")"
                cp "$SRC_FILE" "$DEST_FILE"
            fi
            if [ ! -f "$DEST_FILE" ]; then
                echo "  ${GREEN}+${RESET} $REL_PATH"
                ADDED=$((ADDED + 1))
            else
                echo "  ${YELLOW}~${RESET} $REL_PATH"
                MODIFIED=$((MODIFIED + 1))
            fi
        fi
    done < <(find "$SCRIPT_DIR/templates" -type f -print0 2>/dev/null || true)
fi

# ── Restore Preserved Files ───────────────────────────────────────────────
if [ ${#PRESERVED_FILES[@]} -gt 0 ] && ! $DRY_RUN; then
    for PF in "${PRESERVED_FILES[@]}"; do
        case "$PF" in
            settings.local.json)
                cp "/tmp/unity-claude-settings-local-$TIMESTAMP.json" "$PROJECT_DIR/.claude/settings.local.json"
                rm -f "/tmp/unity-claude-settings-local-$TIMESTAMP.json"
                ;;
        esac
    done
    ok "Restored preserved files"
fi

# ── Restore Custom Files ──────────────────────────────────────────────────
if [ ${#CUSTOM_FILES[@]} -gt 0 ] && ! $DRY_RUN; then
    for CF in "${CUSTOM_FILES[@]}"; do
        if [ -f "$BACKUP_DIR/$CF" ] && [ ! -f "$PROJECT_DIR/.claude/$CF" ]; then
            mkdir -p "$(dirname "$PROJECT_DIR/.claude/$CF")"
            cp "$BACKUP_DIR/$CF" "$PROJECT_DIR/.claude/$CF"
        fi
    done
    ok "Restored custom files"
fi

# ── Set Permissions ────────────────────────────────────────────────────────
if ! $DRY_RUN; then
    find "$PROJECT_DIR/.claude/hooks" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    find "$PROJECT_DIR/.claude/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    find "$PROJECT_DIR/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
fi

# ── Summary ────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
if $DRY_RUN; then
    echo "${BOLD}Upgrade Preview (dry run — no changes made)${RESET}"
else
    echo "${BOLD}Upgrade Complete${RESET}"
fi
echo "═══════════════════════════════════════════════════════════════"
echo "  Version:  ${CURRENT_VERSION} → ${GREEN}${SOURCE_VERSION}${RESET}"
echo "  Added:    ${GREEN}$ADDED${RESET} file(s)"
echo "  Modified: ${YELLOW}$MODIFIED${RESET} file(s)"
echo "  Custom:   ${#CUSTOM_FILES[@]} file(s) preserved"
if ! $DRY_RUN; then
    echo "  Backup:   .claude.backup.$TIMESTAMP/"
fi
echo "═══════════════════════════════════════════════════════════════"

if ! $DRY_RUN; then
    ok "Upgrade to v$SOURCE_VERSION complete."
    echo ""
    echo "Run ${CYAN}/unity-doctor${RESET} to verify the installation."
fi
