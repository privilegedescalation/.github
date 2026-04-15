#!/usr/bin/env bash
set -euo pipefail
#
# Generates a GitHub App installation access token.
# Reads credentials from env vars set in each agent's adapter config:
#   GITHUB_APP_ID_<NAME>   — the GitHub App ID
#   GITHUB_PEM_PATH_<NAME> — path to the private key PEM file
#
# Usage: export GH_TOKEN=$(bash /paperclip/privilegedescalation/agents/get-github-token.sh)

# Auto-detect credentials from env (each agent has exactly one of each)
# Try suffix-based first (GITHUB_APP_ID_<NAME>), then fall back to no-suffix (GITHUB_APP_ID)
APP_ID=$(printenv | grep '^GITHUB_APP_ID_' | head -1 | cut -d= -f2 || true)
if [[ -z "${APP_ID:-}" ]]; then
  APP_ID="${GITHUB_APP_ID:-}"
fi
PEM_PATH=$(printenv | grep '^GITHUB_PEM_PATH_' | head -1 | cut -d= -f2 || true)
if [[ -z "${PEM_PATH:-}" ]]; then
  PEM_PATH="${GITHUB_APP_PEM_FILE:-}"
fi

if [[ -z "${APP_ID:-}" || -z "${PEM_PATH:-}" ]]; then
  echo "Error: GITHUB_APP_ID and GITHUB_APP_PEM_FILE (or GITHUB_APP_ID_<NAME> and GITHUB_PEM_PATH_<NAME>) env vars must be set" >&2
  exit 1
fi

if [[ ! -f "$PEM_PATH" ]]; then
  echo "Error: PEM file not found at $PEM_PATH" >&2
  exit 1
fi

# --- Build JWT (RS256) ---
b64url() { openssl base64 -e -A | tr '+/' '-_' | tr -d '='; }

NOW=$(date +%s)
HEADER=$(printf '{"alg":"RS256","typ":"JWT"}' | b64url)
PAYLOAD=$(printf '{"iat":%d,"exp":%d,"iss":"%s"}' "$((NOW - 60))" "$((NOW + 600))" "$APP_ID" | b64url)
SIGNATURE=$(printf '%s.%s' "$HEADER" "$PAYLOAD" \
  | openssl dgst -sha256 -sign "$PEM_PATH" | b64url)
JWT="${HEADER}.${PAYLOAD}.${SIGNATURE}"

# --- Get installation ID (first installation for this app) ---
INSTALLATION_ID=$(curl -sf \
  -H "Authorization: Bearer $JWT" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/app/installations \
  | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['id'])")

if [[ -z "$INSTALLATION_ID" ]]; then
  echo "Error: Could not get installation ID for app $APP_ID" >&2
  exit 1
fi

# --- Exchange for installation access token ---
TOKEN=$(curl -sf -X POST \
  -H "Authorization: Bearer $JWT" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/app/installations/${INSTALLATION_ID}/access_tokens" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")

if [[ -z "$TOKEN" ]]; then
  echo "Error: Could not get installation access token" >&2
  exit 1
fi

echo "$TOKEN"

