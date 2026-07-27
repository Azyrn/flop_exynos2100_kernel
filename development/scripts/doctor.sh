#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

required=(
    aarch64-linux-gnu-ld
    bc
    brotli
    ccache
    cpio
    curl
    depmod
    flex
    git
    gzip
    lz4
    make
    python3
    tar
    unzip
    wget
    zip
)

optional=(
    adb
    dtc
    gh
    jq
    qemu-system-aarch64
    rsync
    shellcheck
    sparse
    zstd
)

missing=0
info "Project root: $PROJECT_ROOT"

for command_name in "${required[@]}"; do
    if command -v "$command_name" >/dev/null 2>&1; then
        printf '  [OK]   %s\n' "$command_name"
    else
        printf '  [MISS] %s\n' "$command_name"
        missing=1
    fi
done

for command_name in "${optional[@]}"; do
    if command -v "$command_name" >/dev/null 2>&1; then
        printf '  [OK]   %s (recommended)\n' "$command_name"
    else
        printf '  [----] %s (optional)\n' "$command_name"
    fi
done

[ -d "$KERNEL_DIR/.git" ] || die "Kernel Git checkout is missing: $KERNEL_DIR"
[ -x "$TOOLCHAIN_DIR/bin/clang" ] || die "Pinned AOSP Clang is missing: $TOOLCHAIN_DIR"

info "Compiler"
"$TOOLCHAIN_DIR/bin/clang" --version | head -n 2
"$TOOLCHAIN_DIR/bin/ld.lld" --version | head -n 1

info "Git"
git -C "$KERNEL_DIR" status --short --branch
git -C "$KERNEL_DIR" remote -v

if command -v gh >/dev/null 2>&1; then
    info "GitHub CLI"
    gh auth status || warn "GitHub CLI is installed but authentication needs attention"
fi

if command -v adb >/dev/null 2>&1; then
    info "ADB devices"
    adb devices -l
fi

df -h "$PROJECT_ROOT"

if [ "$missing" -ne 0 ]; then
    die "One or more required commands are missing. Run the setup script for this OS."
fi

info "Workspace doctor completed successfully"
