# Repository Map

## Top-level build entry points

| Path | Purpose |
|---|---|
| `kernel/do_build.sh` | Thin wrapper; sets the workspace parent and calls `build/ckbuild.sh` |
| `kernel/build/ckbuild.sh` | Main FloppyKernel build orchestrator and flag parser |
| `kernel/build_kernel.sh` | Older/simple Samsung make path; not the packaging workflow used here |
| `kernel/Makefile` | Linux kernel build system and version |
| `kernel/.github/workflows/build.yml` | Our KernelSU Next-only GitHub Actions wrapper |
| `kernel/.gitmodules` | mkbootimg and optional NetHunter firmware submodules |

## Build helper scripts

| Path | Purpose |
|---|---|
| `build/scripts/tc.sh` | Toolchain selection/download and compiler environment |
| `build/scripts/deps.sh` | Missing package detection for Ubuntu, Arch, and Gentoo |
| `build/scripts/build.sh` | Defconfig fragments, compilation, LTO, modules installation |
| `build/scripts/post.sh` | Module staging and generated `modules.load` |
| `build/scripts/images.sh` | DTB, OneUI/AOSP boot images, and vendor boot |
| `build/scripts/pack.sh` | AnyKernel recovery ZIP and Odin TAR creation |
| `build/scripts/upload.sh` | Optional Telegram and bashupload delivery |
| `build/scripts/kpm.sh` | Suki-only KPM patch path; not used for KernelSU Next |
| `build/scripts/gen_modules_load.sh` | Dependency ordering and NetHunter exclusions |
| `build/scripts/qemu_virt_smoketest.sh` | Generic QEMU launcher; limited for Samsung hardware kernels |

## Configuration

| Path | Purpose |
|---|---|
| `arch/arm64/configs/exynos2100-unified_defconfig` | Main unified Exynos 2100 configuration |
| `arch/arm64/configs/ksu.config` | KernelSU Next, manual hook, and SUSFS fragment |
| `arch/arm64/configs/droidspaces.config` | Namespace/network options always added in normal builds |
| `arch/arm64/configs/sukisu.config` | Other variant; not used by project automation |
| `arch/arm64/configs/xxksu.config` | Other variant; not used by project automation |
| `drivers/su_variants.Kconfig` | Mutually exclusive SU variant and hook choices |

The generated truth for a build is `out/.config`, not only the fragments. The CI debug artifact preserves this file as `debug/config`.

## Exynos 2100 and Samsung areas

| Area | Typical paths |
|---|---|
| Device trees | `arch/arm64/boot/dts/exynos/` |
| SoC support | `drivers/soc/samsung/` |
| CPU frequency | `drivers/cpufreq/` |
| Samsung thermal | `drivers/thermal/samsung/exynos_tmu_v2.c` |
| Mali GPU | `drivers/gpu/arm/` |
| Scheduler/EMS | `kernel/sched/ems/` |
| Memory and ZRAM | `mm/`, `drivers/block/zram/` |
| Storage/UFS | `drivers/scsi/ufs/` |
| Samsung power/QoS | `drivers/soc/samsung/exynos_pm_qos.c`, `kernel/power/qos.c` |
| Device modules | `drivers/`, `sound/`, `net/` |

## Optimization controls discovered

- CPU/GPU undervolt implementation: `drivers/soc/samsung/cal-if/fvmap.c`
- Undervolt Kconfig/defaults: `drivers/soc/samsung/Kconfig` and the unified defconfig
- Energy-step governor: `kernel/sched/ems/energy_step.c`
- Thermal offsets: `drivers/thermal/samsung/exynos_tmu_v2.c`
- Throttler protection sysfs: `kernel/ksysfs.c`
- Frequency-control gating: `include/linux/binfmts.h`
- GPU QoS protection: `drivers/gpu/arm/exynos/frontend/gpex_qos.c`

## KernelSU Next and SUSFS

| Path | Purpose |
|---|---|
| `drivers/kernelsu/` | KernelSU Next imported source |
| `arch/arm64/configs/ksu.config` | Selected project root variant |
| `fs/susfs.c` | SUSFS filesystem-side implementation |
| `include/linux/susfs*.h` | SUSFS interfaces |
| `drivers/su_variants.Kconfig` | Variant choice |

Do not edit SukiSU or XXKSU when the intended result is KernelSU Next unless a shared interface truly requires it.

## Packaging inputs

- `build/boot/ramdisk`: boot image ramdisk input
- `build/vboot/`: vendor ramdisk files
- `build/bin/magiskboot`: image hex-patching helper
- `build/dtb/mkdtboimg.py`: DTB image construction
- `build/mkbootimg/mkbootimg.py`: Android boot image construction
- `references/upstream-projects/AnyKernel3-exynos2100`: offline inspection snapshot of the flash ZIP template

## Generated outputs

Never treat these as hand-edited source:

- `kernel/out/`
- `kernel/modules_out/`
- `kernel/build/tmp/`
- `kernel/build/images/`
- `kernel/build/Floppy_*.zip`
- `kernel/build/Floppy*.tar`
- `kernel/log.txt`
- `builds/local/`
- `builds/github-actions/`
