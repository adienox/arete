#!/usr/bin/env bash

session=$(loginctl show-session 2 | awk -F= '/^LockedHint=/ {print $2}')

if [ $session = "yes" ]; then
    ./unlock.sh
else
    niri msg action screenshot
fi
