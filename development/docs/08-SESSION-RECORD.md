# Session Record

## Repository and fork

- Upstream cloned with full commit graph and tags.
- Upstream URL: `https://github.com/FlopKernel-Series/flop_exynos2100_kernel`
- Fork created through the authenticated GitHub CLI account.
- Fork URL: `https://github.com/Azyrn/flop_exynos2100_kernel`
- Fork visibility verified as public.
- Default branch: `floppy-main`.
- Shallow boundary removed after the final audit.
- Owner `floppy-main` reachable commits: 912,471.
- All reachable commits across fetched refs: 915,515.
- Owner remote branches fetched: 34.
- Owner tags fetched: 6.
- `git fsck --connectivity-only --no-dangling` passed.

The GitHub repository selector screenshot only displayed recent repositories. Searching its field for `flop_exynos2100_kernel` or visiting the direct fork URL reveals it.

## Custom CI commits

| Commit | Purpose |
|---|---|
| `623a2c732` | Add manual Exynos 2100 build workflow |
| `43068613b` | Fix pinned toolchain download and update action versions |
| `b956a4d6e` | Preserve generated config in debug artifact |
| `629ae7243` | Restrict workflow to KernelSU Next only |

Exported copies are in `patches/`.

## GitHub build records

### KernelSU Next reference

- Run ID: `30227478714`
- Result: success
- Job duration: 26 minutes 27 seconds
- Commit: `629ae7243bdabb79f8aea3c6d5e391a74bdb1f5b`
- Artifact label: `ksunext-629ae72`
- Flashable size: 27,861,183 bytes
- Flashable SHA-256: `649600f42564e48148df41c6fcf0c3b6458ba7766ebccdda5e3ab2cab50d0028`
- Local artifact: `builds/github-actions/run-30227478714/`
- GitHub URL: `https://github.com/Azyrn/flop_exynos2100_kernel/actions/runs/30227478714`

The workflow verified the ZIP, both Odin TARs, their LZ4 contents, debug Image, DTB, generated config, log, and exact commit.

The ZIP was copied, not flashed, to:

```text
/sdcard/Download/FloppyKernel/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-20260727-0032.zip
```

The phone-side SHA-256 matched the PC and manifest.

### Earlier Vanilla workflow validation

- Run ID: `30225655003`
- Result: success
- Commit suffix: `4306861`
- Artifacts retained at `builds/github-actions/run-30225655003/`

This earlier run validated the first workflow iterations. It is historical evidence only; the current workflow no longer exposes Vanilla.

## Local audit outputs

An earlier local build/packaging audit is retained under:

```text
builds/local/audit-2026-07-26/
├── out/
├── modules_out/
└── packaging/
```

These are historical generated files, not source and not the current KernelSU Next reference package.

## QEMU result

A generic ARM64 QEMU smoke test reached early kernel boot and then failed at a Samsung secure-monitor call. That is expected for a device-specific Exynos/Samsung kernel running on QEMU’s generic `virt` machine.

QEMU can provide limited evidence that an Image is loadable and reaches early boot. It cannot validate Exynos hardware, Samsung SMC behavior, device trees, modem, camera, GPU, suspend, charging, or real phone boot.

## Installed environment

Required owner tools plus ADB, GitHub CLI, QEMU, DTC, Sparse, ShellCheck, jq, and rsync were installed and verified. Pinned AOSP Clang `r596125` was downloaded, extracted, and used successfully.

## Device identity decision

The connected device showed mixed ROM-spoofed and hardware properties. The physical device evidence identifies an SM-G990E Exynos S21 FE. The user clarified that bootloader lock-looking properties are also spoofed and the bootloader is open. This statement is recorded; automation still avoids all flashing operations.
