#!/usr/bin/env bash
DIR="${1:-$HOME/Pictures/Screenshots}"
FILE="$(ls -t "$DIR" | head -1)"
BASENAME="$(basename "$FILE" .png)"
OUTPUT="$DIR/${BASENAME}-annotated.png"

satty -f "$DIR/$FILE" --output-filename "$OUTPUT" && \
  wl-copy --type image/png < "$OUTPUT"
