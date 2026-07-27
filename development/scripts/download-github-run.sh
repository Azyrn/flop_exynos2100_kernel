#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

require_command gh
gh auth status >/dev/null

run_id="${1:-}"

if [ -z "$run_id" ]; then
    run_id="$(
        gh run list \
            --repo "$GITHUB_REPOSITORY" \
            --workflow build.yml \
            --status success \
            --limit 1 \
            --json databaseId \
            --jq '.[0].databaseId'
    )"
fi

[[ "$run_id" =~ ^[0-9]+$ ]] || die "No valid successful run ID was found"

destination="$BUILDS_DIR/github-actions/run-$run_id"

if [ -e "$destination" ]; then
    die "Destination already exists; refusing to overwrite: $destination"
fi

mkdir -p "$destination"
gh run download "$run_id" \
    --repo "$GITHUB_REPOSITORY" \
    --dir "$destination"

info "Downloaded run $run_id to $destination"
find "$destination" -type f -printf '  %s bytes  %p\n' | sort -n
