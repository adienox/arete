#!/usr/bin/env python3
"""
Native messaging host for Tab Handoff.
Spawned by Firefox per message. Reads one message, writes the URL to a file, exits.
"""

import json
import pathlib
import struct
import sys

OUT = pathlib.Path.home() / ".local" / "share" / "arete-state" / "url"


def read_message():
    raw_len = sys.stdin.buffer.read(4)
    if not raw_len:
        sys.exit(0)
    length = struct.unpack("=I", raw_len)[0]
    return json.loads(sys.stdin.buffer.read(length))


def write_message(msg):
    encoded = json.dumps(msg).encode()
    sys.stdout.buffer.write(struct.pack("=I", len(encoded)))
    sys.stdout.buffer.write(encoded)
    sys.stdout.buffer.flush()


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    try:
        msg = read_message()
        url = msg.get("url", "").strip()
        if url:
            OUT.write_text(url + "\n")
        write_message({"status": "ok"})
    except Exception as e:
        write_message({"status": "error", "error": str(e)})
        sys.exit(1)


if __name__ == "__main__":
    main()
