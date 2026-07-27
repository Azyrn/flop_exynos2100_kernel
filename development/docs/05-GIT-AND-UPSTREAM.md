# Git and Upstream

## Remotes

```text
fork    https://github.com/Azyrn/flop_exynos2100_kernel.git
origin  https://github.com/FlopKernel-Series/flop_exynos2100_kernel.git
```

`origin` is read as the owner’s upstream. Push your work to `fork`, not `origin`.

## Local branches

- `floppy-main` tracks `fork/floppy-main` and contains the KernelSU Next-only CI commits.
- `upstream-floppy-main` tracks `origin/floppy-main` and is a clean owner baseline reference.

At the recorded baseline:

```text
origin/floppy-main: 16065f0cc7b382a6257d5347d62f9fa7a36ea5f4
fork/floppy-main:   629ae7243bdabb79f8aea3c6d5e391a74bdb1f5b
```

The repository is no longer shallow. It contains the complete reachable commit graph for every owner branch and tag fetched on 2026-07-27. The clone retains Git’s `blob:none` partial-clone filter, so an old file blob that has never been inspected may be fetched lazily, but commit history, ancestry, log, and blame context are not cut off by a shallow boundary.

## Inspect owner updates

```bash
export WORKSPACE_ROOT=/path/to/exynos2100-kernel-project
cd "$WORKSPACE_ROOT"
./scripts/sync-upstream.sh
```

This only fetches and lists new owner commits.

Review them:

```bash
cd kernel
git log --oneline --decorate floppy-main..origin/floppy-main
git diff --stat floppy-main...origin/floppy-main
```

## Merge owner updates

First ensure your work is committed and tested:

```bash
cd "$WORKSPACE_ROOT"
./scripts/sync-upstream.sh --merge
```

Resolve conflicts deliberately, especially in:

- build scripts
- defconfig and configuration fragments
- KernelSU/SUSFS imports
- `.github/workflows/build.yml`

Then rebuild and push:

```bash
./scripts/build-local-ksunext.sh clean
cd kernel
git push fork floppy-main
```

Never force-push the shared `floppy-main` unless you have a specific recovery reason and understand which commits will disappear.

## Work branches

Use subsystem-oriented names similar to the owner’s experimental branches:

```text
optimize/zram-latency
thermal/tmu-offset-test
sched/energy-step-tuning
fix/suspend-regression
bringup/oneui-update
```

Create one with:

```bash
./scripts/new-work-branch.sh optimize/zram-latency
```

## Commit practice

The owner’s history commonly:

- splits config regeneration from implementation;
- uses subsystem prefixes such as `zram:`, `mm:`, `configs:`, or `FLOPPY:`;
- preserves upstream authorship when importing backports;
- records reverts when an optimization proves unstable;
- experiments on named branches before merging to `floppy-main`;
- uses version bump commits and tags for releases.

For new commits:

```bash
git commit -s -m "subsystem: concise imperative summary"
```

If backporting, retain the original commit identity and provenance. Prefer `git cherry-pick -x <commit>` where appropriate. Review `kernel/README.md`, `Documentation/process/submitting-patches.rst`, and `Documentation/CodingStyle`.

## CI patch backup

The four custom CI commits are also exported in `patches/`. They apply in order on top of owner baseline `16065f0cc`.
