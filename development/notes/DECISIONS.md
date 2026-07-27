# Decisions from the Initial Audit

## Build variant

All project automation builds KernelSU Next only. The exact owner command is `./do_build.sh kq`. Vanilla, ReSukiSU, and XXKSU remain in upstream source for compatibility/history but are not workflow choices.

## Toolchain

AOSP Clang `r596125` is pinned because it is the owner’s v1.1.2 release compiler and produced the successful reference build. The owner script can discover a newer AOSP Clang when no toolchain exists, but automatic compiler drift is undesirable for controlled optimization work.

## GitHub Actions

The owner did not provide a workflow in the audited upstream branch. Our workflow uses GitHub-hosted Ubuntu 24.04 and the owner’s unmodified build command, then adds strict package checks and debug retention.

## Device delivery

The automated endpoint is a verified file copy to `/sdcard/Download/FloppyKernel/`. Flashing remains a manual OrangeFox action.

## Workspace layout

`kernel/` and `toolchains/` are siblings because `do_build.sh` sets `WP` to the parent of the kernel tree and `tc.sh` looks for `$WP/toolchains`.

## Evidence preservation

GitHub artifacts are stored by immutable run ID. Old local build trees are labeled as an audit and kept separate from current artifacts. Checksums and generated configurations are retained.

## Hardware validation

Generic QEMU cannot emulate Exynos 2100 Samsung secure-monitor and peripheral behavior. A QEMU early-boot result is only a smoke test; real phone testing is the compatibility authority.
