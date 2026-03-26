#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# --- Developer mode flag ---
FLAG_FILE="$REPO_ROOT/.local-developer"
if [ -f "$FLAG_FILE" ]; then
  echo "✓ .local-developer flag already exists, skipping."
else
  touch "$FLAG_FILE"
  echo "✓ Created .local-developer flag file."
fi

# --- Claude Code local developer permissions ---
LOCAL_SETTINGS="$REPO_ROOT/.claude/settings.local.json"
if [ -f "$LOCAL_SETTINGS" ]; then
  echo "✓ .claude/settings.local.json already exists, skipping."
else
  mkdir -p "$REPO_ROOT/.claude"
  cat > "$LOCAL_SETTINGS" << 'SETTINGS'
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash",
      "Write",
      "Edit",
      "Agent",
      "mcp__db"
    ],
    "deny": []
  }
}
SETTINGS
  echo "✓ Created .claude/settings.local.json with developer permissions."
fi

# --- Environment file ---
ENV_FILE="$REPO_ROOT/.env"
if [ -f "$ENV_FILE" ]; then
  echo "✓ .env already exists, skipping."
else
  cp "$REPO_ROOT/.env.template" "$ENV_FILE"
  echo "✓ Created .env from template. Fill in the values before starting Claude Code."
fi

echo ""
echo "Local developer setup complete."
