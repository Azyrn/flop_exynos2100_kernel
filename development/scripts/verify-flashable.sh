#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

require_command sha256sum
require_command unzip

zip_path="${1:-}"
if [ -z "$zip_path" ]; then
    zip_path="$(latest_ksunext_zip)"
fi

[ -n "$zip_path" ] || die "No KernelSU Next flashable ZIP was found"
[ -f "$zip_path" ] || die "ZIP does not exist: $zip_path"

zip_name="$(basename "$zip_path")"
case "$zip_name" in
    *KSUNext*.zip) ;;
    *) die "Refusing a ZIP that is not labeled KSUNext: $zip_name" ;;
esac

info "Testing ZIP structure"
unzip -tq "$zip_path"

actual_sha="$(sha256sum "$zip_path" | awk '{print $1}')"
expected_sha=""
manifest_used=""

while IFS= read -r manifest; do
    candidate="$(
        awk -v filename="$zip_name" \
            '$2 ~ ("/" filename "$") { print $1; exit }' "$manifest"
    )"
    if [ -n "$candidate" ]; then
        expected_sha="$candidate"
        manifest_used="$manifest"
        break
    fi
done < <(find "$BUILDS_DIR" -type f -name SHA256SUMS | sort)

if [ -n "$expected_sha" ]; then
    [ "$actual_sha" = "$expected_sha" ] ||
        die "SHA-256 mismatch: expected $expected_sha, got $actual_sha"
    info "Manifest matches: $manifest_used"
else
    warn "No matching saved manifest was found; archive integrity still passed"
fi

printf 'ZIP: %s\nSHA256: %s\n' "$zip_path" "$actual_sha"
