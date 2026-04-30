#!/usr/bin/env bash
# ============================================================================
# test-cross-validation.sh — Cross-validates Codex plugin files.
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TESTS_RUN=0; TESTS_PASSED=0; TESTS_FAILED=0
assert_eq() { TESTS_RUN=$((TESTS_RUN+1)); if [ "$1" = "$2" ]; then TESTS_PASSED=$((TESTS_PASSED+1)); echo "PASS: $3"; else TESTS_FAILED=$((TESTS_FAILED+1)); echo "FAIL: $3 (expected '$2', got '$1')"; fi; }

echo ""
echo "=== Cross-Validation Tests ==="
echo ""

echo "--- Test: plugin manifest exists and is valid JSON ---"
PLUGIN_JSON="$PROJECT_ROOT/.codex-plugin/plugin.json"
assert_eq "$(test -f "$PLUGIN_JSON" && echo 1 || echo 0)" "1" "plugin.json exists"
if [ -f "$PLUGIN_JSON" ]; then
    jq . "$PLUGIN_JSON" >/dev/null 2>&1
    assert_eq "$?" "0" "plugin.json is valid JSON"
fi

echo ""
echo "--- Test: plugin manifest paths exist ---"
MISSING=0
for path in $(jq -r '.skills?, .mcpServers? | select(. != null)' "$PLUGIN_JSON"); do
    clean="${path#./}"
    if [ ! -e "$PROJECT_ROOT/$clean" ]; then
        echo "  MISSING: $path"
        MISSING=$((MISSING + 1))
    fi
done
assert_eq "$MISSING" "0" "plugin manifest paths exist"

echo ""
echo "--- Test: MCP config is valid JSON ---"
jq . "$PROJECT_ROOT/.mcp.json" >/dev/null 2>&1
assert_eq "$?" "0" ".mcp.json is valid JSON"

echo ""
echo "--- Test: legacy hook scripts are executable ---"
NON_EXEC=0
for hook_file in "$PROJECT_ROOT/.codex-legacy/hooks/"*.sh; do
    if [ ! -x "$hook_file" ]; then
        echo "  NOT EXECUTABLE: $(basename "$hook_file")"
        NON_EXEC=$((NON_EXEC + 1))
    fi
done
assert_eq "$NON_EXEC" "0" "all legacy hook scripts are executable"

echo ""
echo "--- Test: workflow skills exist for migrated commands ---"
WORKFLOW_COUNT=$(find "$PROJECT_ROOT/skills/workflows" -name SKILL.md -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$WORKFLOW_COUNT" -gt 0 ]; then
    assert_eq "1" "1" "workflow skills exist ($WORKFLOW_COUNT found)"
else
    assert_eq "0" "1" "workflow skills exist"
fi

echo ""
echo "=== Cross-Validation: ${TESTS_PASSED} passed, ${TESTS_FAILED} failed ==="
echo ""

exit "$TESTS_FAILED"
