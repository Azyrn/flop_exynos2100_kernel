# Local-Only Assets

The reusable documentation, scripts, patches, and small configuration records are committed under `development/`. The following resources intentionally remain outside the Git repository in the complete local workspace.

## Toolchain

```text
../toolchains/aospclang/
../toolchains/clang-r596125.tar.gz
```

The archive is approximately 1.1 GiB and exceeds GitHub’s 100 MB per-file limit. The extracted toolchain is approximately 3.5 GiB. Its exact revision, URL, and checksum are committed in `development/config/toolchain.lock`.

## Generated builds and artifacts

```text
../builds/local/
../builds/github-actions/
```

The local build tree is approximately 9.2 GiB and contains individual files larger than GitHub permits, including `vmlinux` and `vmlinux.o`. Generated binaries do not belong in source history. GitHub Actions artifacts remain downloadable from their run pages while retained.

The reference KernelSU Next run is:

<https://github.com/Azyrn/flop_exynos2100_kernel/actions/runs/30227478714>

Checksums and immutable run/commit identifiers are committed in `development/config/known-good-artifacts.sha256` and `development/docs/08-SESSION-RECORD.md`.

## Owner guide and packaging snapshots

```text
../references/owner-guides/
../references/upstream-projects/
```

These are separate Git repositories and public Gists. They remain separate to preserve their original history and ownership instead of vendoring them into the kernel repository. Exact revisions and source URLs are committed in `development/config/reference-revisions.md`.

## Private host information

The public development kit does not contain:

- sudo passwords;
- GitHub tokens;
- Telegram credentials;
- the exact connected-device serial;
- signing keys;
- recovery credentials.

`development/config/workspace.env.example` uses placeholders for host-specific values.

## Restoring the local layout

After cloning the kernel to `<workspace>/kernel`:

```bash
mkdir -p <workspace>/toolchains <workspace>/builds <workspace>/references
<workspace>/kernel/development/scripts/install-toolchain.sh
```

The owner’s build script and project helpers both expect the toolchain at `<workspace>/toolchains/aospclang`.
