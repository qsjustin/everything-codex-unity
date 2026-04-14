#!/usr/bin/env bash
# ============================================================================
# notify.sh — STOP HOOK (standard profile)
# Sends a webhook notification when a session completes.
#
# Environment variables:
#   UNITY_NOTIFY_ENABLED=1           — enable notifications (disabled by default)
#   UNITY_NOTIFY_WEBHOOK_URL=<url>   — Discord / Slack / generic webhook URL
#   UNITY_NOTIFY_MIN_DURATION=300    — minimum session seconds to trigger (default: 5 min)
#   UNITY_NOTIFY_FORMAT=auto         — auto | discord | slack (default: auto)
#
# The "auto" format sends both "text" and "content" fields, which makes it
# compatible with both Discord and Slack webhooks out of the box.
# ============================================================================
# Trigger: Stop
# Exit: 0 always (advisory — never blocks)
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="standard"
source "${SCRIPT_DIR}/_lib.sh"

# --- Guard: notifications must be explicitly enabled ---
if [ "${UNITY_NOTIFY_ENABLED:-}" != "1" ]; then
    exit 0
fi

WEBHOOK_URL="${UNITY_NOTIFY_WEBHOOK_URL:-}"
if [ -z "$WEBHOOK_URL" ]; then
    exit 0
fi

# --- Guard: minimum session duration ---
MIN_DURATION="${UNITY_NOTIFY_MIN_DURATION:-300}"
DURATION_SECS=0
if [ -f "${UNITY_HOOK_STATE_DIR}/session-start-time" ]; then
    START_TIME=$(cat "${UNITY_HOOK_STATE_DIR}/session-start-time")
    DURATION_SECS=$(( $(date +%s) - START_TIME ))
fi

if [ "$DURATION_SECS" -lt "$MIN_DURATION" ]; then
    exit 0
fi

# --- Gather session summary ---
EDIT_COUNT=0
if [ -f "$UNITY_EDITS_FILE" ]; then
    EDIT_COUNT=$(sort -u "$UNITY_EDITS_FILE" | wc -l | tr -d ' ')
fi

BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
MINUTES=$((DURATION_SECS / 60))
SECONDS_REMAINDER=$((DURATION_SECS % 60))

MESSAGE="Unity Claude session complete | Branch: ${BRANCH} | Duration: ${MINUTES}m ${SECONDS_REMAINDER}s | Files modified: ${EDIT_COUNT}"

# --- Build payload based on format ---
FORMAT="${UNITY_NOTIFY_FORMAT:-auto}"
case "$FORMAT" in
    discord)
        PAYLOAD=$(jq -nc --arg msg "$MESSAGE" '{content: $msg}')
        ;;
    slack)
        PAYLOAD=$(jq -nc --arg msg "$MESSAGE" '{text: $msg}')
        ;;
    *)
        # Auto: send both fields for maximum compatibility
        PAYLOAD=$(jq -nc --arg msg "$MESSAGE" '{text: $msg, content: $msg}')
        ;;
esac

# --- Send notification (fire and forget) ---
curl -s -o /dev/null -X POST -H "Content-Type: application/json" \
    -d "$PAYLOAD" "$WEBHOOK_URL" 2>/dev/null || true

echo "" >&2
echo "  Notification sent to webhook." >&2

exit 0
