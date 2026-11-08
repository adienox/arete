#!/usr/bin/env bash

set -euo pipefail

# Never start qutebrowser if it isn't already running.
pgrep -u "$(id -u)" -f '(^|/)\.?qutebrowser(-wrapped)?( |$)' >/dev/null || exit 0

(
    # Prevent multiple watchers if Matugen invokes the hook repeatedly.
    exec 9>"${XDG_RUNTIME_DIR}/matugen-qutebrowser-reload.lock"
    flock -n 9 || exit 0

    niri msg --json event-stream |
    jq --unbuffered -r '
        foreach inputs as $event
        ({};
            if $event.WindowsChanged then
                reduce $event.WindowsChanged.windows[] as $w
                    (. ; .[($w.id | tostring)] = $w)
            elif $event.WindowOpenedOrChanged then
                .[($event.WindowOpenedOrChanged.window.id | tostring)] =
                    $event.WindowOpenedOrChanged.window
            elif $event.WindowClosed then
                del(.[$event.WindowClosed.id | tostring])
            else .
            end;

            if $event.WindowFocusChanged then
                ($event.WindowFocusChanged.id // null) as $id
                | if $id == null then ""
                  else .[($id | tostring)].app_id // ""
                  end
            elif $event.WindowsChanged then
                ([.[] | select(.is_focused)] | first | .app_id // "")
            else ""
            end
        )
        | select(test("qutebrowser"; "i"))
    ' |
    while IFS= read -r app_id; do
        pgrep -u "$(id -u)" -f '(^|/)\.?qutebrowser(-wrapped)?( |$)' >/dev/null || break

        qutebrowser ':config-source'
        break
    done
) </dev/null >/dev/null 2>&1 &

exit 0
