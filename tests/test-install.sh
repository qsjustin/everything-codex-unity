#!/usr/bin/env bash
# ============================================================================
# test-install.sh — Tests for install.sh
# Creates a mock Unity project, runs install.sh, verifies results.
# ============================================================================

MOCK_DIR="/tmp/unity-test-mock-$$"
INSTALL_SCRIPT="${REPO_DIR}/install.sh"
UNINSTALL_SCRIPT="${REPO_DIR}/uninstall.sh"
UPGRADE_SCRIPT="${REPO_DIR}/upgrade.sh"

# --- Setup: create mock Unity project ---
mkdir -p "${MOCK_DIR}/Assets/Scripts"
mkdir -p "${MOCK_DIR}/ProjectSettings"
mkdir -p "${MOCK_DIR}/Packages"

# Create minimal ProjectVersion.txt
echo "m_EditorVersion: 2022.3.20f1" > "${MOCK_DIR}/ProjectSettings/ProjectVersion.txt"

# Create minimal manifest.json
cat > "${MOCK_DIR}/Packages/manifest.json" << 'MANIFEST'
{
  "dependencies": {
    "com.unity.ugui": "1.0.0"
  }
}
MANIFEST

# --- Test: install.sh exists and is executable ---
assert_file_exists "$INSTALL_SCRIPT" "install.sh exists"
assert_file_executable "$INSTALL_SCRIPT" "install.sh is executable"
assert_file_exists "$UNINSTALL_SCRIPT" "uninstall.sh exists"
assert_file_executable "$UNINSTALL_SCRIPT" "uninstall.sh is executable"
assert_file_exists "$UPGRADE_SCRIPT" "upgrade.sh exists"
assert_file_executable "$UPGRADE_SCRIPT" "upgrade.sh is executable"

# --- Test: upgrade requires a previous install ---
FRESH_PROJECT="${MOCK_DIR}/fresh-project"
mkdir -p "${FRESH_PROJECT}/Assets" "${FRESH_PROJECT}/ProjectSettings"
UPGRADE_EXIT=0
bash "$UPGRADE_SCRIPT" --project-dir "$FRESH_PROJECT" > /dev/null 2>&1 || UPGRADE_EXIT=$?
assert_eq "1" "$UPGRADE_EXIT" "project upgrade rejects missing install"

mkdir -p "${FRESH_PROJECT}/skills/custom"
echo "user skill" > "${FRESH_PROJECT}/skills/custom/SKILL.md"
echo '{"mcpServers":{}}' > "${FRESH_PROJECT}/.mcp.json"
UPGRADE_EXIT=0
bash "$UPGRADE_SCRIPT" --project-dir "$FRESH_PROJECT" > /dev/null 2>&1 || UPGRADE_EXIT=$?
assert_eq "1" "$UPGRADE_EXIT" "project upgrade ignores unrelated local skills and mcp config"
assert_file_exists "${FRESH_PROJECT}/skills/custom/SKILL.md" "project upgrade preserves unrelated local skills"
assert_file_exists "${FRESH_PROJECT}/.mcp.json" "project upgrade preserves unrelated mcp config"

FRESH_HOME="${MOCK_DIR}/fresh-home"
FRESH_CODEX_HOME="${MOCK_DIR}/fresh-codex-home"
UPGRADE_EXIT=0
HOME="$FRESH_HOME" CODEX_HOME="$FRESH_CODEX_HOME" bash "$UPGRADE_SCRIPT" --codex-marketplace > /dev/null 2>&1 || UPGRADE_EXIT=$?
assert_eq "1" "$UPGRADE_EXIT" "marketplace upgrade rejects missing install"

# --- Test: uninstall requires a previous install ---
UNINSTALL_EXIT=0
bash "$UNINSTALL_SCRIPT" --project-dir "$FRESH_PROJECT" > /dev/null 2>&1 || UNINSTALL_EXIT=$?
assert_eq "1" "$UNINSTALL_EXIT" "project uninstall rejects missing install"

UNINSTALL_EXIT=0
bash "$UNINSTALL_SCRIPT" --project-dir "$FRESH_PROJECT" > /dev/null 2>&1 || UNINSTALL_EXIT=$?
assert_eq "1" "$UNINSTALL_EXIT" "project uninstall ignores unrelated local skills and mcp config"
assert_file_exists "${FRESH_PROJECT}/skills/custom/SKILL.md" "project uninstall preserves unrelated local skills"
assert_file_exists "${FRESH_PROJECT}/.mcp.json" "project uninstall preserves unrelated mcp config"

UNINSTALL_EXIT=0
HOME="$FRESH_HOME" CODEX_HOME="$FRESH_CODEX_HOME" bash "$UNINSTALL_SCRIPT" --codex-marketplace > /dev/null 2>&1 || UNINSTALL_EXIT=$?
assert_eq "1" "$UNINSTALL_EXIT" "marketplace uninstall rejects missing install"

# --- Test: install into mock project ---
INSTALL_OUTPUT=$(bash "$INSTALL_SCRIPT" --project-dir "$MOCK_DIR" 2>&1) || true

# Verify Codex plugin directories were created
assert_file_exists "${MOCK_DIR}/.codex-plugin" "install creates .codex-plugin directory"
assert_file_exists "${MOCK_DIR}/skills" "install creates skills directory"
assert_file_exists "${MOCK_DIR}/.codex-legacy" "install creates legacy reference directory"
assert_file_exists "${MOCK_DIR}/.codex-unity" "install creates .codex-unity support directory"

# Verify subdirectories
assert_file_exists "${MOCK_DIR}/.codex-legacy/agents" "install creates legacy agents directory"
assert_file_exists "${MOCK_DIR}/.codex-legacy/commands" "install creates legacy commands directory"
assert_file_exists "${MOCK_DIR}/.codex-legacy/hooks" "install creates legacy hooks directory"
assert_file_exists "${MOCK_DIR}/.codex-legacy/rules" "install creates legacy rules directory"

# Verify hooks are executable
if [ -d "${MOCK_DIR}/.codex-legacy/hooks" ]; then
    HOOK_COUNT=$(find "${MOCK_DIR}/.codex-legacy/hooks" -name "*.sh" -type f | wc -l | tr -d ' ')
    if [ "$HOOK_COUNT" -gt 0 ]; then
        NON_EXEC=$(find "${MOCK_DIR}/.codex-legacy/hooks" -name "*.sh" -type f ! -perm -u+x | wc -l | tr -d ' ')
        assert_eq "0" "$NON_EXEC" "all hook scripts are executable"
    else
        skip_test "no hook scripts found to check permissions"
    fi
else
    skip_test "hooks directory not found"
fi

# Verify plugin and MCP config were copied
assert_file_exists "${MOCK_DIR}/.codex-plugin/plugin.json" "install copies plugin.json"
assert_file_exists "${MOCK_DIR}/.mcp.json" "install copies .mcp.json"

# Verify plugin.json is valid JSON
if [ -f "${MOCK_DIR}/.codex-plugin/plugin.json" ]; then
    JQ_EXIT=0
    jq . "${MOCK_DIR}/.codex-plugin/plugin.json" > /dev/null 2>&1 || JQ_EXIT=$?
    assert_eq "0" "$JQ_EXIT" "installed plugin.json is valid JSON"
fi

# Verify _lib.sh exists
assert_file_exists "${MOCK_DIR}/.codex-legacy/hooks/_lib.sh" "install copies _lib.sh"

# Verify at least one agent exists
AGENT_COUNT=0
if [ -d "${MOCK_DIR}/.codex-legacy/agents" ]; then
    AGENT_COUNT=$(find "${MOCK_DIR}/.codex-legacy/agents" -name "*.md" -type f | wc -l | tr -d ' ')
fi
if [ "$AGENT_COUNT" -gt 0 ]; then
    PASS=$((PASS + 1))
    if [ "$VERBOSE" = "--verbose" ]; then
        echo -e "  ${GREEN}PASS${NC} agents installed (${AGENT_COUNT} found)"
    fi
else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${NC} no agent files found after install"
fi

# Verify at least one command exists
CMD_COUNT=0
if [ -d "${MOCK_DIR}/.codex-legacy/commands" ]; then
    CMD_COUNT=$(find "${MOCK_DIR}/.codex-legacy/commands" -name "*.md" -type f | wc -l | tr -d ' ')
fi
if [ "$CMD_COUNT" -gt 0 ]; then
    PASS=$((PASS + 1))
    if [ "$VERBOSE" = "--verbose" ]; then
        echo -e "  ${GREEN}PASS${NC} commands installed (${CMD_COUNT} found)"
    fi
else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${NC} no command files found after install"
fi

# Verify AGENTS.md was generated
assert_file_exists "${MOCK_DIR}/AGENTS.md" "install generates AGENTS.md"

# --- Test: Codex Desktop marketplace install ---
CODEX_HOME_MOCK="${MOCK_DIR}/codex-home"
HOME_MOCK="${MOCK_DIR}/home"
MARKETPLACE_OUTPUT=$(HOME="$HOME_MOCK" CODEX_HOME="$CODEX_HOME_MOCK" bash "$INSTALL_SCRIPT" --codex-marketplace 2>&1) || true
assert_file_exists "${HOME_MOCK}/.agents/plugins/marketplace.json" "marketplace install writes marketplace.json"
assert_file_exists "${HOME_MOCK}/plugins/everything-codex-unity/.codex-plugin/plugin.json" "marketplace install writes plugin manifest"
assert_file_exists "${HOME_MOCK}/plugins/everything-codex-unity/skills/unity-workflow/SKILL.md" "marketplace install exposes workflow skills"
assert_file_exists "${CODEX_HOME_MOCK}/config.toml" "marketplace install updates Codex config"

if [ -f "${CODEX_HOME_MOCK}/config.toml" ]; then
    CONFIG_TEXT=$(cat "${CODEX_HOME_MOCK}/config.toml")
    assert_contains "$CONFIG_TEXT" "[marketplaces.everything-codex-unity]" "Codex config contains marketplace section"
    assert_contains "$CONFIG_TEXT" "[plugins.\"everything-codex-unity@everything-codex-unity\"]" "Codex config enables plugin"
fi

if [ -f "${HOME_MOCK}/.agents/plugins/marketplace.json" ]; then
    JQ_EXIT=0
    jq . "${HOME_MOCK}/.agents/plugins/marketplace.json" > /dev/null 2>&1 || JQ_EXIT=$?
    assert_eq "0" "$JQ_EXIT" "marketplace.json is valid JSON"
fi

# --- Test: Codex Desktop marketplace upgrade ---
UPGRADE_OUTPUT=$(HOME="$HOME_MOCK" CODEX_HOME="$CODEX_HOME_MOCK" bash "$UPGRADE_SCRIPT" --codex-marketplace 2>&1) || true
assert_file_exists "${HOME_MOCK}/plugins/everything-codex-unity/skills/unity-workflow/SKILL.md" "marketplace upgrade preserves workflow skills"
if [ -d "${HOME_MOCK}/plugins" ]; then
    BACKUP_COUNT=$(find "${HOME_MOCK}/plugins" -maxdepth 1 -name 'everything-codex-unity.backup.*' -type d | wc -l | tr -d ' ')
    if [ "$BACKUP_COUNT" -gt 0 ]; then
        PASS=$((PASS + 1))
        if [ "$VERBOSE" = "--verbose" ]; then
            echo -e "  ${GREEN}PASS${NC} marketplace upgrade creates backup"
        fi
    else
        FAIL=$((FAIL + 1))
        echo -e "  ${RED}FAIL${NC} marketplace upgrade creates backup"
    fi
fi

# --- Test: project and marketplace modes are mutually exclusive ---
MUTEX_EXIT=0
CODEX_HOME="$CODEX_HOME_MOCK" bash "$INSTALL_SCRIPT" --project-dir "$MOCK_DIR" --codex-marketplace > /dev/null 2>&1 || MUTEX_EXIT=$?
assert_eq "1" "$MUTEX_EXIT" "install rejects --project-dir with --codex-marketplace"

MUTEX_EXIT=0
CODEX_HOME="$CODEX_HOME_MOCK" bash "$UPGRADE_SCRIPT" --project-dir "$MOCK_DIR" --codex-marketplace > /dev/null 2>&1 || MUTEX_EXIT=$?
assert_eq "1" "$MUTEX_EXIT" "upgrade rejects --project-dir with --codex-marketplace"

# --- Test: Codex Desktop marketplace uninstall ---
UNINSTALL_OUTPUT=$(HOME="$HOME_MOCK" CODEX_HOME="$CODEX_HOME_MOCK" bash "$UNINSTALL_SCRIPT" --codex-marketplace --no-backup 2>&1) || true
if [ ! -d "${HOME_MOCK}/plugins/everything-codex-unity" ]; then
    PASS=$((PASS + 1))
    if [ "$VERBOSE" = "--verbose" ]; then
        echo -e "  ${GREEN}PASS${NC} marketplace uninstall removes plugin directory"
    fi
else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}FAIL${NC} marketplace uninstall removes plugin directory"
fi

if [ -f "${CODEX_HOME_MOCK}/config.toml" ]; then
    CONFIG_TEXT=$(cat "${CODEX_HOME_MOCK}/config.toml")
    assert_not_contains "$CONFIG_TEXT" "[marketplaces.everything-codex-unity]" "marketplace uninstall removes marketplace config"
    assert_not_contains "$CONFIG_TEXT" "[plugins.\"everything-codex-unity@everything-codex-unity\"]" "marketplace uninstall removes plugin config"
fi

if [ -f "${HOME_MOCK}/.agents/plugins/marketplace.json" ]; then
    ENTRY_COUNT=$(jq '[.plugins[] | select(.name == "everything-codex-unity")] | length' "${HOME_MOCK}/.agents/plugins/marketplace.json")
    assert_eq "0" "$ENTRY_COUNT" "marketplace uninstall removes marketplace entry"
fi

MUTEX_EXIT=0
CODEX_HOME="$CODEX_HOME_MOCK" bash "$UNINSTALL_SCRIPT" --project-dir "$MOCK_DIR" --codex-marketplace > /dev/null 2>&1 || MUTEX_EXIT=$?
assert_eq "1" "$MUTEX_EXIT" "uninstall rejects --project-dir with --codex-marketplace"

# --- Cleanup ---
rm -rf "$MOCK_DIR"
