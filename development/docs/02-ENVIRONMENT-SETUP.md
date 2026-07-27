# Environment Setup

## Current PC

The environment verified on 2026-07-27 is:

- Arch Linux, x86_64
- Kernel `7.1.5-zen1-1-zen`
- Git `2.55.0`
- GitHub CLI `2.96.0`
- ADB `36.0.1`
- ccache `4.13.6`
- QEMU AArch64 `11.0.2`
- Approximately 255 GiB free on `/home` at organization time

All required and recommended tools listed below are already installed on this PC.

## Compiler lock

The known-good compiler is:

- AOSP Clang revision: `clang-r596125`
- Clang: `22.0.2`
- LLD: `22.0.2`
- Archive: `toolchains/clang-r596125.tar.gz`
- Archive SHA-256: `a03f32ee674ee137c1f0cc24f0b005d8db46f1b9b86c35dcbf1dcfd9a924dcd4`
- Extracted path: `toolchains/aospclang`

The exact upstream URL and lock are in `config/toolchain.lock`.

Do not casually switch to “latest Clang” while debugging a kernel regression. Change compiler revisions as a separate experiment and record the revision in the build report.

## Required build tools

The owner’s scripts directly require or invoke:

- AOSP Clang/LLD
- GNU Make and standard build utilities
- ARM64 binutils
- `bc`
- `brotli`
- `ccache`
- `cpio`
- `curl`
- `depmod` from kmod
- `flex`
- Git
- gzip
- `lz4`
- Python 3
- `tar`
- `unzip`
- `wget`
- xz
- `zip`

Recommended development and verification tools already installed:

- ADB
- device-tree compiler
- GitHub CLI
- `jq`
- QEMU AArch64
- `rsync`
- ShellCheck
- Sparse
- `zstd`

## Reinstall on Arch Linux

```bash
export WORKSPACE_ROOT=/path/to/exynos2100-kernel-project
cd "$WORKSPACE_ROOT"
./scripts/setup-arch.sh
./scripts/install-toolchain.sh
./scripts/doctor.sh
```

## Reinstall on Ubuntu/Debian

```bash
export WORKSPACE_ROOT=/path/to/exynos2100-kernel-project
cd "$WORKSPACE_ROOT"
./scripts/setup-ubuntu.sh
./scripts/install-toolchain.sh
./scripts/doctor.sh
```

The GitHub runner uses Ubuntu 24.04 and installs:

```text
bc binutils-aarch64-linux-gnu brotli ccache cpio curl flex kmod lz4
python3 tar unzip wget xz-utils zip zstd
```

It separately downloads pinned AOSP Clang and initializes only the required `build/mkbootimg` submodule.

## Disk and performance expectations

- The organized workspace currently occupies roughly 16 GiB.
- A full ThinLTO output tree can exceed 9 GiB.
- Keep at least 20 GiB free before a clean build.
- The verified GitHub clean build took 26 minutes 27 seconds.
- Local time depends on CPU, memory, thermal limits, and ccache state.

## Submodules and network dependencies

Initialize the required submodule after a fresh clone:

```bash
cd kernel
git submodule update --init --depth=1 build/mkbootimg
```

The NetHunter firmware submodule is only needed for the optional `n` build flag.

A normal recovery ZIP build also needs access to:

```text
https://github.com/FlopKernel-Series/AnyKernel3-exynos2100
branch: floppy-unity
```

An offline reference snapshot is stored under `references/upstream-projects/AnyKernel3-exynos2100`, but the owner script normally creates a fresh temporary shallow clone.
