#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

require_command gh
gh auth status >/dev/null

info "Triggering KernelSU Next-only workflow"
gh workflow run build.yml \
    --repo "$GITHUB_REPOSITORY" \
    --ref "$GITHUB_BRANCH"

info "Workflow dispatched"
printf 'Watch runs: https://github.com/%s/actions\n' "$GITHUB_REPOSITORY"
printf 'CLI: gh run list --repo %q --workflow build.yml --limit 5\n' "$GITHUB_REPOSITORY"
