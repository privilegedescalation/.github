#!/usr/bin/env bash
# ci-health-check.sh — Scan all privilegedescalation repos for CI/CD health
# Run from: /paperclip/privilegedescalation/engineering/hugh
# Requires: GH_TOKEN set (use: export GH_TOKEN=$(bash ./get-github-token.sh))
set -euo pipefail

ORG="privilegedescalation"

fetch_plugin_repos() {
  local query='headlamp-[a-z].*'
  gh api repos/privilegedescalation --jq \
    --arg query "$query" \
    '[.[] | select(.name | test($query))] | sort_by(.name) | .[].name'
}

PLUGIN_REPOS=(
  headlamp-polaris-plugin
  headlamp-rook-plugin
  headlamp-sealed-secrets-plugin
  headlamp-intel-gpu-plugin
  headlamp-tns-csi-plugin
  headlamp-kube-vip-plugin
  headlamp-argocd-plugin
  headlamp-plugin-template
)

echo "=== CI/CD Health Check — $(date -u '+%Y-%m-%d %H:%M UTC') ==="
echo ""

failures=0
warnings=0

for repo in "${PLUGIN_REPOS[@]}"; do
  echo "--- ${repo} ---"

  # Get last 10 runs (wider window to catch intermittent failures)
  runs=$(gh run list --repo "${ORG}/${repo}" --limit 10 --json name,conclusion,headBranch,updatedAt 2>/dev/null || echo "[]")

  if [ "$runs" = "[]" ]; then
    echo "  WARNING: No workflow runs found"
    ((warnings++)) || true
    continue
  fi

  # Count CI failures on main — exclude E2E and Release (tracked separately below)
  main_failures=$(echo "$runs" | jq '[.[] | select(.headBranch=="main" and .conclusion=="failure" and .name!="Release" and .name!="E2E Tests")] | length')
  total=$(echo "$runs" | jq 'length')

  if [ "$main_failures" -gt 0 ]; then
    echo "  FAIL: ${main_failures} CI failure(s) in last ${total} runs on main:"
    echo "$runs" | jq -r '.[] | select(.headBranch=="main" and .conclusion=="failure" and .name!="Release" and .name!="E2E Tests") | "    - \(.name) (\(.updatedAt))"'
    ((failures++)) || true
  else
    echo "  OK: CI passing on main"
  fi

  # Surface E2E test failures as warnings (infra blocker: RBAC not yet applied — PRI-494)
  e2e_failures=$(echo "$runs" | jq '[.[] | select(.headBranch=="main" and .name=="E2E Tests" and .conclusion=="failure")] | length')
  if [ "$e2e_failures" -gt 0 ]; then
    echo "  WARN: E2E Tests failing on main (${e2e_failures} failure(s)) — RBAC bootstrap pending (PRI-494)"
    ((warnings++)) || true
  fi

  # Surface Release failures as warnings — with graceful skip in place, these indicate real errors
  release_failures=$(echo "$runs" | jq '[.[] | select(.name=="Release" and .conclusion=="failure")] | length')
  if [ "$release_failures" -gt 0 ]; then
    echo "  WARN: Release workflow has ${release_failures} failure(s) — investigate (PRI-380 secrets still pending)"
    ((warnings++)) || true
  fi

  # Check for action_required — GitHub's "Require approval for first-time contributors" setting
  # blocks workflow runs from GitHub App bot accounts. This is a CI pipeline blocker (see PRI-44).
  action_required_count=$(echo "$runs" | jq '[.[] | select(.conclusion=="action_required")] | length')
  if [ "$action_required_count" -gt 0 ]; then
    echo "  FAIL: ${action_required_count} workflow run(s) with action_required (GitHub App PR approval blocked):"
    echo "$runs" | jq -r '.[] | select(.conclusion=="action_required") | "    - \(.name) on \(.headBranch) (\(.updatedAt))"'
    ((failures++)) || true
  fi

  # Check latest release
  latest_release=$(gh api "repos/${ORG}/${repo}/releases" --jq '.[0].tag_name // "none"' 2>/dev/null || echo "error")
  echo "  Latest release: ${latest_release}"

  echo ""
done

echo "=== Summary ==="
echo "Repos scanned: ${#PLUGIN_REPOS[@]}"
echo "With failures: ${failures}"
echo "With warnings: ${warnings}"

if [ "$failures" -gt 0 ]; then
  exit 1
fi
