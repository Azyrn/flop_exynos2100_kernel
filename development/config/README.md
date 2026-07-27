# Configuration and Locks

- `toolchain.lock`: exact compiler revision, archive URL, project commit, and checksum.
- `known-good-artifacts.sha256`: checksums for the compiler, workflow, reference build, and CI patches.
- `host-packages-arch-2026-07-27.txt`: exact installed package versions at the successful build baseline.
- `workspace.env.example`: optional non-secret script overrides.
- `reference-revisions.md`: exact commits of offline owner/reference snapshots.

Do not put passwords, GitHub tokens, Telegram bot credentials, signing keys, or private device data in this folder.
