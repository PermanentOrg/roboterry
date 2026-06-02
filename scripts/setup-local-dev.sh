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
