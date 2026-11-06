#!/bin/sh
# Reload a running qutebrowser; never start a new one.
if pgrep -u "$(id -u)" -f '(^|/)\.?qutebrowser(-wrapped)?( |$)' >/dev/null; then
    qutebrowser ':config-source'
fi
exit 0
