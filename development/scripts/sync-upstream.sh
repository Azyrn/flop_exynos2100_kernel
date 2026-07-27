#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

mode="${1:-fetch}"

cd "$KERNEL_DIR"
git fetch origin --prune --tags
git fetch fork --prune --tags

info "Upstream commits not yet in your fork branch"
git log --oneline --decorate floppy-main..origin/floppy-main

if [ "$mode" = "fetch" ]; then
    info "Fetch completed; no branch was changed"
    exit 0
fi

[ "$mode" = "--merge" ] || die "Usage: $0 [--merge]"
[ "$(git branch --show-current)" = "floppy-main" ] ||
    die "Switch to floppy-main before merging upstream"
[ -z "$(git status --porcelain)" ] ||
    die "Working tree must be clean before merging upstream"

git merge --no-edit origin/floppy-main
info "Upstream merged locally. Review and test before running: git push fork floppy-main"
