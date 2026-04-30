#!/usr/bin/env bash
# ============================================================================
# test-install.sh — Tests for install.sh
# Creates a mock Unity project, runs install.sh, verifies results.
# ============================================================================

MOCK_DIR="/tmp/unity-test-mock-$$"
INSTALL_SCRIPT="${REPO_DIR}/install.sh"

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

# --- Cleanup ---
rm -rf "$MOCK_DIR"
