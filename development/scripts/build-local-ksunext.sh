#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

mode="${1:-incremental}"

case "$mode" in
    incremental)
        owner_flags="kq"
        ;;
    clean)
        owner_flags="kcq"
        ;;
    release)
        owner_flags="kRq"
        ;;
    clean-release)
        owner_flags="kcRq"
        ;;
    *)
        die "Usage: $0 [incremental|clean|release|clean-release]"
        ;;
esac

"$SCRIPT_DIR/doctor.sh"

info "Building KernelSU Next with owner flags: $owner_flags"
info "Kernel: $KERNEL_DIR"
info "Log: $KERNEL_DIR/log.txt"

cd "$KERNEL_DIR"
export WP="$PROJECT_ROOT"
export CLANG_TYPE="aosp"
export USE_CCACHE="1"
export DO_ZIP="1"
export DO_TAR="1"

./do_build.sh "$owner_flags"

info "Generated packages"
find "$KERNEL_DIR/build" -maxdepth 1 -type f \
    \( -name 'Floppy_*KSUNext*.zip' -o -name 'Floppy*KSUNext*.tar' \) \
    -printf '  %p\n' |
    sort
