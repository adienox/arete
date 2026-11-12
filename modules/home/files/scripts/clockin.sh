#!/usr/bin/env bash

playerctl -a pause

# Exit if resuming from pause
if [[ "$ORG_CLOCK_PAUSED" == "true" ]]; then
    echo '{ "command": ["set_property", "pause", false] }' | socat - /tmp/mpv-clockin.sock
    exit 0
fi

HEADPHONES="WH-1000XM6"
MUSIC_DIR="$HOME/Music/focus/"

SETTINGS_FILE="$HOME/.cache/clockin-settings.json"

TRACK=$(find "$MUSIC_DIR" -type f \
    \( -iname '*.mp3' -o -iname '*.flac' -o -iname '*.ogg' -o -iname '*.wav' -o -iname '*.m4a' \) |
    shuf -n 1)

DEVICE=$(bluetoothctl devices |
    grep -F "$HEADPHONES" |
    head -n 1 |
    awk '{print $2}')

# Only go inside if headphones connected
if [[ -n "$DEVICE" ]] &&
   bluetoothctl info "$DEVICE" | grep -q "Connected: yes"; then

    # Turn on ANC
    setsid -f sonyctl -mode nc

    # Play focus music if exists
    [[ -n "$TRACK" ]] || exit 0
    setsid -f mpv --no-video \
        --no-resume-playback \
        --input-ipc-server=/tmp/mpv-clockin.sock \
        "$TRACK" </dev/null >/dev/null 2>&1
fi

mkdir -p "$(dirname "$SETTINGS_FILE")"

# Backup current wallpaper and dnd setting
gojq -n \
    --arg wallpaper "$(dms ipc wallpaper get)" \
    --argjson dnd "$(dms ipc notifications getDoNotDisturb)" \
    '{
        wallpaper: $wallpaper,
        do_not_disturb: $dnd
    }' > "$SETTINGS_FILE"

# Set focus wallpaper and dnd
dms ipc wallpaper set "$HOME/Pictures/wallpapers/progress.jpg"
dms ipc notifications enableDoNotDisturbIndefinitely
