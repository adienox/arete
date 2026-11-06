#!/usr/bin/env sh

echo '{"command":["stop"]}' |
    socat - /tmp/mpv-clockin.sock 2>/dev/null || true

SETTINGS_FILE="$HOME/.cache/clockin-settings.json"

WALLPAPER=$(gojq -r '.wallpaper' "$SETTINGS_FILE")
DND=$(gojq -r '.do_not_disturb' "$SETTINGS_FILE")

dms ipc wallpaper set "$WALLPAPER"

if [[ "$DND" == "false" ]]; then
    dms ipc notifications disableDoNotDisturb
fi

ALLOWED_WIFI_NETWORKS=("Force" "Anchor")

CURRENT_SSID=$(nmcli -g GENERAL.CONNECTION device show | head -n1)

for allowed in "${ALLOWED_WIFI_NETWORKS[@]}"; do
    if [[ "$CURRENT_SSID" == "$allowed" ]]; then
        sonyctl --ambient 10 2>/dev/null || true
        break
    fi
done
