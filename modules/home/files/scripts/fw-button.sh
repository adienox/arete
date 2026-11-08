#!/usr/bin/env bash

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/org-clock-button-pause"

mkdir -p "$(dirname "$STATE_FILE")"

# If state file exists, resume the clock.
if [[ -f "$STATE_FILE" ]]; then
    dms ipc orgClock resume && rm "$STATE_FILE"
    exit 0
fi

clocking=$(dms ipc orgClock dump | jq -r '.clocking')

if [[ "$clocking" == "true" ]]; then
    dms ipc orgClock pause && sleep 0.2 && touch "$STATE_FILE"
else
    spotify &
fi
