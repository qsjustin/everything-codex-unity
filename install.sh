#!/usr/bin/env bash
# ============================================================================
# everything-codex-unity installer
# One-command setup for Unity projects.
# ============================================================================

set -euo pipefail

if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
    RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4); CYAN=$(tput setaf 6); BOLD=$(tput bold); RESET=$(tput sgr0)
else
    RED=""; GREEN=""; YELLOW=""; BLUE=""; CYAN=""; BOLD=""; RESET=""
fi

info()  { echo "${BLUE}[INFO]${RESET} $*"; }
ok()    { echo "${GREEN}[OK]${RESET}   $*"; }
warn()  { echo "${YELLOW}[WARN]${RESET} $*"; }
error() { echo "${RED}[ERR]${RESET}  $*" >&2; }

PROJECT_DIR="."
PROJECT_DIR_SET=0
INSTALL_PROJECT=1
INSTALL_MARKETPLACE=0
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project-dir)
            PROJECT_DIR="$2"
            PROJECT_DIR_SET=1
            shift 2
            ;;
        --codex-marketplace)
            INSTALL_MARKETPLACE=1
            INSTALL_PROJECT=0
            shift
            ;;
        --codex-home)
            CODEX_HOME="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: install.sh [--project-dir <path> | --codex-marketplace] [--codex-home <path>]"
            echo ""
            echo "Installs everything-codex-unity into a Unity project or Codex Desktop."
            echo ""
            echo "Options:"
            echo "  --project-dir <path>       Unity project directory containing Assets/ and ProjectSettings/."
            echo "  --codex-marketplace        Register this toolkit as a Codex Desktop marketplace plugin."
            echo "  --codex-home <path>        Codex home directory for marketplace install (default: \$CODEX_HOME or ~/.codex)."
            echo ""
            echo "Note: --project-dir and --codex-marketplace are mutually exclusive."
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ "$INSTALL_MARKETPLACE" -eq 1 ] && [ "$PROJECT_DIR_SET" -eq 1 ]; then
    error "--project-dir and --codex-marketplace are mutually exclusive. Run project install and Desktop marketplace install separately."
    exit 1
fi

if [ "$INSTALL_PROJECT" -eq 1 ]; then
    PROJECT_DIR=$(cd "$PROJECT_DIR" && pwd)
fi
if [ "$INSTALL_MARKETPLACE" -eq 1 ]; then
    CODEX_HOME=$(mkdir -p "$CODEX_HOME" && cd "$CODEX_HOME" && pwd)
fi
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/scripts/codex-marketplace.sh"

echo ""
echo "${BOLD}${CYAN}Everything Codex Unity${RESET}"
echo "${CYAN}Codex plugin toolkit for Unity game development${RESET}"
echo ""

if [ "$INSTALL_PROJECT" -eq 1 ]; then
    info "Detecting Unity project in: $PROJECT_DIR"
    if [ ! -d "$PROJECT_DIR/Assets" ] || [ ! -d "$PROJECT_DIR/ProjectSettings" ]; then
        error "This does not look like a Unity project. Expected Assets/ and ProjectSettings/."
        exit 1
    else
        ok "Unity project detected"

        UNITY_VERSION="unknown"
        if [ -f "$PROJECT_DIR/ProjectSettings/ProjectVersion.txt" ]; then
            UNITY_VERSION=$(grep 'm_EditorVersion:' "$PROJECT_DIR/ProjectSettings/ProjectVersion.txt" | awk '{print $2}' || echo "unknown")
        fi
        ok "Unity version: $UNITY_VERSION"

        RENDER_PIPELINE="Built-in"
        if [ -f "$PROJECT_DIR/Packages/manifest.json" ]; then
            if grep -q "com.unity.render-pipelines.universal" "$PROJECT_DIR/Packages/manifest.json" 2>/dev/null; then
                RENDER_PIPELINE="URP"
            elif grep -q "com.unity.render-pipelines.high-definition" "$PROJECT_DIR/Packages/manifest.json" 2>/dev/null; then
                RENDER_PIPELINE="HDRP"
            fi
        fi
        ok "Render pipeline: $RENDER_PIPELINE"
    fi
fi

backup_path() {
    local path="$1"
    if [ -e "$path" ]; then
        local backup="${path}.backup.$(date +%Y%m%d%H%M%S)"
        if [ -e "$backup" ]; then
            backup="${backup}.$$"
        fi
        mv "$path" "$backup"
        warn "Backed up existing $(basename "$path") to $(basename "$backup")"
    fi
}

copy_dir() {
    local src="$1"
    local dst="$2"
    local label="$3"
    if [ -d "$src" ]; then
        backup_path "$dst"
        cp -R "$src" "$dst"
        ok "Installed $label"
    fi
}

copy_file() {
    local src="$1"
    local dst="$2"
    local label="$3"
    if [ -f "$src" ]; then
        backup_path "$dst"
        cp "$src" "$dst"
        ok "Installed $label"
    fi
}

install_codex_marketplace() {
    info "Installing Codex Desktop marketplace plugin..."
    ecu_install_marketplace "$SCRIPT_DIR" "$CODEX_HOME" 0
}

if [ "$INSTALL_PROJECT" -eq 1 ]; then
    info "Installing Codex plugin files..."
    copy_dir "$SCRIPT_DIR/.codex-plugin" "$PROJECT_DIR/.codex-plugin" ".codex-plugin/"
    copy_dir "$SCRIPT_DIR/skills" "$PROJECT_DIR/skills" "Codex skills"
    copy_dir "$SCRIPT_DIR/.codex-legacy" "$PROJECT_DIR/.codex-legacy" "legacy reference material"
    copy_file "$SCRIPT_DIR/.mcp.json" "$PROJECT_DIR/.mcp.json" "Unity MCP config"

    if [ -d "$SCRIPT_DIR/templates" ]; then
        mkdir -p "$PROJECT_DIR/.codex-unity/templates"
        cp "$SCRIPT_DIR/templates/"* "$PROJECT_DIR/.codex-unity/templates/" 2>/dev/null || true
        ok "Installed C# templates"
    fi

    if [ -d "$SCRIPT_DIR/scripts" ]; then
        mkdir -p "$PROJECT_DIR/.codex-unity/scripts"
        cp "$SCRIPT_DIR/scripts/"*.sh "$PROJECT_DIR/.codex-unity/scripts/" 2>/dev/null || true
        chmod +x "$PROJECT_DIR/.codex-unity/scripts/"*.sh 2>/dev/null || true
        ok "Installed validation scripts"
    fi

    if [ -d "$SCRIPT_DIR/tests" ]; then
        mkdir -p "$PROJECT_DIR/.codex-unity/tests"
        cp "$SCRIPT_DIR/tests/"*.sh "$PROJECT_DIR/.codex-unity/tests/" 2>/dev/null || true
        chmod +x "$PROJECT_DIR/.codex-unity/tests/"*.sh 2>/dev/null || true
        ok "Installed toolkit tests"
    fi

    info "Generating AGENTS.md..."
    AGENTS_MD="$PROJECT_DIR/AGENTS.md"
    if [ -f "$AGENTS_MD" ]; then
        warn "AGENTS.md already exists; generating AGENTS.md.generated"
        AGENTS_MD="$PROJECT_DIR/AGENTS.md.generated"
    fi

    if [ -f "$SCRIPT_DIR/scripts/generate-agents-md.sh" ]; then
        bash "$SCRIPT_DIR/scripts/generate-agents-md.sh" "$PROJECT_DIR" > "$AGENTS_MD"
    else
        cp "$SCRIPT_DIR/AGENTS.md" "$AGENTS_MD"
    fi
    ok "Generated $(basename "$AGENTS_MD")"

    GITIGNORE="$PROJECT_DIR/.gitignore"
    if [ -f "$GITIGNORE" ]; then
        ENTRIES=(".codex-unity/state/" ".codex-unity/logs/" ".codex.local.json")
        MISSING=()
        for entry in "${ENTRIES[@]}"; do
            grep -qF "$entry" "$GITIGNORE" 2>/dev/null || MISSING+=("$entry")
        done
        if [ ${#MISSING[@]} -gt 0 ]; then
            {
                echo ""
                echo "# Codex Unity local state"
                for entry in "${MISSING[@]}"; do echo "$entry"; done
            } >> "$GITIGNORE"
            ok "Updated .gitignore"
        fi
    fi

    chmod +x "$PROJECT_DIR/.codex-legacy/hooks/"*.sh 2>/dev/null || true
fi

if [ "$INSTALL_MARKETPLACE" -eq 1 ]; then
    install_codex_marketplace
fi

echo ""
echo "${BOLD}${GREEN}Installation complete.${RESET}"
echo ""
echo "Installed:"
if [ "$INSTALL_PROJECT" -eq 1 ]; then
    echo "  ${CYAN}Skills${RESET}      Codex skills in skills/"
    echo "  ${CYAN}Plugin${RESET}      Manifest in .codex-plugin/plugin.json"
    echo "  ${CYAN}MCP${RESET}         Unity MCP config in .mcp.json"
    echo "  ${CYAN}Legacy${RESET}      Reference agents, commands, rules, and hooks in .codex-legacy/"
fi
if [ "$INSTALL_MARKETPLACE" -eq 1 ]; then
    echo "  ${CYAN}Desktop${RESET}     Codex marketplace in $HOME/.agents/plugins/marketplace.json"
    echo "  ${CYAN}Plugin${RESET}      Bundle in $HOME/plugins/everything-codex-unity"
fi
echo ""
echo "Next steps:"
if [ "$INSTALL_PROJECT" -eq 1 ]; then
    echo "  1. Review ${CYAN}AGENTS.md${RESET}"
    echo "  2. Start Unity MCP at ${YELLOW}http://localhost:8080/mcp${RESET} if you want editor automation"
    echo "  3. Run ${CYAN}install.sh --codex-marketplace${RESET} if you want Codex Desktop to discover \$unity-* skills"
else
    echo "  1. Restart Codex Desktop so it reloads the marketplace plugin"
    echo "  2. Open a Unity project and invoke skills such as ${CYAN}\$unity-doctor${RESET} or ${CYAN}\$unity-workflow${RESET}"
fi
echo ""
