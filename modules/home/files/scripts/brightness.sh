#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") <increment|decrement>" >&2
    exit 1
}

[[ $# -ne 1 ]] && usage

action="$1"
[[ "$action" != "increment" && "$action" != "decrement" ]] && usage

output=$(niri msg -j focused-output | gojq -r ".name")

case "$output" in
    "HDMI-A-1")
        dms ipc call brightness "$action" 5 "ddc:i2c-8"
        dms ipc call brightness "$action" 5 "backlight:ddcci8"
        ;;
    "eDP-1")
        dms ipc call brightness "$action" 5 "backlight:amdgpu_bl1"
        ;;
    *)
        echo "Unknown output: $output" >&2
        exit 1
        ;;
esac
