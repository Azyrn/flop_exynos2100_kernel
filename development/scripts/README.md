# Helper Scripts

| Script | Purpose | Mutates external state? |
|---|---|---|
| `doctor.sh` | Check commands, compiler, Git, GitHub CLI, disk, and ADB | No |
| `setup-arch.sh` | Install required/recommended Arch packages | Installs packages after sudo authentication |
| `setup-ubuntu.sh` | Install required/recommended Debian/Ubuntu packages | Installs packages after sudo authentication |
| `install-toolchain.sh` | Verify/extract/download pinned AOSP Clang | Creates toolchain files only when missing |
| `new-work-branch.sh` | Update from the fork and create a work branch | Creates a local Git branch |
| `sync-upstream.sh` | Fetch owner history and show new commits | Fetch-only by default |
| `sync-upstream.sh --merge` | Merge owner main into fork main locally | Creates a local merge; never pushes |
| `build-local-ksunext.sh` | Run the owner’s KernelSU Next build | Creates local build outputs |
| `trigger-github-build.sh` | Dispatch the fork’s KSU Next-only workflow | Starts a GitHub Actions run |
| `download-github-run.sh` | Download a successful run by immutable ID | Creates a new local run folder |
| `verify-flashable.sh` | Test ZIP and compare SHA-256 manifest | No |
| `copy-flashable-to-phone.sh` | Verify and copy the ZIP to phone storage | Creates one storage folder/file; never flashes |

All helpers derive the project path from their own location. The whole workspace can therefore be moved later without editing absolute paths inside the scripts.

Defaults are in `scripts/lib/common.sh`. Override non-secret runtime values with environment variables documented in `config/workspace.env.example`.
