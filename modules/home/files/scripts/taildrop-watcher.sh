#!/usr/bin/env bash
set -euo pipefail

WATCH_DIR="${1:?Usage: $0 <watch-dir>}"

inotifywait -m -e create --format "%f" "$WATCH_DIR" | while read -r FILE; do
    FULL_PATH="$WATCH_DIR/$FILE"
    (
        ACTION=$(notify-send --wait \
            --action=open="Open file" \
            --action=copy="Copy file" \
            -a "Taildrop" \
            "Received: $FILE")
        case "$ACTION" in
        open)
            xdg-open "$FULL_PATH" >/dev/null 2>&1 &
            ;;
        copy)
            wl-copy <"$FULL_PATH" &
            ;;
        esac
    ) &
done
