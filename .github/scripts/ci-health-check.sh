#!/usr/bin/env bash
# ci-health-check.sh — Scan all privilegedescalation repos for CI/CD health
# Run from: /paperclip/privilegedescalation/engineering/hugh
# Requires: GH_TOKEN set (use: export GH_TOKEN=$(bash ./get-github-token.sh))
set -euo pipefail

ORG="privilegedescalation"
PLUGIN_REPOS=(
  headlamp-polaris-plugin
  headlamp-rook-plugin
  headlamp-sealed-secrets-plugin
  headlamp-intel-gpu-plugin
  headlamp-tns-csi-plugin
  headlamp-kube-vip-plugin
)

echo "=== CI/CD Health Check — $(date -u '+%Y-%m-%d %H:%M UTC') ==="
echo ""

failures=0
warnings=0

for repo in "${PLUGIN_REPOS[@]}"; do
  echo "--- ${repo} ---"

  # Get last 5 runs
  runs=$(gh run list --repo "${ORG}/${repo}" --limit 5 --json name,conclusion,headBranch,updatedAt 2>/dev/null || echo "[]")

  if [ "$runs" = "[]" ]; then
    echo "  WARNING: No workflow runs found"
    ((warnings++)) || true
    continue
  fi

  # Use node for JSON parsing (jq not available)
  main_failures=$(echo "$runs" | node -e "
    const d = JSON.parse(require('fs').readFileSync(0,'utf8'));
    const fails = d.filter(r => r.headBranch==='main' && r.conclusion==='failure');
    console.log(fails.length);
  ")
  total=$(echo "$runs" | node -e "
    const d = JSON.parse(require('fs').readFileSync(0,'utf8'));
    console.log(d.length);
  ")

  if [ "$main_failures" -gt 0 ]; then
    echo "  FAIL: ${main_failures} failure(s) in last ${total} runs on main:"
    echo "$runs" | node -e "
      const d = JSON.parse(require('fs').readFileSync(0,'utf8'));
      d.filter(r => r.headBranch==='main' && r.conclusion==='failure')
       .forEach(r => console.log('    - ' + r.name + ' (' + r.updatedAt + ')'));
    "
    ((failures++)) || true
  else
    echo "  OK: All recent runs passing"
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
