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

echo ""
echo "Roboterry developer mode enabled. Restart your session so the"
echo "SessionStart hook picks up the .local-developer flag."
