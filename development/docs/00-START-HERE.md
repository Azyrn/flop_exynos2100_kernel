# Start Here

## Current known-good state

- Kernel: Linux 5.4.302, FloppyKernel v1.1.2 lineage.
- Editable branch: `kernel/floppy-main`.
- Fork remote: `fork` → `Azyrn/flop_exynos2100_kernel`.
- Owner remote: `origin` → `FlopKernel-Series/flop_exynos2100_kernel`.
- Fork is four CI commits ahead of the owner baseline recorded on 2026-07-27.
- GitHub workflow builds only KernelSU Next with SUSFS by executing `./do_build.sh kq`.
- Compiler: AOSP Clang 22.0.2, revision `r596125`.
- Successful reference run: GitHub Actions `30227478714`, commit `629ae7243bdabb79f8aea3c6d5e391a74bdb1f5b`.
- Verified reference ZIP SHA-256: `649600f42564e48148df41c6fcf0c3b6458ba7766ebccdda5e3ab2cab50d0028`.

## First checks

```bash
export WORKSPACE_ROOT=/path/to/exynos2100-kernel-project
cd "$WORKSPACE_ROOT"
./scripts/doctor.sh
```

The doctor checks required commands, the pinned compiler, Git remotes, GitHub CLI authentication, free disk space, and ADB connectivity.

## Begin a change

Always isolate an experiment:

```bash
./scripts/new-work-branch.sh optimize/short-description
cd kernel
```

Make one measurable change, inspect it, and commit it:

```bash
git diff --check
git diff
git status
git add <exact-files>
git commit -s -m "subsystem: describe the change"
```

Then use [03-BUILD-TEST-DELIVER.md](03-BUILD-TEST-DELIVER.md).

## Read in this order

1. [01-OWNER-BUILD-WORKFLOW.md](01-OWNER-BUILD-WORKFLOW.md)
2. [02-ENVIRONMENT-SETUP.md](02-ENVIRONMENT-SETUP.md)
3. [03-BUILD-TEST-DELIVER.md](03-BUILD-TEST-DELIVER.md)
4. [04-REPOSITORY-MAP.md](04-REPOSITORY-MAP.md)
5. [05-GIT-AND-UPSTREAM.md](05-GIT-AND-UPSTREAM.md)
6. [06-DEVICE-AND-SAFETY.md](06-DEVICE-AND-SAFETY.md)
7. [07-OWNER-NOTES-AND-PRACTICES.md](07-OWNER-NOTES-AND-PRACTICES.md)
8. [08-SESSION-RECORD.md](08-SESSION-RECORD.md)
9. [09-TROUBLESHOOTING.md](09-TROUBLESHOOTING.md)
10. [10-OPTIMIZATION-METHOD.md](10-OPTIMIZATION-METHOD.md)
11. [11-LOCAL-ONLY-ASSETS.md](11-LOCAL-ONLY-ASSETS.md)

## Important warning

A successful compiler run proves that the source compiled and the packages passed structural checks. It does not prove that every camera, modem, GPU, suspend, charging, thermal, or root path works on real hardware. Device testing is still required, with a known-good ZIP and recovery plan available.
