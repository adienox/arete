#!/usr/bin/env python3
"""niri-pip-stack: keep Picture-in-Picture windows in tidy corner columns.

- New PiP windows are stacked top-to-bottom in the corner column; when a
  column is full a new column starts next to it.
- Drag a PiP window across the middle of the screen to move it between the
  right and left stacks (it snaps to that side's edge). Drag within a side
  to pick the column and vertical slot. Once you let go (position stable
  for SETTLE seconds) everything re-packs.
- When you switch workspaces, PiP windows follow you onto the active
  workspace of their monitor so they stay visible.
- Closing a window re-flows the rest.

Pair with a window rule that makes PiP windows float.

Talks to niri over the IPC socket directly (no `niri msg` subprocesses):
spawning a process per query was ~15 ms and the piped event stream was
block-buffered, which made snapping feel slow. The socket is ~0.05 ms.

Placement note: niri's `SetFixed` coordinates are relative to the working
area (output minus struts/bars), while `tile_pos_in_workspace_view` is
absolute. The window rule already puts new PiPs at the working-area
top-right corner, so we learn that corner from the first new window and
only ever issue a *relative* move (`AdjustFixed`) to reach each slot. That
means a bar on any edge is respected, and a window already in place is not
moved at all (no wiggle).
"""
import json
import os
import queue
import re
import socket
import sys
import threading
import time

# ---- config ---------------------------------------------------------------
APP_ID_RE = re.compile(r"^(firefox|librewolf|zen|chromium|google-chrome)")
TITLE_RE = re.compile(r"^Picture[- ]in[- ][Pp]icture$")
CORNER = "top-right"     # default side + vertical alignment of both stacks
MARGIN = 5               # px from the screen/working-area edge
GAP = 12                 # px between windows
TOP_RESERVED = 0         # extra px to keep clear at the top
BOTTOM_RESERVED = 0      # extra px to keep clear at the bottom
SETTLE = 0.06            # seconds of quiet before a drop is committed
DRAG_THRESHOLD = 6       # px a window must be off its slot to count as dragged
# ---------------------------------------------------------------------------

EVENTS_THAT_MATTER = (
    "WindowsChanged", "WindowOpenedOrChanged", "WindowClosed",
    "WindowLayoutsChanged", "WorkspaceActivated",
)

TOP = CORNER.startswith("top")
DEFAULT_SIDE = "right" if CORNER.endswith("right") else "left"

# persistent state
columns = {}    # output name -> [{"side": "right"|"left", "wins": [id, ...]}, ...]
ref = {}        # output name -> {"right": abs x of corner column, "top": abs y, ...}
expected = {}   # window id -> last observed absolute (x, y), or None while settling
sizes = {}      # window id -> (w, h) last seen
placed = {}     # window id -> last anchor fallback signature


# ---- niri IPC ---------------------------------------------------------------

class Niri:
    """Minimal newline-delimited JSON client for the niri IPC socket."""

    def __init__(self):
        path = os.environ.get("NIRI_SOCKET")
        if not path:
            raise RuntimeError("NIRI_SOCKET is not set")
        self.path = path
        self.sock = None
        self.f = None
        self.lock = threading.Lock()

    def close(self):
        for close in (getattr(self.f, "close", None), getattr(self.sock, "close", None)):
            if close:
                try:
                    close()
                except OSError:
                    pass
        self.sock = self.f = None

    def _send(self, obj):
        with self.lock:
            if self.sock is None:
                self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                self.sock.connect(self.path)
                self.f = self.sock.makefile("rwb")
            try:
                self.f.write((json.dumps(obj) + "\n").encode())
                self.f.flush()
                line = self.f.readline()
                if not line:
                    raise ConnectionError("niri closed the connection")
                return json.loads(line)
            except Exception:
                self.close()
                raise

    def query(self, name):
        reply = self._send(name)
        if "Err" in reply:
            raise RuntimeError(reply["Err"])
        ok = reply.get("Ok")
        return ok.get(name) if isinstance(ok, dict) else None

    def action(self, action):
        reply = self._send({"Action": action})
        if "Err" in reply:
            raise RuntimeError(reply["Err"])


_client = None


def client():
    global _client
    if _client is None:
        _client = Niri()
    return _client


def workspace_ref(ws):
    if ws.get("name"):
        return {"Name": ws["name"]}
    return {"Index": ws["idx"]}


def move_to_workspace(win_id, ws):
    client().action({"MoveWindowToWorkspace": {
        "window_id": win_id, "reference": workspace_ref(ws), "focus": False}})


def send_move(win_id, x, y):
    """Send one MoveFloatingWindow with per-axis PositionChange dicts.

    Returns False (and sends nothing) when both axes are no-op relative
    moves, so a window already in place never wiggles.
    """
    def noop(c):
        return c is not None and "AdjustFixed" in c and abs(c["AdjustFixed"]) <= 1
    if noop(x) and noop(y):
        return False
    client().action({"MoveFloatingWindow": {"id": win_id, "x": x, "y": y}})
    return True


def anchor_place(win_id, p):
    """Fallback when the working area is not known yet: anchor to the corner
    with a proportional move, then offset in pixels."""
    client().action({"MoveFloatingWindow": {
        "id": win_id,
        "x": {"SetProportion": float(p["x_anchor"])},
        "y": {"SetProportion": float(p["y_anchor"])}}})
    client().action({"MoveFloatingWindow": {
        "id": win_id,
        "x": {"AdjustFixed": float(p["x_adj"])},
        "y": {"AdjustFixed": float(p["y_adj"])}}})


def event_reader(q):
    """Read the niri event stream straight off its own socket connection."""
    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(os.environ["NIRI_SOCKET"])
        sock.sendall(b'"EventStream"\n')
        f = sock.makefile("rb")
        f.readline()  # {"Ok":"Handled"}
        while True:
            line = f.readline()
            if not line:
                break
            try:
                ev = json.loads(line)
            except json.JSONDecodeError:
                continue
            if any(k in ev for k in EVENTS_THAT_MATTER):
                q.put(ev)
    except Exception as e:  # keep the daemon alive; service will restart it
        print(f"niri-pip-stack: event stream: {e}", file=sys.stderr)
    q.put(None)


# ---- window helpers ---------------------------------------------------------

def is_pip(w):
    return (w.get("is_floating")
            and APP_ID_RE.match(w.get("app_id") or "")
            and TITLE_RE.match(w.get("title") or ""))


def size_of(w):
    layout = w.get("layout") or {}
    s = layout.get("tile_size") or layout.get("window_size")
    return (int(s[0]), int(s[1])) if s else None


def pos_of(w):
    p = (w.get("layout") or {}).get("tile_pos_in_workspace_view")
    return (round(p[0]), round(p[1])) if p else None


# ---- layout math ------------------------------------------------------------

def avail_height(out_h):
    return out_h - 2 * MARGIN - TOP_RESERVED - BOTTOM_RESERVED


def used_height(ids, by_id):
    hs = [by_id[i]["size"][1] for i in ids]
    return sum(hs) + GAP * max(len(hs) - 1, 0)


def max_off_screen(size):
    """How far niri lets a floating window hang off the working-area edge."""
    min_on = min(75.0, max(10.0, size / 4.0))
    return max(0.0, size - min_on)


def normalize(cols, by_id, out_h):
    """Drop empty columns; push overflow of a full column into the next one
    on the same side."""
    avail = avail_height(out_h)
    result = []
    for side in ("right", "left"):
        side_cols = [c for c in cols if c["side"] == side and c["wins"]]
        i = 0
        while i < len(side_cols):
            keep, rest = [], []
            for wid in side_cols[i]["wins"]:
                if not rest and (not keep or used_height(keep + [wid], by_id) <= avail):
                    keep.append(wid)
                else:
                    rest.append(wid)
            side_cols[i]["wins"] = keep
            if rest:
                if i + 1 == len(side_cols):
                    side_cols.append({"side": side, "wins": []})
                side_cols[i + 1]["wins"] = rest + side_cols[i + 1]["wins"]
            i += 1
        result.extend(c for c in side_cols if c["wins"])
    return result


def geometry(cols, by_id):
    """Per window: column offsets + an anchor fallback placement."""
    placements = {}
    right_off = left_off = 0.0
    for col in cols:
        side, wins = col["side"], col["wins"]
        width = max(by_id[i]["size"][0] for i in wins)
        off = right_off if side == "right" else left_off
        if side == "right":
            right_off += width + GAP
        else:
            left_off += width + GAP
        v_off = 0.0
        for wid in wins:
            ww, wh = by_id[wid]["size"]
            if side == "right":
                x_anchor, x_adj = 100.0, -(MARGIN + off + max_off_screen(ww))
            else:
                x_anchor, x_adj = 0.0, MARGIN + off
            if TOP:
                y_anchor, y_adj = 0.0, MARGIN + TOP_RESERVED + v_off
            else:
                y_anchor = 100.0
                y_adj = -(MARGIN + BOTTOM_RESERVED + v_off + max_off_screen(wh))
            placements[wid] = {
                "side": side, "off": off, "v_off": v_off, "ww": ww, "wh": wh,
                "x_anchor": x_anchor, "x_adj": x_adj,
                "y_anchor": y_anchor, "y_adj": y_adj,
            }
            v_off += wh + GAP
    return placements


def change_for(p, r, pos):
    """Per-axis PositionChange dicts, or None for the anchor fallback.

    `SetFixed` is relative to the working area, so the left edge can be set
    directly (MARGIN + offset). The right/top edges need the working-area
    size, which we don't know, so we use the corner learned from the window
    rule as an absolute target and reach it with one relative move.
    """
    x = y = None
    if p["side"] == "left":
        x = {"SetFixed": float(MARGIN + p["off"])}
    elif p["side"] == "right" and r.get("right") is not None:
        x = {"AdjustFixed": float(r["right"] - p["off"] - p["ww"] - pos[0])}
    if TOP and r.get("top") is not None:
        y = {"AdjustFixed": float(r["top"] + p["v_off"] - pos[1])}
    elif not TOP and r.get("bottom") is not None:
        y = {"AdjustFixed": float(r["bottom"] - p["v_off"] - p["wh"] - pos[1])}
    return x, y


def sig_of(p):
    return (p["side"], round(p["off"]), round(p["v_off"]),
            p["x_anchor"], round(p["x_adj"]), p["y_anchor"], round(p["y_adj"]))


def col_centers(cols, by_id, out_w):
    """Approximate column centres (full-output frame) for drop targeting."""
    info = []
    right_edge = left_edge = MARGIN
    for col in cols:
        side, wins = col["side"], col["wins"]
        width = max(by_id[i]["size"][0] for i in wins)
        if side == "right":
            x_left = out_w - right_edge - width
            right_edge += width + GAP
        else:
            x_left = left_edge
            left_edge += width + GAP
        info.append((side, x_left + width / 2))
    return info


# ---- drag handling -------------------------------------------------------------

def drop_window(cols, wid, by_id, out_w, col_info):
    """Snap wid into the column nearest where it was dropped, choosing the
    screen side from the drop's horizontal position."""
    w = by_id[wid]
    pos = w["pos"] or expected.get(wid)
    if not pos:
        return
    (x, y), (ww, wh) = pos, w["size"]
    cx, cy = x + ww / 2, y + wh / 2
    side = "left" if cx < out_w / 2 else "right"

    for c in cols:
        if wid in c["wins"]:
            c["wins"].remove(wid)

    candidates = [k for k, info in enumerate(col_info) if info[0] == side]
    if candidates:
        target = min(candidates, key=lambda k: abs(cx - col_info[k][1]))
    else:
        cols.append({"side": side, "wins": []})
        target = len(cols) - 1

    col = cols[target]["wins"]
    idx = 0
    for other in col:
        o = by_id[other]
        oy = (o["pos"] or expected.get(other, (0, 0)))[1] + o["size"][1] / 2
        if oy < cy:
            idx += 1
    col.insert(idx if TOP else len(col) - idx, wid)


# ---- main relayout ----------------------------------------------------------------

def relayout():
    windows = client().query("Windows")
    workspaces = {ws["id"]: ws for ws in client().query("Workspaces")}
    outputs = client().query("Outputs")

    # The active workspace of each output, so PiP windows can follow the user.
    active_by_output = {}
    for ws in workspaces.values():
        if ws.get("is_active") and ws.get("output"):
            active_by_output[ws["output"]] = ws

    per_output = {}
    for w in windows:
        if not is_pip(w) or not size_of(w):
            continue
        ws = workspaces.get(w.get("workspace_id"))
        if not ws or not ws.get("output"):
            continue
        out = ws["output"]
        target_ws = active_by_output.get(out)
        if target_ws and target_ws["id"] != ws["id"]:
            move_to_workspace(w["id"], target_ws)
        per_output.setdefault(out, {})[w["id"]] = {
            "size": size_of(w), "pos": pos_of(w)}

    # forget windows that are gone / left an output
    for out_name in list(columns):
        alive = set(per_output.get(out_name, {}))
        columns[out_name] = [
            {"side": c["side"], "wins": [i for i in c["wins"] if i in alive]}
            for c in columns[out_name]
        ]
        columns[out_name] = [c for c in columns[out_name] if c["wins"]]
        if not columns[out_name] and out_name not in per_output:
            del columns[out_name]
    live_ids = {i for d in per_output.values() for i in d}
    for d in (expected, sizes, placed):
        for i in list(d):
            if i not in live_ids:
                del d[i]

    for out_name, by_id in per_output.items():
        logical = (outputs.get(out_name) or {}).get("logical")
        if not logical:
            continue
        out_w, out_h = logical["width"], logical["height"]
        cols = columns.setdefault(out_name, [])

        # new windows go into the default side's first column with room
        known = {i for c in cols for i in c["wins"]}
        new_wids = sorted(set(by_id) - known)
        for wid in new_wids:
            for c in cols:
                if (c["side"] == DEFAULT_SIDE
                        and used_height(c["wins"] + [wid], by_id) <= avail_height(out_h)):
                    c["wins"].append(wid)
                    break
            else:
                cols.append({"side": DEFAULT_SIDE, "wins": [wid]})

        # Learn the working-area corner. New PiPs open at the configured
        # corner before we move them, so the outermost edge of any window
        # teaches us that corner. Done from all windows (not just new ones)
        # so a window whose position is briefly absent still gets learned.
        r = ref.setdefault(out_name, {})
        if not r:
            for wid, w in by_id.items():
                pos = w["pos"]
                if not pos:
                    continue
                ww, wh = w["size"]
                if CORNER.endswith("right"):
                    v = pos[0] + ww
                    r["right"] = v if r.get("right") is None else max(r["right"], v)
                else:
                    v = pos[0]
                    r["left"] = v if r.get("left") is None else min(r["left"], v)
                if CORNER.startswith("top"):
                    v = pos[1]
                    r["top"] = v if r.get("top") is None else min(r["top"], v)
                else:
                    v = pos[1] + wh
                    r["bottom"] = v if r.get("bottom") is None else max(r["bottom"], v)

        # drag detection, framed against *observed* positions only (this is
        # offset-agnostic, so a bar/frame can't cause phantom drags)
        dragged = []
        for wid, w in by_id.items():
            pos = w["pos"]
            if not pos:
                continue
            col_side = next((c["side"] for c in cols if wid in c["wins"]), None)
            side_now = "left" if (pos[0] + w["size"][0] / 2) < out_w / 2 else "right"
            exp = expected.get(wid)
            if exp is None:
                expected[wid] = pos
                if col_side and side_now != col_side:
                    dragged.append(wid)
                continue
            if (max(abs(pos[0] - exp[0]), abs(pos[1] - exp[1])) > DRAG_THRESHOLD
                    or (col_side and side_now != col_side)):
                dragged.append(wid)
            expected[wid] = pos

        if dragged:
            info = col_centers(cols, by_id, out_w)
            for wid in sorted(dragged,
                              key=lambda i: by_id[i]["pos"][1] if by_id[i]["pos"] else 0):
                drop_window(cols, wid, by_id, out_w, info)

        cols = normalize(cols, by_id, out_h)
        columns[out_name] = cols
        placements = geometry(cols, by_id)

        for wid, p in placements.items():
            pos = by_id[wid]["pos"]
            sig = sig_of(p)
            sizes[wid] = by_id[wid]["size"]
            if pos is None:
                continue  # not laid out yet; wait for the next pass
            if placed.get(wid) == sig and wid not in dragged:
                continue  # already placed and not moved
            x_change, y_change = change_for(p, r, pos)
            if x_change is None or y_change is None:
                anchor_place(wid, p)
                expected[wid] = None
            elif send_move(wid, x_change, y_change):
                expected[wid] = None  # learn the new position next pass
            if wid in dragged:
                placed.pop(wid, None)  # move may be ignored mid-drag; retry when settled
            else:
                placed[wid] = sig


def main():
    q = queue.Queue()
    threading.Thread(target=event_reader, args=(q,), daemon=True).start()
    relayout()

    dirty = False
    while True:
        try:
            ev = q.get(timeout=SETTLE)
            if ev is None:
                return
            dirty = True
        except queue.Empty:
            if dirty:
                dirty = False
                try:
                    relayout()
                except Exception as e:  # keep the daemon alive
                    print(f"niri-pip-stack: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
