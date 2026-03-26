#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
# Staffbot MCP Server Startup
#
# Validates required environment variables, handles SSH key setup,
# and starts the dbhub MCP server.
# ------------------------------------------------------------------

errors=()

# --- Validate database connection variables ---
for var in DB_TYPE DB_HOST DB_PORT DB_NAME DB_USER DB_PASSWORD; do
  if [ -z "${!var:-}" ]; then
    errors+=("$var")
  fi
done

if [ ${#errors[@]} -gt 0 ]; then
  echo "ERROR: Missing required database environment variables:" >&2
  for var in "${errors[@]}"; do
    echo "  - $var" >&2
  done
  echo "" >&2
  echo "Local: copy .env.template to .env and fill in the values." >&2
  echo "Web:   add these in your project's environment variable settings." >&2
  echo "" >&2
  echo "Ask your IT contact for the correct values." >&2
  exit 1
fi

# --- Validate SSH tunnel variables (if tunneling is configured) ---
if [ -n "${SSH_HOST:-}" ] || [ -n "${SSH_PRIVATE_KEY_BASE64:-}" ]; then
  ssh_errors=()

  [ -z "${SSH_HOST:-}" ] && ssh_errors+=("SSH_HOST")
  [ -z "${SSH_USER:-}" ] && ssh_errors+=("SSH_USER")

  if [ -z "${SSH_KEY:-}" ] && [ -z "${SSH_PRIVATE_KEY_BASE64:-}" ]; then
    ssh_errors+=("SSH_KEY (local) or SSH_PRIVATE_KEY_BASE64 (web)")
  fi

  if [ ${#ssh_errors[@]} -gt 0 ]; then
    echo "ERROR: SSH tunnel is partially configured but missing:" >&2
    for var in "${ssh_errors[@]}"; do
      echo "  - $var" >&2
    done
    echo "" >&2
    echo "See .env.template for the full list of SSH variables." >&2
    exit 1
  fi
fi

# --- Decode base64 SSH key to a temp file (web use) ---
if [ -n "${SSH_PRIVATE_KEY_BASE64:-}" ]; then
  SSH_KEY_FILE=$(mktemp)
  case "$(uname -s)" in
    Darwin*) b64_decode_flag="-D" ;;
    *)       b64_decode_flag="-d" ;;
  esac
  printf '%s' "$SSH_PRIVATE_KEY_BASE64" | base64 "$b64_decode_flag" > "$SSH_KEY_FILE"
  chmod 600 "$SSH_KEY_FILE"
  trap 'rm -f "$SSH_KEY_FILE"' EXIT
  export SSH_KEY="$SSH_KEY_FILE"
fi

npx @bytebase/dbhub --transport stdio
