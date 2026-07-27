# Owner Build Workflow

## What is owner-provided and what is ours

The owner’s `floppy-main` branch did not contain a `.github/workflows` directory when audited on 2026-07-27. The owner’s actual build system is the Bash pipeline stored in the kernel repository.

Our fork adds `.github/workflows/build.yml`. It wraps the owner’s own command and verifies its outputs; it does not replace the build logic.

## Exact call chain

```text
./do_build.sh kq
  └── build/ckbuild.sh kq
      ├── build/lib/log.sh
      ├── build/scripts/tc.sh
      ├── build/scripts/build.sh
      ├── build/scripts/post.sh
      ├── build/scripts/kpm.sh
      ├── build/scripts/images.sh
      ├── build/scripts/pack.sh
      ├── build/scripts/upload.sh
      └── build/scripts/deps.sh
```

`do_build.sh` sets `WP` to the parent of the kernel checkout. That is why `kernel/` and `toolchains/` are siblings in this project.

## Exact KernelSU Next command

```bash
cd "$WORKSPACE_ROOT/kernel"
USE_CCACHE=1 DO_ZIP=1 DO_TAR=1 ./do_build.sh kq
```

Flags are parsed one character at a time:

| Flag | Meaning |
|---|---|
| `k` | KernelSU Next |
| `q` | Quiet console; full output remains in `log.txt` |
| `c` | Clean `out`, module output, and temporary packaging data |
| `R` | Release branding and disable automatic local version suffix |
| `m` | Open `menuconfig` |
| `r` | Regenerate the base defconfig, only without an SU variant |
| `l` | Full LTO; owner warns it is very resource-heavy |
| `n` | Build the optional NetHunter module package |
| `t` | Upload to Telegram if `../chat_ci` and `../bot_token` exist |
| `b` | Upload package and log to bashupload.com |
| `s` | ReSukiSU; intentionally not used in this project workflow |
| `x` | XXKSU; intentionally not used in this project workflow |

The parser checks whether a character appears anywhere in each argument. Pass only the compact documented flag string; do not pass arbitrary words.

Useful supported commands:

```bash
./do_build.sh kq      # KernelSU Next incremental test build
./do_build.sh kcq     # KernelSU Next clean test build
./do_build.sh kRq     # KernelSU Next release-branded build
./do_build.sh kcRq    # KernelSU Next clean release build
./do_build.sh r       # Regenerate base defconfig; no SU flag allowed
```

The project wrappers expose these as:

```bash
./scripts/build-local-ksunext.sh incremental
./scripts/build-local-ksunext.sh clean
./scripts/build-local-ksunext.sh release
./scripts/build-local-ksunext.sh clean-release
```

## Configuration assembly

The defaults are:

- Base defconfig: `arch/arm64/configs/exynos2100-unified_defconfig`
- KernelSU Next fragment: `arch/arm64/configs/ksu.config`
- Always-added fragment for normal builds: `arch/arm64/configs/droidspaces.config`
- Architecture: ARM64
- `PLATFORM_VERSION=12`
- `ANDROID_MAJOR_VERSION=s`
- `TARGET_SOC=universal2100`
- LLVM and LLVM integrated assembler enabled
- ThinLTO from the base configuration
- ccache enabled by default
- `SKIP_FIPS_CRYPTO_INTEGRITY=1`
- `SKIP_EXYNOS_FMP_INTEGRITY=1`

The KernelSU Next fragment selects manual hooks and SUSFS. The verified build configuration in `builds/github-actions/run-30227478714/debug-ksunext-629ae72/debug/config` contains `CONFIG_KSU_NEXT=y`, `CONFIG_KSU=y`, `CONFIG_KSU_MANUAL_HOOK=y`, and the expected SUSFS options.

## Compilation sequence

The owner’s script:

1. Finds or downloads the selected compiler.
2. Installs missing host dependencies using the distro package manager.
3. Merges the base defconfig and fragments.
4. Applies the Floppy local-version string.
5. Builds DTBs.
6. Builds the kernel and modules with all available CPUs.
7. Installs stripped modules into a staging directory.
8. Generates dependency-ordered `modules.load`.
9. Excludes external NetHunter Wi-Fi modules from the normal vendor ramdisk.
10. Creates OneUI and AOSP boot images.
11. Creates the vendor boot image containing the DTB and staged modules.
12. Clones the `floppy-unity` branch of AnyKernel3 for the recovery ZIP.
13. Creates a flashable ZIP and OneUI/AOSP Odin TARs.
14. Optionally uploads the selected package.
15. Cleans temporary packaging and module staging data, but retains the kernel output.

## Image and package behavior

- OneUI `boot.img` uses the built kernel directly.
- The AOSP kernel image is hex-patched from `aosp_mode=0` to `aosp_mode=1`.
- `vendor_boot.img` is built with header version 3, the Exynos 2100 DTB, generated module ramdisk, and `loop.max_part=7`.
- The recovery ZIP comes from `FlopKernel-Series/AnyKernel3-exynos2100`, branch `floppy-unity`.
- TARs contain LZ4-compressed `boot.img` and `vendor_boot.img` for OneUI or AOSP.

Normal outputs:

```text
kernel/build/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-<date>.zip
kernel/build/FloppyOneUI_v1.1.2-KSUNext-SUSFS-exynos2100-<date>.tar
kernel/build/FloppyAOSP_v1.1.2-KSUNext-SUSFS-exynos2100-<date>.tar
kernel/out/arch/arm64/boot/Image
kernel/out/arch/arm64/boot/dts/exynos/exynos2100.dtb
kernel/out/.config
kernel/log.txt
```

## Owner release practice observed

The owner tags version commits and publishes recovery ZIP variants on GitHub Releases. Additional Odin TARs and patchers are placed in the separate build-compendium repository. The build script can also deliver testing builds through Telegram or bashupload.

The owner’s releases historically included Vanilla and multiple root variants. This project intentionally restricts its automated workflow to KernelSU Next only.
