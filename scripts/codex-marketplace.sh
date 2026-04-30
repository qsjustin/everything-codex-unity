#!/usr/bin/env bash
# Shared helpers for Codex Desktop home-local marketplace installs.

set -euo pipefail

ECU_PLUGIN_NAME="everything-codex-unity"
ECU_MARKETPLACE_NAME="everything-codex-unity"

ecu_require_python3() {
    if ! command -v python3 >/dev/null 2>&1; then
        echo "python3 is required to update Codex marketplace JSON without overwriting other plugins." >&2
        exit 1
    fi
}

ecu_validate_marketplace_json() {
    local marketplace_json="$1"

    if [ ! -f "$marketplace_json" ]; then
        return 0
    fi

    ecu_require_python3
    python3 - "$marketplace_json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
try:
    data = json.loads(path.read_text())
except Exception as exc:
    print(f"Invalid marketplace JSON at {path}: {exc}", file=sys.stderr)
    sys.exit(1)

if not isinstance(data, dict):
    print(f"Marketplace JSON must be an object: {path}", file=sys.stderr)
    sys.exit(1)

plugins = data.get("plugins", [])
if not isinstance(plugins, list):
    print(f"Marketplace JSON plugins field must be an array: {path}", file=sys.stderr)
    sys.exit(1)
PY
}

ecu_backup_path() {
    local path="$1"
    local stamp="${2:-$(date +%Y%m%d%H%M%S)}"
    local backup

    if [ ! -e "$path" ]; then
        return 0
    fi

    backup="${path}.backup.${stamp}"
    if [ -e "$backup" ]; then
        backup="${backup}.$$"
    fi
    mv "$path" "$backup"
    echo "Backed up $(basename "$path") to $(basename "$backup")"
}

ecu_copy_flattened_skills() {
    local src_root="$1"
    local dst_root="$2"
    local skill_file
    local skill_name
    local skill_dir
    local dst_dir

    rm -rf "$dst_root"
    mkdir -p "$dst_root"

    while IFS= read -r skill_file; do
        skill_name=$(awk '
            /^---[[:space:]]*$/ {
                if (in_fm == 0) { in_fm = 1; next }
                exit
            }
            in_fm == 1 && /^name:[[:space:]]*/ {
                sub(/^name:[[:space:]]*/, "")
                gsub(/^[[:space:]"'\''`]+|[[:space:]"'\''`]+$/, "")
                print
                exit
            }
        ' "$skill_file")
        if [ -z "$skill_name" ]; then
            echo "Skill is missing frontmatter name: $skill_file" >&2
            exit 1
        fi

        skill_dir=$(dirname "$skill_file")
        dst_dir="$dst_root/$skill_name"
        if [ -e "$dst_dir" ]; then
            echo "Duplicate skill name for marketplace install: $skill_name" >&2
            exit 1
        fi
        cp -R "$skill_dir" "$dst_dir"
    done < <(find "$src_root" -name SKILL.md -type f | sort)
}

ecu_write_codex_config_section() {
    local config_file="$1"
    local marketplace_root="$2"
    local tmp_file

    mkdir -p "$(dirname "$config_file")"
    touch "$config_file"
    tmp_file=$(mktemp)
    awk '
        /^\[marketplaces\.everything-codex-unity\]$/ { skip=1; next }
        /^\[plugins\."everything-codex-unity@everything-codex-unity"\]$/ { skip=1; next }
        /^\[/ { skip=0 }
        skip != 1 { print }
    ' "$config_file" > "$tmp_file"
    mv "$tmp_file" "$config_file"

    {
        echo ""
        echo "[marketplaces.everything-codex-unity]"
        echo "last_updated = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
        echo "source_type = \"local\""
        echo "source = \"$marketplace_root\""
        echo ""
        echo "[plugins.\"everything-codex-unity@everything-codex-unity\"]"
        echo "enabled = true"
    } >> "$config_file"
}

ecu_remove_codex_config_section() {
    local config_file="$1"
    local tmp_file

    if [ ! -f "$config_file" ]; then
        return 0
    fi

    tmp_file=$(mktemp)
    awk '
        /^\[marketplaces\.everything-codex-unity\]$/ { skip=1; next }
        /^\[plugins\."everything-codex-unity@everything-codex-unity"\]$/ { skip=1; next }
        /^\[/ { skip=0 }
        skip != 1 { print }
    ' "$config_file" > "$tmp_file"
    mv "$tmp_file" "$config_file"
}

ecu_upsert_marketplace_entry() {
    local marketplace_json="$1"
    mkdir -p "$(dirname "$marketplace_json")"
    ecu_require_python3

    python3 - "$marketplace_json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
if path.exists():
    data = json.loads(path.read_text())
else:
    data = {
        "name": "everything-codex-unity",
        "interface": {"displayName": "Everything Codex Unity"},
        "plugins": [],
    }

data.setdefault("name", "everything-codex-unity")
data.setdefault("interface", {}).setdefault("displayName", "Everything Codex Unity")
plugins = [p for p in data.get("plugins", []) if p.get("name") != "everything-codex-unity"]
plugins.append({
    "name": "everything-codex-unity",
    "source": {
        "source": "local",
        "path": "./plugins/everything-codex-unity",
    },
    "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL",
    },
    "category": "Developer Tools",
})
data["plugins"] = plugins
path.write_text(json.dumps(data, indent=2) + "\n")
PY
}

ecu_remove_marketplace_entry() {
    local marketplace_json="$1"
    if [ ! -f "$marketplace_json" ]; then
        return 0
    fi
    ecu_require_python3

    python3 - "$marketplace_json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text())
data["plugins"] = [p for p in data.get("plugins", []) if p.get("name") != "everything-codex-unity"]
path.write_text(json.dumps(data, indent=2) + "\n")
PY
}

ecu_install_marketplace() {
    local script_dir="$1"
    local codex_home="$2"
    local dry_run="${3:-0}"
    local marketplace_root="$HOME"
    local plugin_dir="$marketplace_root/plugins/$ECU_PLUGIN_NAME"
    local marketplace_json="$marketplace_root/.agents/plugins/marketplace.json"
    local config_file="$codex_home/config.toml"
    local stamp

    stamp=$(date +%Y%m%d%H%M%S)

    if [ "$dry_run" -eq 1 ]; then
        echo "Would install Codex marketplace entry -> $marketplace_json"
        echo "Would install plugin bundle -> $plugin_dir"
        echo "Would enable plugin in -> $config_file"
        return 0
    fi

    ecu_validate_marketplace_json "$marketplace_json"

    mkdir -p "$marketplace_root/.agents/plugins" "$marketplace_root/plugins"
    ecu_backup_path "$plugin_dir" "$stamp"
    mkdir -p "$plugin_dir"

    cp -R "$script_dir/.codex-plugin" "$plugin_dir/.codex-plugin"
    ecu_copy_flattened_skills "$script_dir/skills" "$plugin_dir/skills"
    cp "$script_dir/.mcp.json" "$plugin_dir/.mcp.json"
    [ -d "$script_dir/.codex-legacy" ] && cp -R "$script_dir/.codex-legacy" "$plugin_dir/.codex-legacy"
    [ -d "$script_dir/templates" ] && cp -R "$script_dir/templates" "$plugin_dir/templates"
    [ -d "$script_dir/scripts" ] && cp -R "$script_dir/scripts" "$plugin_dir/scripts"
    [ -d "$script_dir/tests" ] && cp -R "$script_dir/tests" "$plugin_dir/tests"
    chmod +x "$plugin_dir/.codex-legacy/hooks/"*.sh 2>/dev/null || true
    chmod +x "$plugin_dir/scripts/"*.sh "$plugin_dir/tests/"*.sh 2>/dev/null || true

    ecu_upsert_marketplace_entry "$marketplace_json"
    ecu_write_codex_config_section "$config_file" "$marketplace_root"

    echo "Installed Codex marketplace entry at $marketplace_json"
    echo "Installed plugin bundle at $plugin_dir"
    echo "Enabled plugin in $config_file"
}

ecu_uninstall_marketplace() {
    local codex_home="$1"
    local keep_backup="${2:-1}"
    local marketplace_json="$HOME/.agents/plugins/marketplace.json"
    local plugin_dir="$HOME/plugins/$ECU_PLUGIN_NAME"
    local config_file="$codex_home/config.toml"
    local backup
    local stamp

    ecu_validate_marketplace_json "$marketplace_json"

    stamp=$(date +%Y%m%d%H%M%S)
    if [ -d "$plugin_dir" ]; then
        if [ "$keep_backup" -eq 1 ]; then
            backup="$HOME/plugins/${ECU_PLUGIN_NAME}.uninstall-backup-${stamp}"
            if [ -e "$backup" ]; then
                backup="${backup}.$$"
            fi
            mv "$plugin_dir" "$backup"
            echo "Backed up Codex marketplace plugin to: $backup"
        else
            rm -rf "$plugin_dir"
            echo "Removed Codex marketplace plugin"
        fi
    fi

    ecu_remove_marketplace_entry "$marketplace_json"
    ecu_remove_codex_config_section "$config_file"
    echo "Removed Codex marketplace entry and config sections"
}
