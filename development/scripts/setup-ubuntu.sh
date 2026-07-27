#!/usr/bin/env bash

set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
    printf '[ERROR] This installer requires apt-get.\n' >&2
    exit 1
fi

sudo apt-get update
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    adb \
    bc \
    binutils-aarch64-linux-gnu \
    brotli \
    build-essential \
    ccache \
    cpio \
    curl \
    device-tree-compiler \
    flex \
    gh \
    git \
    jq \
    kmod \
    lz4 \
    python3 \
    qemu-system-arm \
    rsync \
    shellcheck \
    sparse \
    tar \
    unzip \
    wget \
    xz-utils \
    zip \
    zstd

printf '[INFO] Host packages installed. Run scripts/install-toolchain.sh next if needed.\n'
