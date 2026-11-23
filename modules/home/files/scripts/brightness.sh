#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") <increment|decrement>" >&2
    exit 1
}

[[ $# -ne 1 ]] && usage

action="$1"
[[ "$action" != "increment" && "$action" != "decrement" ]] && usage

step=5

output=$(niri msg -j focused-output | gojq -r '.name')
if [[ -z "$output" || "$output" == "null" ]]; then
    echo "No focused output" >&2
    exit 1
fi

# Brightness devices known to the running DMS daemon (includes DDC/I2C monitors).
# Using the daemon's cached state avoids re-probing DDC on every keypress.
mapfile -t available < <(dms ipc call brightness list 2>/dev/null | awk '$1 ~ /^[a-z]+:/ { print $1 }')

has_device() {
    local needle="$1" dev
    for dev in "${available[@]}"; do
        [[ "$dev" == "$needle" ]] && return 0
    done
    return 1
}

devices=()
add_device() {
    local dev="$1" existing
    has_device "$dev" || return 0
    for existing in "${devices[@]}"; do
        [[ "$existing" == "$dev" ]] && return 0
    done
    devices+=("$dev")
}

# Map the focused niri output to its DRM connector(s).
mapfile -t connectors < <(ls -d /sys/class/drm/card*-"$output" 2>/dev/null || true)

for connector in "${connectors[@]}"; do
    connector_real=$(readlink -f "$connector")

    # Internal panels expose a backlight whose device is bound to the connector.
    for bl in /sys/class/backlight/*; do
        [[ -e "$bl/device" ]] || continue
        if [[ "$(readlink -f "$bl/device")" == "$connector_real" ]]; then
            add_device "backlight:$(basename "$bl")"
        fi
    done

    # External monitors are driven over DDC/I2C. Depending on the driver the
    # usable bus is either the connector's child i2c adapter or its ddc link.
    for i2c in "$connector"/i2c-* "$connector"/ddc; do
        [[ -e "$i2c" ]] || continue
        bus=$(basename "$(readlink -f "$i2c")") # i2c-N
        add_device "ddc:$bus"
        # The ddcci kernel module may also expose a backlight for the same bus.
        add_device "backlight:ddcci${bus#i2c-}"
    done
done

# Fallback for internal panels whose backlight isn't linked to the connector.
if [[ ${#devices[@]} -eq 0 && "$output" =~ ^(eDP|LVDS|DSI) ]]; then
    for dev in "${available[@]}"; do
        if [[ "$dev" == backlight:* && "$dev" != *kbd* ]]; then
            add_device "$dev"
            break
        fi
    done
fi

if [[ ${#devices[@]} -eq 0 ]]; then
    echo "No DMS brightness device found for output: $output" >&2
    exit 1
fi

for dev in "${devices[@]}"; do
    dms ipc call brightness "$action" "$step" "$dev"
done
