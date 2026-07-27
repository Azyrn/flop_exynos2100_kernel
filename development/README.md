# Exynos 2100 Kernel Development Workspace

This is the version-controlled development kit for the FloppyKernel Exynos 2100 fork. It was organized on 2026-07-27 after cloning and auditing the upstream repository, reproducing the build environment, creating the GitHub fork, adding a KernelSU Next-only workflow, completing successful builds, and copying a verified flashable ZIP to the connected S21 FE.

Start with [docs/00-START-HERE.md](docs/00-START-HERE.md).

In the complete local workspace, this directory is `kernel/development/` and convenience links expose its documentation and scripts from the workspace root. Large build outputs and toolchains are deliberately stored beside `kernel/`, not committed. See [docs/11-LOCAL-ONLY-ASSETS.md](docs/11-LOCAL-ONLY-ASSETS.md).

## Quick start

```bash
export WORKSPACE_ROOT=/path/to/exynos2100-kernel-project
cd "$WORKSPACE_ROOT"
./scripts/doctor.sh
./scripts/new-work-branch.sh optimize/my-first-change
```

From a standalone kernel clone without the convenience links, use `./development/scripts/<script-name>`.

After editing the kernel:

```bash
./scripts/build-local-ksunext.sh clean
```

Or build on GitHub:

```bash
./scripts/trigger-github-build.sh
gh run watch --repo Azyrn/flop_exynos2100_kernel
./scripts/download-github-run.sh
./scripts/copy-flashable-to-phone.sh
```

The phone helper only copies and verifies the ZIP. It does not flash, reboot, enter recovery, use root, or write a partition.

## Folder map

```text
exynos2100-kernel-project/
├── kernel/          Your Git checkout and editable kernel source
├── toolchains/      Pinned AOSP Clang r596125 and its source archive
├── builds/          Historical local outputs and GitHub artifacts
├── scripts/         Safe setup, build, CI, verification, and copy helpers
├── docs/            Complete working documentation
├── patches/         Exported patch series for the custom GitHub workflow
├── references/      Offline owner guides and packaging repositories
├── config/          Reproducibility locks and non-secret examples
├── notes/           Session decisions and facts
└── logs/            Reserved for future test and device logs
```

The Git repository is specifically `kernel/`; run kernel Git commands there. The outer local project folder intentionally is not another Git repository.

## Essential links

- Fork: <https://github.com/Azyrn/flop_exynos2100_kernel>
- Upstream: <https://github.com/FlopKernel-Series/flop_exynos2100_kernel>
- Actions: <https://github.com/Azyrn/flop_exynos2100_kernel/actions>
- Latest successful KernelSU Next run: <https://github.com/Azyrn/flop_exynos2100_kernel/actions/runs/30227478714>
