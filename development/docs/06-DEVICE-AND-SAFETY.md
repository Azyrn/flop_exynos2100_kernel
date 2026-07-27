# Device and Safety

## Connected test device recorded in this session

- Physical hardware: Samsung Galaxy S21 FE Exynos, model `SM-G990E`
- SoC family: Exynos 2100 / s5e9840
- Bootloader build observed: `G990EXXSIGYI3`
- ADB serial: intentionally omitted from the public repository
- ROM: Elite UI
- The ROM spoofs some product properties as `SM-S731B` / `r13s`
- Vendor and boot identity still showed the G990E/r9s base
- The user confirmed the bootloader is actually unlocked and lock-looking properties are spoofed

Do not decide compatibility from one spoofed `ro.product.*` property. Cross-check bootloader, vendor, boot, hardware, and model properties.

## Project delivery rule

Automation may:

- inspect the device;
- create `/sdcard/Download/FloppyKernel/`;
- copy a verified KernelSU Next ZIP;
- list the copied file;
- compare SHA-256.

Automation in this workspace does not:

- reboot;
- enter recovery or download mode;
- run `adb sideload`;
- invoke `su`;
- run `dd`;
- write boot, vendor boot, DTB, or vbmeta;
- flash through OrangeFox, Odin, fastboot, or any root manager.

The user manually flashes the copied ZIP in OrangeFox.

## Owner’s important release notes

- Supports the Exynos 2100 S21 FE, S21, S21+, and S21 Ultra families.
- RAM Plus must be disabled; the owner says enabling it degrades performance.
- KernelSU Next with SUSFS is the recommended root variant.
- The release baseline advertises OneUI and AOSP support across Android 12 through Android 16 QPR2.

## Recovery planning

Before each manual test:

- Keep the last known-good flashable ZIP on the phone or removable storage.
- Keep the current ROM boot/vendor boot recovery method available.
- Record the exact tested commit and ZIP SHA-256.
- Confirm battery level and reliable USB/storage access.
- Change one kernel behavior at a time.
- Do not test unstable undervolting and unrelated scheduler changes together.

## Owner flashing guide

The complete local workspace retains an exact Git snapshot of the guide at:

```text
references/owner-guides/flashing-guide/README.md
```

Public source: <https://gist.github.com/Flopster101/f56ce2d275235428f098a41bdb7a1af1>

It covers recovery and Odin and warns that first-time bootloader/custom flashing can require formatting data. It was written for TWRP and mentions SD card access because encrypted internal storage may not be available there. Your chosen flow is OrangeFox and an internal copied ZIP; verify that OrangeFox can read the destination before relying on it.

## After a manual flash

Capture:

```bash
adb wait-for-device
adb shell uname -a
adb shell cat /proc/version
adb shell dmesg > logs/dmesg-<commit>-first-boot.txt
```

If ADB is unavailable, gather recovery logs and record exactly where boot stopped.
