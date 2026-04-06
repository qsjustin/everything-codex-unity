#!/usr/bin/env bash
# ============================================================================
# everything-claude-unity uninstall script
# Cleanly removes the .claude/ directory, cleans CLAUDE.md, and updates
# .gitignore. Creates a backup before removal unless --no-backup is used.
#
# Usage:
#   ./uninstall.sh [--project-dir <path>] [--yes] [--keep-local] [--no-backup]
# ============================================================================

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────────────
if [ -t 1 ] && command -v tput &>/dev/null; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    RED="" GREEN="" YELLOW="" BLUE="" BOLD="" RESET=""
fi

info()  { echo "${BLUE}[INFO]${RESET} $*"; }
ok()    { echo "${GREEN}[OK]${RESET}   $*"; }
warn()  { echo "${YELLOW}[WARN]${RESET} $*"; }
error() { echo "${RED}[ERR]${RESET}  $*" >&2; }

# ── Parse Arguments ─────────────────────────────────────────────────────────
PROJECT_DIR="."
SKIP_CONFIRM=false
KEEP_LOCAL=false
NO_BACKUP=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project-dir) PROJECT_DIR="$2"; shift 2 ;;
        --yes|-y) SKIP_CONFIRM=true; shift ;;
        --keep-local) KEEP_LOCAL=true; shift ;;
        --no-backup) NO_BACKUP=true; shift ;;
        -h|--help)
            cat <<EOF
${BOLD}uninstall.sh${RESET} — Remove everything-claude-unity from a project.

${BOLD}Usage:${RESET}
  ./uninstall.sh [OPTIONS]

${BOLD}Options:${RESET}
  --project-dir <path>  Target Unity project directory (default: current dir)
  --yes, -y             Skip confirmation prompt
  --keep-local          Preserve settings.local.json (saved to project root)
  --no-backup           Skip creating a backup of .claude/ before removal
  -h, --help            Show this help

${BOLD}What it removes:${RESET}
  - .claude/ directory (agents, commands, skills, hooks, rules, settings)
  - .gitignore entry for .claude/settings.local.json
  - Optionally: generated CLAUDE.md (if it appears installer-generated)
EOF
            exit 0
            ;;
        *) error "Unknown option: $1"; exit 1 ;;
    esac
done

# ── Resolve Paths ──────────────────────────────────────────────────────────
PROJECT_DIR=$(cd "$PROJECT_DIR" && pwd)

# ── Validate ───────────────────────────────────────────────────────────────
if [ ! -d "$PROJECT_DIR/.claude" ]; then
    error "No .claude/ directory found in $PROJECT_DIR"
    error "Nothing to uninstall."
    exit 1
fi

# Verify it's an everything-claude-unity installation
IS_ECU=false
if [ -f "$PROJECT_DIR/.claude/VERSION" ] || [ -f "$PROJECT_DIR/.claude/hooks/block-scene-edit.sh" ]; then
    IS_ECU=true
fi

if ! $IS_ECU; then
    warn "This .claude/ directory may not be an everything-claude-unity installation."
    warn "Proceeding will remove it anyway."
fi

# ── Confirmation ───────────────────────────────────────────────────────────
if ! $SKIP_CONFIRM; then
    echo ""
    echo "${BOLD}This will remove:${RESET}"
    echo "  - $PROJECT_DIR/.claude/ (all agents, commands, skills, hooks, rules)"

    if [ -f "$PROJECT_DIR/.gitignore" ] && grep -q 'settings.local.json' "$PROJECT_DIR/.gitignore"; then
        echo "  - .gitignore entry for .claude/settings.local.json"
    fi

    if $KEEP_LOCAL && [ -f "$PROJECT_DIR/.claude/settings.local.json" ]; then
        echo ""
        echo "  ${GREEN}Preserving:${RESET} settings.local.json → .claude-settings-local.json.saved"
    fi

    echo ""
    read -rp "Continue? [y/N] " REPLY
    case "$REPLY" in
        [yY]|[yY][eE][sS]) ;;
        *) info "Cancelled."; exit 0 ;;
    esac
fi

# ── Backup ─────────────────────────────────────────────────────────────────
if ! $NO_BACKUP; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="$PROJECT_DIR/.claude.backup.$TIMESTAMP"
    info "Creating backup at .claude.backup.$TIMESTAMP/"
    cp -r "$PROJECT_DIR/.claude" "$BACKUP_DIR"
    ok "Backup created"
fi

# ── Preserve settings.local.json ──────────────────────────────────────────
if $KEEP_LOCAL && [ -f "$PROJECT_DIR/.claude/settings.local.json" ]; then
    cp "$PROJECT_DIR/.claude/settings.local.json" "$PROJECT_DIR/.claude-settings-local.json.saved"
    ok "Saved settings.local.json to .claude-settings-local.json.saved"
fi

# ── Remove .claude/ ───────────────────────────────────────────────────────
info "Removing .claude/ directory..."
rm -rf "$PROJECT_DIR/.claude"
ok "Removed .claude/"

# ── Clean .gitignore ──────────────────────────────────────────────────────
if [ -f "$PROJECT_DIR/.gitignore" ]; then
    if grep -q '.claude/settings.local.json' "$PROJECT_DIR/.gitignore"; then
        info "Cleaning .gitignore..."
        # Remove the settings.local.json line and its comment
        sed -i.bak '/.claude\/settings.local.json/d' "$PROJECT_DIR/.gitignore"
        sed -i.bak '/# Claude Code local settings/d' "$PROJECT_DIR/.gitignore"
        rm -f "$PROJECT_DIR/.gitignore.bak"
        ok "Cleaned .gitignore"
    fi
fi

# ── Check CLAUDE.md ───────────────────────────────────────────────────────
if [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
    if grep -q 'everything-claude-unity' "$PROJECT_DIR/CLAUDE.md" 2>/dev/null; then
        warn "CLAUDE.md appears to be generated by the installer."
        if ! $SKIP_CONFIRM; then
            read -rp "Remove CLAUDE.md? [y/N] " REPLY
            case "$REPLY" in
                [yY]|[yY][eE][sS])
                    rm -f "$PROJECT_DIR/CLAUDE.md"
                    ok "Removed CLAUDE.md"
                    ;;
                *) info "Kept CLAUDE.md" ;;
            esac
        else
            info "Kept CLAUDE.md (use manual removal if desired)"
        fi
    fi
fi

# ── Summary ────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "${BOLD}Uninstall Complete${RESET}"
echo "═══════════════════════════════════════════════════════════════"
echo "  Removed: .claude/ directory"
if ! $NO_BACKUP; then
    echo "  Backup:  .claude.backup.$TIMESTAMP/"
fi
if $KEEP_LOCAL; then
    echo "  Saved:   .claude-settings-local.json.saved"
fi
echo "═══════════════════════════════════════════════════════════════"
echo ""
ok "everything-claude-unity has been removed."
echo "To reinstall: ${BOLD}./install.sh --project-dir $PROJECT_DIR${RESET}"
