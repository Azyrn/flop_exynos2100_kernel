#!/usr/bin/env bash

set -euo pipefail

if [ ! -f /etc/arch-release ]; then
    printf '[ERROR] This installer is for Arch Linux.\n' >&2
    exit 1
fi

sudo pacman -S --needed \
    aarch64-linux-gnu-binutils \
    android-tools \
    base-devel \
    bc \
    brotli \
    ccache \
    cpio \
    curl \
    dtc \
    flex \
    git \
    github-cli \
    jq \
    kmod \
    lz4 \
    python \
    qemu-system-aarch64 \
    rsync \
    shellcheck \
    sparse \
    tar \
    unzip \
    wget \
    xz \
    zip \
    zstd

printf '[INFO] Host packages installed. Run scripts/install-toolchain.sh next if needed.\n'
