#!/usr/bin/env sh

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/org-clock-button-pause"

# Exit if resuming from pause
if [[ "$ORG_CLOCK_PAUSED" == "true" ]]; then
    echo '{ "command": ["set_property", "pause", true] }' | socat - /tmp/mpv-clockin.sock
    touch "$STATE_FILE"
    exit 0
fi

rm -f "$STATE_FILE"

SETTINGS_FILE="$HOME/.cache/clockin-settings.json"

# Stop mpv focus music
echo '{"command":["stop"]}' |
    socat - /tmp/mpv-clockin.sock 2>/dev/null || true

# restore previous settings
WALLPAPER=$(gojq -r '.wallpaper' "$SETTINGS_FILE")
DND=$(gojq -r '.do_not_disturb' "$SETTINGS_FILE")

dms ipc wallpaper set "$WALLPAPER"

if [[ "$DND" == "false" ]]; then
    dms ipc notifications disableDoNotDisturb
fi

ALLOWED_WIFI_NETWORKS=("Force" "Anchor")

CURRENT_SSID=$(nmcli -g GENERAL.CONNECTION device show | head -n1)

# get back to ambient mode
for allowed in "${ALLOWED_WIFI_NETWORKS[@]}"; do
    if [[ "$CURRENT_SSID" == "$allowed" ]]; then
        sonyctl --ambient 10 2>/dev/null || true
        break
    fi
done
