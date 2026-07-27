#!/usr/bin/env bash

# shellcheck disable=SC2034
set -euo pipefail

COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
KERNEL_DIR="$(git -C "$COMMON_DIR" rev-parse --show-toplevel)"
PROJECT_ROOT="$(cd "$KERNEL_DIR/.." && pwd -P)"
TOOLCHAIN_DIR="$PROJECT_ROOT/toolchains/aospclang"
BUILDS_DIR="$PROJECT_ROOT/builds"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-Azyrn/flop_exynos2100_kernel}"
GITHUB_BRANCH="${GITHUB_BRANCH:-floppy-main}"
PHONE_DIR="${PHONE_DIR:-/sdcard/Download/FloppyKernel}"

info() {
    printf '[INFO] %s\n' "$*"
}

warn() {
    printf '[WARN] %s\n' "$*" >&2
}

die() {
    printf '[ERROR] %s\n' "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "Required command is missing: $1"
}

latest_ksunext_zip() {
    find "$BUILDS_DIR" -type f -name '*_v*-KSUNext-*.zip' -printf '%T@ %p\n' 2>/dev/null |
        sort -n |
        tail -n 1 |
        cut -d' ' -f2-
}
