#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

usage() {
	cat <<EOF
Usage: $0 start LABEL
       $0 finish LABEL

Capture rootless ADB battery, thermal, time-in-state, suspend, and wakeup
snapshots under:
  ${BATTERY_AB_LOG_DIR:-$PROJECT_ROOT/logs/battery-ab}/LABEL/

Use a unique LABEL for each repetition, for example battery-a-active-1.
EOF
}

select_device() {
	mapfile -t connected_devices < <(adb devices | awk '$2 == "device" { print $1 }')

	if [ -n "${ANDROID_SERIAL:-}" ]; then
		printf '%s\n' "${connected_devices[@]}" | grep -Fxq "$ANDROID_SERIAL" ||
			die "ANDROID_SERIAL is not connected: $ANDROID_SERIAL"
		serial="$ANDROID_SERIAL"
	else
		[ "${#connected_devices[@]}" -eq 1 ] ||
			die "Expected exactly one authorized ADB device; found ${#connected_devices[@]}"
		serial="${connected_devices[0]}"
	fi
}

collect_snapshot() {
	local destination="$1"
	local temporary="${destination}.tmp.$$"

	{
		printf 'host.timestamp_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
		printf 'host.git_commit=%s\n' "$(git -C "$KERNEL_DIR" rev-parse HEAD)"
		adb -s "$serial" shell sh <<'DEVICE_SNAPSHOT'
read_metric()
{
	metric_name="$1"
	metric_path="$2"
	metric_fallback="${3:-}"
	metric_value="$(cat "$metric_path" 2>/dev/null | head -n 1)"
	if [ -z "$metric_value" ] && [ -n "$metric_fallback" ] &&
		command -v cmd >/dev/null 2>&1; then
		metric_value="$(cmd battery get "$metric_fallback" 2>/dev/null | head -n 1)"
	fi
	if [ -n "$metric_value" ]; then
		printf 'metric.%s=%s\n' "$metric_name" "$metric_value"
	else
		printf 'metric.%s=unavailable\n' "$metric_name"
	fi
}

dump_file()
{
	dump_path="$1"
	printf '\n--- %s ---\n' "$dump_path"
	if ! cat "$dump_path" 2>/dev/null; then
		printf '[unavailable]\n'
	fi
}

printf 'device.timestamp=%s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')"
printf 'metric.boot_id=%s\n' "$(cat /proc/sys/kernel/random/boot_id)"
printf 'metric.uptime_seconds=%s\n' "$(cut -d' ' -f1 /proc/uptime)"
printf 'device.uname=%s\n' "$(uname -a)"
printf 'device.bootloader=%s\n' "$(getprop ro.boot.bootloader)"
printf 'device.build_fingerprint=%s\n' "$(getprop ro.build.fingerprint)"

read_metric battery_capacity /sys/class/power_supply/battery/capacity level
read_metric charge_counter_uah /sys/class/power_supply/battery/charge_counter counter
read_metric energy_counter /sys/class/power_supply/battery/energy_counter
read_metric battery_temp_raw /sys/class/power_supply/battery/temp temp
read_metric battery_voltage_uv /sys/class/power_supply/battery/voltage_now
read_metric battery_current_ua /sys/class/power_supply/battery/current_now current_now
read_metric battery_status /sys/class/power_supply/battery/status status

printf '\n=== CPU time in state ===\n'
cpu_tis_found=0
for tis_path in /sys/devices/system/cpu/cpufreq/policy*/stats/time_in_state; do
	[ -e "$tis_path" ] || continue
	cpu_tis_found=1
	dump_file "$tis_path"
done
[ "$cpu_tis_found" -eq 1 ] || printf '[unavailable]\n'

printf '\n=== GPU time in state ===\n'
gpu_tis_found=0
for tis_path in \
	/sys/class/misc/mali0/device/time_in_state \
	/sys/devices/platform/*mali*/time_in_state \
	/sys/kernel/gpu/gpu_time_in_state; do
	[ -e "$tis_path" ] || continue
	gpu_tis_found=1
	dump_file "$tis_path"
done
[ "$gpu_tis_found" -eq 1 ] || printf '[unavailable]\n'

printf '\n=== Thermal zones ===\n'
thermal_found=0
for zone_path in /sys/class/thermal/thermal_zone*; do
	[ -d "$zone_path" ] || continue
	thermal_found=1
	printf '%s type=%s temp=%s\n' \
		"$zone_path" \
		"$(cat "$zone_path/type" 2>/dev/null)" \
		"$(cat "$zone_path/temp" 2>/dev/null)"
done
[ "$thermal_found" -eq 1 ] || printf '[unavailable]\n'

printf '\n=== Suspend statistics ===\n'
suspend_found=0
for suspend_path in /sys/power/suspend_stats/*; do
	[ -e "$suspend_path" ] || continue
	suspend_found=1
	dump_file "$suspend_path"
done
[ "$suspend_found" -eq 1 ] || printf '[unavailable]\n'
dump_file /sys/power/wakeup_count

printf '\n=== Wakeup data ===\n'
dump_file /sys/kernel/wakeup_reasons/last_resume_reason
dump_file /sys/kernel/wakeup_reasons/last_suspend_time
dump_file /sys/kernel/debug/wakeup_sources
dump_file /d/wakeup_sources
dump_file /proc/wakelocks

printf '\n=== Android power wake locks and suspend blockers ===\n'
if command -v dumpsys >/dev/null 2>&1; then
	dumpsys power 2>/dev/null |
		sed -n '/Wake Locks:/,/Suspend Blockers:/p'
else
	printf '[unavailable]\n'
fi
DEVICE_SNAPSHOT
	} | tr -d '\r' >"$temporary"

	mv "$temporary" "$destination"
}

metric() {
	local snapshot="$1"
	local name="$2"

	sed -n "s/^metric\\.${name}=//p" "$snapshot" | head -n 1
}

subtract() {
	local lhs="$1"
	local rhs="$2"

	if [[ "$lhs" =~ ^-?[0-9]+([.][0-9]+)?$ ]] &&
		[[ "$rhs" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
		awk -v lhs="$lhs" -v rhs="$rhs" 'BEGIN { printf "%.3f", lhs - rhs }'
	else
		printf 'unavailable'
	fi
}

write_summary() {
	local start_snapshot="$1"
	local finish_snapshot="$2"
	local summary="$3"
	local start_boot finish_boot start_uptime finish_uptime
	local start_charge finish_charge start_capacity finish_capacity
	local start_temp finish_temp

	start_boot="$(metric "$start_snapshot" boot_id)"
	finish_boot="$(metric "$finish_snapshot" boot_id)"
	start_uptime="$(metric "$start_snapshot" uptime_seconds)"
	finish_uptime="$(metric "$finish_snapshot" uptime_seconds)"
	start_charge="$(metric "$start_snapshot" charge_counter_uah)"
	finish_charge="$(metric "$finish_snapshot" charge_counter_uah)"
	start_capacity="$(metric "$start_snapshot" battery_capacity)"
	finish_capacity="$(metric "$finish_snapshot" battery_capacity)"
	start_temp="$(metric "$start_snapshot" battery_temp_raw)"
	finish_temp="$(metric "$finish_snapshot" battery_temp_raw)"

	{
		printf 'label=%s\n' "$label"
		printf 'start_boot_id=%s\n' "$start_boot"
		printf 'finish_boot_id=%s\n' "$finish_boot"
		if [ "$start_boot" = "$finish_boot" ]; then
			printf 'boot_changed=no\n'
			printf 'elapsed_uptime_seconds=%s\n' \
				"$(subtract "$finish_uptime" "$start_uptime")"
		else
			printf 'boot_changed=yes\n'
			printf 'elapsed_uptime_seconds=invalid_after_reboot\n'
		fi
		printf 'start_charge_counter_uah=%s\n' "$start_charge"
		printf 'finish_charge_counter_uah=%s\n' "$finish_charge"
		printf 'charge_used_uah=%s\n' "$(subtract "$start_charge" "$finish_charge")"
		printf 'start_capacity_percent=%s\n' "$start_capacity"
		printf 'finish_capacity_percent=%s\n' "$finish_capacity"
		printf 'capacity_used_percent=%s\n' \
			"$(subtract "$start_capacity" "$finish_capacity")"
		printf 'start_battery_temp_raw=%s\n' "$start_temp"
		printf 'finish_battery_temp_raw=%s\n' "$finish_temp"
		printf 'battery_temp_delta_raw=%s\n' "$(subtract "$finish_temp" "$start_temp")"
		printf 'note=Battery temp raw is normally tenths of a degree C; retain raw snapshots for verification.\n'
	} >"$summary"
}

require_command adb
require_command git

action="${1:-}"
label="${2:-}"

case "$action" in
	start | finish) ;;
	*)
		usage >&2
		exit 2
		;;
esac

[ -n "$label" ] || {
	usage >&2
	exit 2
}

case "$label" in
	*[!A-Za-z0-9._-]*)
		die "LABEL may contain only letters, numbers, dots, underscores, and hyphens"
		;;
esac

select_device

log_root="${BATTERY_AB_LOG_DIR:-$PROJECT_ROOT/logs/battery-ab}"
run_dir="$log_root/$label"
start_snapshot="$run_dir/start.txt"
finish_snapshot="$run_dir/finish.txt"
summary="$run_dir/summary.txt"

case "$action" in
	start)
		[ ! -e "$start_snapshot" ] ||
			die "Start snapshot already exists for LABEL: $label"
		mkdir -p "$run_dir"
		collect_snapshot "$start_snapshot"
		info "Started battery A/B run: $label"
		printf 'Snapshot: %s\n' "$start_snapshot"
		;;
	finish)
		[ -f "$start_snapshot" ] ||
			die "No start snapshot exists for LABEL: $label"
		[ ! -e "$finish_snapshot" ] ||
			die "Finish snapshot already exists for LABEL: $label"
		collect_snapshot "$finish_snapshot"
		write_summary "$start_snapshot" "$finish_snapshot" "$summary"
		if grep -Fxq 'boot_changed=yes' "$summary"; then
			warn "The boot ID changed during this run; uptime delta is invalid"
		fi
		info "Finished battery A/B run: $label"
		cat "$summary"
		printf 'Start snapshot: %s\nFinish snapshot: %s\nSummary: %s\n' \
			"$start_snapshot" "$finish_snapshot" "$summary"
		;;
esac
