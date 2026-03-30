#!/usr/bin/env bash
# Install Claude Code statusline
# Usage: bash install.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
TARGET="${CLAUDE_DIR}/statusline-command.sh"
SETTINGS="${CLAUDE_DIR}/settings.json"

echo "Installing Claude Code statusline..."

# 1. Check jq dependency
if ! command -v jq &>/dev/null; then
    echo ""
    echo "[!] jq is required but not installed."
    echo "    Install it:"
    echo "      Windows (scoop): scoop install jq"
    echo "      Windows (choco): choco install jq"
    echo "      macOS:           brew install jq"
    echo "      Ubuntu/Debian:   sudo apt install jq"
    echo "      Fedora:          sudo dnf install jq"
    exit 1
fi

# 2. Copy script
mkdir -p "$CLAUDE_DIR"
cp "${SCRIPT_DIR}/statusline-command.sh" "$TARGET"
chmod +x "$TARGET"
echo "[+] Script copied to ${TARGET}"

# 3. Update settings.json
STATUSLINE_BLOCK='{"type":"command","command":"bash ~/.claude/statusline-command.sh"}'

if [ -f "$SETTINGS" ]; then
    if jq -e '.statusLine' "$SETTINGS" &>/dev/null; then
        # Update existing statusLine
        jq --argjson sl "$STATUSLINE_BLOCK" '.statusLine = $sl' "$SETTINGS" > "${SETTINGS}.tmp"
        mv "${SETTINGS}.tmp" "$SETTINGS"
        echo "[+] Updated statusLine in ${SETTINGS}"
    else
        # Add statusLine field
        jq --argjson sl "$STATUSLINE_BLOCK" '. + {statusLine: $sl}' "$SETTINGS" > "${SETTINGS}.tmp"
        mv "${SETTINGS}.tmp" "$SETTINGS"
        echo "[+] Added statusLine to ${SETTINGS}"
    fi
else
    # Create settings.json
    echo "{\"statusLine\": ${STATUSLINE_BLOCK}}" | jq . > "$SETTINGS"
    echo "[+] Created ${SETTINGS}"
fi

echo ""
echo "Done! Restart Claude Code to see the status line."
echo ""
echo "Preview:"
echo "  Line 1: [Model] repo | branch +staged ~modified | RAM/CPU"
echo "  Line 2: [████░░░░░░] 42%  \$0.05  8m5s"
echo ""
echo "To uninstall: remove 'statusLine' from ${SETTINGS} and delete ${TARGET}"
