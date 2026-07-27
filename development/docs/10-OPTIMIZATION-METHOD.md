# Optimization Method

## Define the goal before changing code

Choose one primary metric:

- lower idle drain;
- lower screen-on power;
- lower temperature at the same workload;
- higher sustained performance within a temperature limit;
- lower UI latency;
- faster storage;
- less memory pressure;
- improved suspend reliability.

“Faster and better battery” is not a testable single change. State the workload, duration, thermal condition, ROM, battery level, and expected result.

## Establish a baseline

Use the verified KernelSU Next reference build or a new clean build from an unchanged branch. Record:

- Git commit;
- ZIP filename and SHA-256;
- ROM/build fingerprint;
- KernelSU manager version;
- ambient temperature;
- battery level and charging state;
- RAM Plus state;
- thermal/undervolt settings;
- benchmark or workload procedure;
- dmesg errors and reboots.

Run the workload more than once. Phone temperature and background services can dominate small differences.

## Change one subsystem

Good branch scopes:

- `sched/` for EMS and energy-step;
- `mm/` or `zram/` for memory;
- `thermal/` for TMU logic;
- `cpufreq/` for CPU frequency;
- `gpu/` for Mali controls;
- `ufs/` for storage;
- `power/` for suspend and wakeups.

Avoid combining scheduler, undervolt, thermal, and ZRAM changes in one test ZIP. If the phone regresses, you need a small search space.

## Prefer evidence-backed patches

For an upstream/backport candidate:

1. Identify the original repository and commit.
2. Check kernel version assumptions.
3. Read follow-up fixes and reverts.
4. Cherry-pick with provenance.
5. Resolve conflicts minimally.
6. Compile all affected configurations where practical.
7. Test the real hardware behavior.

The owner’s history includes reverts of unstable energy-step, networking, ZRAM, and configuration experiments. Treat reverts as useful evidence.

## Configuration changes

Use fragments for variant-specific settings and the unified defconfig for device-wide defaults. Always inspect the generated `.config`:

```bash
rg 'CONFIG_NAME' kernel/out/.config
```

Save the config with every serious test build. GitHub CI already does this.

## Performance safety

- Keep thermal protection active while first testing functional changes.
- Do not mask thermal throttling to make a benchmark look faster.
- Increase undervolting gradually and one domain at a time.
- A crash is a failed stability test even if the benchmark score improved.
- Test deep sleep, charging, camera, calls, Wi-Fi, Bluetooth, and suspend after core power changes.
- Watch for delayed failures, not only first boot.

## Suggested acceptance gate

A change should reach `floppy-main` only when:

1. `git diff --check` passes.
2. The patch has a clear rationale and provenance.
3. A clean KernelSU Next build passes.
4. Packaging and SHA verification pass.
5. The device boots repeatedly.
6. Core hardware tests pass.
7. The target metric improves beyond normal run-to-run variation.
8. Thermals and battery do not regress outside the intended tradeoff.
9. No new persistent dmesg errors appear.
10. A known-good rollback ZIP remains available.
