# Troubleshooting

## Run the doctor first

```bash
export WORKSPACE_ROOT=/path/to/exynos2100-kernel-project
cd "$WORKSPACE_ROOT"
./scripts/doctor.sh
```

## Compiler missing or wrong

Expected first version line:

```text
Android (...) clang version 22.0.2 ... based on r596125
```

Repair:

```bash
./scripts/install-toolchain.sh
```

Do not mix another Clang directory into `PATH` while comparing against the reference build.

## mkbootimg missing

```bash
cd kernel
git submodule update --init --depth=1 build/mkbootimg
```

## Build fails immediately on a missing command

Use the OS setup script in `scripts/`. The owner’s dependency detector checks command names and may not cover every command needed later in packaging, which is why the project installers include a broader known-good set.

## Build appears quiet

The `q` flag sends normal make output to:

```text
kernel/log.txt
```

Inspect errors:

```bash
rg -n 'error:|undefined reference|No such file|FAILED' kernel/log.txt
tail -n 200 kernel/log.txt
```

Kernel source trees can emit warnings even on successful builds. Compare new warnings with the known-good build before treating every warning as a regression.

## AnyKernel ZIP is skipped

The packaging step shallow-clones:

```text
https://github.com/FlopKernel-Series/AnyKernel3-exynos2100
branch floppy-unity
```

Check network access and ensure `kernel/build/tmp/AK3-2100` is not an incomplete non-Git directory. The script retries five times, then continues without the recovery ZIP.

## No artifact appears in GitHub

```bash
gh run list --repo Azyrn/flop_exynos2100_kernel --workflow build.yml --limit 10
gh run view <run-id> --repo Azyrn/flop_exynos2100_kernel --log-failed
```

Failed runs retain `log.txt` and `out/.config` when those files exist.

## Downloader refuses an existing folder

This is intentional to preserve evidence. Use the existing folder, specify another run ID, or manually move the old run folder to an archive location. Do not merge files from different run IDs.

## ADB reports more than one device

Set the intended serial:

```bash
export ANDROID_SERIAL=replace-with-your-adb-serial
./scripts/copy-flashable-to-phone.sh
```

The copy helper still verifies that this serial is connected.

## Phone SHA-256 command unavailable

The connected phone supported `sha256sum` during this session. If a different recovery/ROM lacks it, copy the ZIP while Android is booted or install a trusted userspace providing SHA-256. Do not skip verification for a test build.

## QEMU panics in Samsung SMC code

This is a platform mismatch, not proof that the phone build is broken. Use QEMU only as an early-boot smoke test. Real hardware validation is required.

## Git pull/push goes to the wrong repository

```bash
cd kernel
git remote -v
git branch -vv
```

`floppy-main` should track `fork/floppy-main`. `origin` is the owner and should not receive your pushes.
