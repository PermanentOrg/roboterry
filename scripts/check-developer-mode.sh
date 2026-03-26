#!/usr/bin/env bash
# ------------------------------------------------------------------
# Developer Mode Gate
#
# Blocks write/shell tools unless .local-developer exists in the
# repo root. End users on the web get a clean denial; developers
# who have run "npm run local-developer" pass through.
# ------------------------------------------------------------------

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ -f "$REPO_ROOT/.local-developer" ]; then
  exit 0
fi

cat >&2 << 'MSG'
This tool is not available in Staffbot. File modifications and shell commands are restricted to developers.

If you are setting up this repository for development, run: npm run local-developer
MSG
exit 2
