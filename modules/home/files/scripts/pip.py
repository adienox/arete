#!/usr/bin/env python

import json
import subprocess
import sys

PADDING = 5
SIDE_MONITOR = "eDP-1"


def get_pip_window():
    windows = subprocess.run(
        ["niri", "msg", "-j", "windows"], capture_output=True, text=True
    )

    windows = json.loads(windows.stdout)

    pip_window = None
    for window in windows:
        if window["title"] == "Picture-in-Picture":
            pip_window = window
            break

    return pip_window


def niri_run(command: str) -> None:
    command_list = command.split(" ")
    subprocess.run(command_list)


def move_around(pip_window) -> None:
    """Toggle the PiP between the right and left stacks."""
    output = subprocess.run(
        ["niri", "msg", "-j", "focused-output"], capture_output=True, text=True
    )
    output = json.loads(output.stdout)

    curr_x_pos = int(pip_window["layout"]["tile_pos_in_workspace_view"][0])
    curr_x_size = int(pip_window["layout"]["tile_size"][0])

    monitor_width: int = int(output["logical"]["width"])

    niri_run(
        f"niri msg action move-window-to-monitor --id {pip_window['id']} {output['name']}"
    )

    on_right = (curr_x_pos + curr_x_size / 2) >= monitor_width / 2
    if on_right:
        # Left stack. `move-floating-window -x <px>` is relative to the
        # working area, so PADDING is the margin from its left edge.
        niri_run(
            f"niri msg action move-floating-window --id {pip_window['id']} -x {PADDING} -y {PADDING}"
        )
    else:
        # Right stack. Anchor to the working-area right edge, then offset
        # left by the clamp amount niri applies to the anchor.
        max_off = max(0.0, curr_x_size - min(75.0, max(10.0, curr_x_size / 4.0)))
        niri_run(
            f"niri msg action move-floating-window --id {pip_window['id']} -x 100% -y 0%"
        )
        niri_run(
            f"niri msg action move-floating-window --id {pip_window['id']} "
            f"-x -{max_off + PADDING:.0f} -y {PADDING}"
        )


def move_to_another(pip_window) -> None:
    niri_run(
        f"niri msg action move-window-to-monitor --id {pip_window['id']} {SIDE_MONITOR}"
    )
    niri_run(f"niri msg action toggle-window-floating --id {pip_window['id']}")
    niri_run(f"niri msg action fullscreen-window --id {pip_window['id']}")
    niri_run("niri msg action focus-window-previous")


def main():
    args = sys.argv[1:]
    pip_window = get_pip_window()

    if pip_window:
        if args[0] == "same":
            move_around(pip_window)
        elif args[0] == "side":
            move_to_another(pip_window)


if __name__ == "__main__":
    main()
