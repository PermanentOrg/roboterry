#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
# Developer Mode Status (SessionStart hook)
#
# Tool use is never restricted. Instead, this hook tells the session
# which set of instructions in CLAUDE.md to follow, based on whether
# the .local-developer flag exists in the repo root. Developers create
# the flag by running "npm run local-developer".
# ------------------------------------------------------------------

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ -f "$REPO_ROOT/.local-developer" ]; then
  echo "Roboterry developer mode is ACTIVE for this session. Follow the \"Developer mode\" instructions in CLAUDE.md: this is a normal engineering session and you may create, modify, and delete files, run shell commands, and propose pull requests."
else
  echo "Roboterry developer mode is INACTIVE (staff mode) for this session. Follow the \"Staff mode\" instructions in CLAUDE.md: you may write generated files (reports, exports, CSVs, scripts) only inside the git-ignored sandbox/ directory, do not modify anything else in the repository, do not run or suggest shell commands, present results conversationally, and treat all data as sensitive."
fi
