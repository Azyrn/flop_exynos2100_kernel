# Build, Test, and Deliver

## Daily development loop

### 1. Update your base

```bash
export WORKSPACE_ROOT=/path/to/exynos2100-kernel-project
cd "$WORKSPACE_ROOT"
./scripts/sync-upstream.sh
```

This fetches and reports upstream changes without modifying your branch. See [05-GIT-AND-UPSTREAM.md](05-GIT-AND-UPSTREAM.md) before merging.

### 2. Create one experiment branch

```bash
./scripts/new-work-branch.sh optimize/example-change
```

### 3. Edit and review

```bash
cd kernel
git status
git diff --check
git diff
```

For patches, use the kernel’s own checker:

```bash
git diff | ./scripts/checkpatch.pl --no-tree -
```

After committing:

```bash
./scripts/checkpatch.pl --strict -g HEAD
```

Not every warning in this old vendor tree should be mechanically “fixed.” Review whether a warning belongs to your change.

### 4. Local KernelSU Next build

For a quick iteration:

```bash
cd ..
./scripts/build-local-ksunext.sh incremental
```

Before phone testing or publishing:

```bash
./scripts/build-local-ksunext.sh clean
```

The full log is `kernel/log.txt`.

### 5. GitHub build

Push the tested branch or merge it into your fork’s `floppy-main`. The current workflow dispatches only from the branch you select and always runs KernelSU Next.

```bash
cd kernel
git push -u fork HEAD
```

For the standard `floppy-main` workflow:

```bash
cd ..
./scripts/trigger-github-build.sh
gh run watch --repo Azyrn/flop_exynos2100_kernel
```

To dispatch a feature branch that already contains the workflow:

```bash
GITHUB_BRANCH=optimize/example-change ./scripts/trigger-github-build.sh
```

The workflow:

1. Uses Ubuntu 24.04.
2. Checks out the selected commit.
3. Installs build dependencies.
4. Downloads AOSP Clang `r596125`.
5. Runs `./do_build.sh kq`.
6. Requires exactly one flashable ZIP and both Odin TARs.
7. Runs `unzip -tq` on the recovery ZIP.
8. Lists both TARs and tests their embedded LZ4 images.
9. Stores the kernel Image, DTB, exact `.config`, log, commit, and `SHA256SUMS`.
10. Uploads separate flashable, Odin, and debug artifacts for 30 days.

### 6. Download and verify

Download the latest successful run:

```bash
./scripts/download-github-run.sh
./scripts/verify-flashable.sh
```

Or specify an exact run and ZIP:

```bash
./scripts/download-github-run.sh 30227478714
./scripts/verify-flashable.sh /absolute/path/to/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-date.zip
```

The downloader refuses to overwrite an existing run folder. The verifier rejects ZIP names that do not contain `KSUNext`, tests the archive, computes SHA-256, and compares it with a saved workflow manifest when available.

### 7. Copy to the phone

Connect exactly one authorized ADB device:

```bash
adb devices -l
./scripts/copy-flashable-to-phone.sh
```

Default destination:

```text
/sdcard/Download/FloppyKernel/
```

The script verifies the archive first, performs `adb push`, and compares the PC and phone SHA-256 values. It does not flash.

## What counts as a successful test

Use increasing levels of confidence:

1. Source and configuration review.
2. Clean compile succeeds.
3. ZIP/TAR structural validation succeeds.
4. Artifact hash matches the workflow manifest.
5. ZIP copies to the phone with a matching hash.
6. Manual OrangeFox flash succeeds.
7. Device boots to Android.
8. ADB works and the intended kernel version/root variant is visible.
9. Core hardware and suspend/resume tests pass.
10. Battery, thermal, performance, and stability tests pass over time.

Do not label level 1–5 as “device-tested.”

## Suggested post-boot evidence

After the user manually flashes and boots:

```bash
adb shell uname -a
adb shell cat /proc/version
adb shell dmesg | tail -n 300
adb shell getprop ro.boot.bootloader
adb shell getprop ro.boot.em.model
```

For KernelSU Next, confirm through the manager application and retain its version information with the test record.
