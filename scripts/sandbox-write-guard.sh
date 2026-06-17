#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
# Sandbox Write Guard (PreToolUse hook)
#
# Mechanically enforces the staff-mode boundary described in CLAUDE.md.
# Developer mode (the .local-developer flag exists) is unrestricted.
# In staff mode this hook:
#   - allows Write/Edit/NotebookEdit only inside the sandbox/ directory
#   - denies Bash (staff sessions never run shell commands)
#   - denies Agent (subagents could write outside the guarded path)
#
# A denied tool call exits 2; Claude Code feeds the stderr message back
# to the model as the denial reason. This is a backstop for the CLAUDE.md
# instructions, not a replacement for them.
# ------------------------------------------------------------------

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Developer mode: no restrictions.
if [ -f "$REPO_ROOT/.local-developer" ]; then
  exit 0
fi

deny() {
  printf '%s\n' "$1" >&2
  exit 2
}

PAYLOAD="$(cat)"
TOOL="$(printf '%s' "$PAYLOAD" | jq -r '.tool_name // empty')"

case "$TOOL" in
  Bash)
    deny "Staff mode: shell commands are disabled. Ask Terry to do this another way, or have a developer run it."
    ;;
  Agent)
    deny "Staff mode: subagents are disabled because they can write outside the sandbox/ workspace."
    ;;
  Write | Edit | NotebookEdit)
    TARGET="$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')"
    [ -n "$TARGET" ] || deny "Staff mode: could not determine the target path, so the write was blocked."

    INSIDE="$(REPO_ROOT="$REPO_ROOT" TARGET="$TARGET" node -e '
      const fs = require("fs");
      const path = require("path");
      const sandbox = fs.realpathSync(path.join(process.env.REPO_ROOT, "sandbox"));
      const target = path.resolve(process.env.REPO_ROOT, process.env.TARGET);
      // Resolve symlinks on the longest existing ancestor of the target,
      // so a new file under a real sandbox path still resolves correctly.
      let ancestor = target;
      while (!fs.existsSync(ancestor) && ancestor !== path.dirname(ancestor)) {
        ancestor = path.dirname(ancestor);
      }
      const resolved = path.resolve(fs.realpathSync(ancestor), path.relative(ancestor, target));
      const rel = path.relative(sandbox, resolved);
      const inside = rel !== "" && !rel.startsWith("..") && !path.isAbsolute(rel);
      process.stdout.write(inside ? "yes" : "no");
    ')"

    [ "$INSIDE" = "yes" ] || deny "Staff mode: files can only be written inside the sandbox/ directory. Blocked path: $TARGET"
    ;;
esac

exit 0
