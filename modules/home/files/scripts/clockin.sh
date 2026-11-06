#!/usr/bin/env bash

playerctl -a pause

HEADPHONES="WH-1000XM6"
MUSIC_DIR="$HOME/Music/focus/"

SETTINGS_FILE="$HOME/.cache/clockin-settings.json"

mkdir -p "$(dirname "$SETTINGS_FILE")"

gojq -n \
    --arg wallpaper "$(dms ipc wallpaper get)" \
    --argjson dnd "$(dms ipc notifications getDoNotDisturb)" \
    '{
        wallpaper: $wallpaper,
        do_not_disturb: $dnd
    }' > "$SETTINGS_FILE"

dms ipc wallpaper set "$HOME/Pictures/wallpapers/progress.jpg"
dms ipc notifications enableDoNotDisturbIndefinitely

TRACK=$(find "$MUSIC_DIR" -type f \
    \( -iname '*.mp3' -o -iname '*.flac' -o -iname '*.ogg' -o -iname '*.wav' -o -iname '*.m4a' \) |
    shuf -n 1)

DEVICE=$(bluetoothctl devices |
    grep -F "$HEADPHONES" |
    head -n 1 |
    awk '{print $2}')

if [[ -n "$DEVICE" ]] &&
   bluetoothctl info "$DEVICE" | grep -q "Connected: yes"; then

    sonyctl --mode nc

    [[ -n "$TRACK" ]] || exit 0
    mpv --no-video \
        --no-resume-playback \
        --input-ipc-server=/tmp/mpv-clockin.sock \
        "$TRACK"
fi
