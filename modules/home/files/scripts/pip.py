#!/usr/bin/env python

import json
import subprocess
import sys

PADDING = 5
TOP_EXCLUSION = 30
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
    output = subprocess.run(
        ["niri", "msg", "-j", "focused-output"], capture_output=True, text=True
    )
    output = json.loads(output.stdout)

    curr_x_pos, curr_y_pos = (
        int(v) for v in pip_window["layout"]["tile_pos_in_workspace_view"]
    )
    curr_x_size, curr_y_size = (int(v) for v in pip_window["layout"]["tile_size"])

    # monitor
    monitor_height: int = int(output["logical"]["height"])
    monitor_width: int = int(output["logical"]["width"])

    bottom_right = {
        "x": monitor_width - curr_x_size - PADDING,
        "y": monitor_height - curr_y_size - TOP_EXCLUSION - PADDING,
    }

    top_right = {
        "x": monitor_width - curr_x_size - PADDING,
        "y": PADDING,
    }

    # placement
    # weird behavior by niri, if you set placement to (x,y), niri will give back (x,y+top)
    if (curr_x_pos == bottom_right["x"]) and (
        curr_y_pos == bottom_right["y"] + TOP_EXCLUSION
    ):
        next_pos = top_right
    else:
        next_pos = bottom_right

    niri_run(
        f"niri msg action move-window-to-monitor --id {pip_window['id']} {output['name']}"
    )

    niri_run(
        f"niri msg action move-floating-window --id {pip_window['id']} -x {next_pos['x']} -y {next_pos['y']}"
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
