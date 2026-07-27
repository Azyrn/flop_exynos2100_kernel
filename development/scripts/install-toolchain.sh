#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

CLANG_REVISION="clang-r596125"
ARCHIVE="$PROJECT_ROOT/toolchains/${CLANG_REVISION}.tar.gz"
ARCHIVE_SHA256="a03f32ee674ee137c1f0cc24f0b005d8db46f1b9b86c35dcbf1dcfd9a924dcd4"
ARCHIVE_URL="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/mirror-goog-main-llvm-toolchain-source/${CLANG_REVISION}.tar.gz"

require_command curl
require_command sha256sum
require_command tar

if [ -x "$TOOLCHAIN_DIR/bin/clang" ]; then
    info "Toolchain already exists: $TOOLCHAIN_DIR"
    "$TOOLCHAIN_DIR/bin/clang" --version | head -n 2
    exit 0
fi

mkdir -p "$PROJECT_ROOT/toolchains"

if [ ! -f "$ARCHIVE" ]; then
    info "Downloading $CLANG_REVISION"
    curl --fail --location --retry 3 --retry-all-errors \
        --output "$ARCHIVE" "$ARCHIVE_URL"
fi

printf '%s  %s\n' "$ARCHIVE_SHA256" "$ARCHIVE" | sha256sum --check -
mkdir -p "$TOOLCHAIN_DIR"
tar -xzf "$ARCHIVE" -C "$TOOLCHAIN_DIR"

touch \
    "$TOOLCHAIN_DIR/bin/aarch64-linux-gnu-elfedit" \
    "$TOOLCHAIN_DIR/bin/arm-linux-gnueabi-elfedit"
chmod +x \
    "$TOOLCHAIN_DIR/bin/aarch64-linux-gnu-elfedit" \
    "$TOOLCHAIN_DIR/bin/arm-linux-gnueabi-elfedit"

"$TOOLCHAIN_DIR/bin/clang" --version | head -n 2
"$TOOLCHAIN_DIR/bin/ld.lld" --version | head -n 1
info "Pinned AOSP Clang installation completed"
