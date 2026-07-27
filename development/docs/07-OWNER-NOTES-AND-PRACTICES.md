# Owner Notes and Practices

## Offline owner references

The complete local workspace stores exact Git snapshots under `references/owner-guides/`. They are linked rather than republished inside the kernel repository:

| Subject | Public source |
|---|---|
| v1.1.2 features and project goals | <https://gist.github.com/Flopster101/98db4f7cc60289a7b8356fcee0792d97> |
| Recovery and Odin flashing | <https://gist.github.com/Flopster101/f56ce2d275235428f098a41bdb7a1af1> |
| CPU/GPU undervolt controls and testing | <https://gist.github.com/Flopster101/c52a3f1820fd3caac93fe0eef17cc69a> |
| TMU offsets and throttler protection | <https://gist.github.com/Flopster101/6b044a6d241069e15bc6434fe43ad463> |
| Supported external Wi-Fi chipsets | <https://gist.github.com/Flopster101/2da62d39f86ede20d29d507a13b3f25f> |

Packaging references:

| Folder | Subject |
|---|---|
| `references/upstream-projects/AnyKernel3-exynos2100` | Owner’s `floppy-unity` recovery ZIP template |
| `references/upstream-projects/build-compendium` | Separate repository used for TARs and patchers |

Run `git log` inside any reference folder to see its snapshot history and source remote.

## Project goals stated by the owner

The owner describes FloppyKernel as balancing:

- stability;
- broad Exynos 2100 compatibility;
- responsiveness;
- customization;
- optional performance rather than forcing maximum performance.

The device base is G990E, while the unified target supports r9s, o1s, p3s, and t2s families.

## Baseline feature themes

- Android 12 common-kernel base, Linux 5.4.302 at the current snapshot
- AOSP Clang with ThinLTO and `-O2`
- OneUI and AOSP support
- KernelSU Next and SUSFS
- CPU/GPU undervolting
- MGLRU and memory backports
- ZRAM work and multiple compressors
- optimized EMS/energy-step scheduling
- runtime GPU behavior controls
- thermal offsets and throttler protection
- WireGuard, BBRPlus, FQ
- DroidSpaces, NoMount, mass-storage, USB audio, and wakelock controls
- Android 16 compatibility backports

## Development behavior visible in history

The owner uses dedicated experiment branches for optimizations, thermal changes, MGLRU, ZRAM, GPU spoofing, BPF, and bring-up stages. Mainline history contains explicit reverts of unstable or questionable changes. This suggests the following practice:

1. Develop a focused feature on a branch.
2. Keep backports attributable.
3. Regenerate defconfig in an explicit commit when needed.
4. Test real hardware.
5. Revert regressions instead of hiding them with more tuning.
6. Merge stable work into `floppy-main`.
7. Tag release version commits and publish named artifacts.

## Configuration regeneration

The build system supports regeneration with `r`, but rejects regeneration combined with SU variants:

```bash
cd kernel
./do_build.sh r
git diff -- arch/arm64/configs/exynos2100-unified_defconfig
```

Do not accept large unrelated defconfig churn without explaining it.

## Important documentation drift

Owner guides and release posts are snapshots and can lag the current tree:

- The v1.1.2 feature overview still mentions RKSU, while current upstream migrated RKSU to XXKSU.
- The latest upstream commit stops enabling SUSFS by default in the embedded KernelSU Next source, but this project’s `ksu.config` explicitly enables SUSFS for the `k` build.
- The undervolting gist mentions 3% CPU defaults, while the current unified defconfig recorded on 2026-07-27 sets all CPU clusters and GPU undervolt defaults to 1%.

For a specific build, trust in this order:

1. The exact tested commit.
2. The generated `out/.config` or CI `debug/config`.
3. The current source code and device tree.
4. Release notes for that tag.
5. Older overview guides.

## Tuning notes from the owner

Undervolting controls:

```text
/sys/kernel/exynos_uv/cpucl0_uv_percent
/sys/kernel/exynos_uv/cpucl1_uv_percent
/sys/kernel/exynos_uv/cpucl2_uv_percent
/sys/kernel/exynos_uv/gpu_uv_percent
```

Thermal offset controls:

```text
/proc/exynos_tmu/LITTLE_offset
/proc/exynos_tmu/MID_offset
/proc/exynos_tmu/BIG_offset
/proc/exynos_tmu/G3D_offset
```

Throttler protection:

```text
/sys/kernel/throttlers_protection
```

Read the complete offline guides before using these. Larger positive thermal offsets delay throttling and increase heat. Larger undervolt percentages can cause immediate crashes. Test one domain and one step at a time.
