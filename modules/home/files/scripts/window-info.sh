#!/usr/bin/env bash
WINDOW_INFO=$(niri msg --json pick-window) || exit 1
APP_ID=$(echo "$WINDOW_INFO" | gojq -r '.app_id')
TITLE=$(echo "$WINDOW_INFO" | gojq -r '.title')

notify-send --app-name="Window Info" "$APP_ID" "$TITLE"
