#!/usr/bin/env bash
set -euo pipefail

# Thin entry point for `nix run github:adienox/arete#install`.
#
# Nix caches a flake reference (github:...) for a while, so the app script
# itself can be several hours stale even after you push. To avoid running
# stale installer logic, this bootstrap only clones the repository and then
# execs the freshly cloned scripts/install.sh, which does the real work.
#
# Usage: nix run github:adienox/arete#install <hostname> [role]
# Env:   REPO_URL  overrides the clone source

REPO_URL="${REPO_URL:-https://github.com/adienox/arete}"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
echo "==> fetching arete into ${WORK}"
git clone --depth 1 "${REPO_URL}" "${WORK}"
echo "    revision: $(git -C "${WORK}" rev-parse --short HEAD)"

# Tell install.sh to reuse this clone instead of fetching its own copy.
export ARETE_WORK="${WORK}"
exec "${WORK}/scripts/install.sh" "$@"
