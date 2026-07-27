#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

branch_name="${1:-}"
[ -n "$branch_name" ] || die "Usage: $0 <branch-name>"
git check-ref-format --branch "$branch_name" >/dev/null ||
    die "Invalid Git branch name: $branch_name"

cd "$KERNEL_DIR"
[ -z "$(git status --porcelain)" ] ||
    die "Commit or stash current changes before creating a branch"

git switch floppy-main
git pull --ff-only fork floppy-main
git switch -c "$branch_name"
info "Created work branch: $branch_name"
