#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

require_command adb
require_command sha256sum

zip_path="${1:-}"
if [ -z "$zip_path" ]; then
    zip_path="$(latest_ksunext_zip)"
fi

[ -n "$zip_path" ] || die "No KernelSU Next ZIP was found"
"$SCRIPT_DIR/verify-flashable.sh" "$zip_path"

mapfile -t connected_devices < <(adb devices | awk '$2 == "device" { print $1 }')

if [ -n "${ANDROID_SERIAL:-}" ]; then
    serial="$ANDROID_SERIAL"
    printf '%s\n' "${connected_devices[@]}" | grep -Fxq "$serial" ||
        die "ANDROID_SERIAL is not connected: $serial"
else
    [ "${#connected_devices[@]}" -eq 1 ] ||
        die "Expected exactly one authorized ADB device; found ${#connected_devices[@]}"
    serial="${connected_devices[0]}"
fi

zip_name="$(basename "$zip_path")"
remote_path="$PHONE_DIR/$zip_name"
local_sha="$(sha256sum "$zip_path" | awk '{print $1}')"

info "Creating phone folder: $PHONE_DIR"
adb -s "$serial" shell mkdir -p "$PHONE_DIR"

info "Copying ZIP only; no flash or reboot command is used"
adb -s "$serial" push "$zip_path" "$remote_path"

remote_sha="$(
    adb -s "$serial" shell sha256sum "$remote_path" |
        tr -d '\r' |
        awk '{print $1}'
)"

[ "$local_sha" = "$remote_sha" ] ||
    die "Phone copy checksum mismatch: local=$local_sha remote=$remote_sha"

adb -s "$serial" shell ls -l "$remote_path"
printf 'Phone path: %s\nSHA256: %s\n' "$remote_path" "$remote_sha"
info "Copy verified. The ZIP was not flashed."
