#!/usr/bin/env sh
FRAME_PARAMS='((title . "emacs-main"))'

if systemctl --user is-active --quiet emacs.service; then
    emacsclient -c -n -F "$FRAME_PARAMS"
else
    systemctl --user start emacs.service
    if emacsclient -c -n -F "$FRAME_PARAMS" --retry 10 --quiet 2>/dev/null; then
        :
    else
        echo "emacs daemon did not start in time" >&2
        exit 1
    fi
fi
