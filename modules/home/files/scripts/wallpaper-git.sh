#!/usr/bin/env bash
# Watch the wallpapers repo for new files and offer to:
#   - commit & push
#   - rename, then commit & push
#   - create a task (via apis.chipmunk-teeth.ts.net) and defer it
#
# Invoked by the wallpaper-git path unit. Positional arg is the repo path.
set -euo pipefail

REPO="${1:-$HOME/Pictures/wallpapers}"
API="${WALLPAPER_TASKS_API:-https://apis.chipmunk-teeth.ts.net/tasks}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper-git"
STATE="$STATE_DIR/handled"

cd "$REPO"
mkdir -p "$STATE_DIR"

mapfile -t ALL < <(git ls-files --others --exclude-standard)

# Prune deferred entries that are no longer untracked (committed/removed).
if [ -s "$STATE" ] && [ "${#ALL[@]}" -gt 0 ]; then
  grep -Fxf <(printf '%s\n' "${ALL[@]}") "$STATE" > "$STATE.new" 2>/dev/null || true
  mv "$STATE.new" "$STATE"
elif [ "${#ALL[@]}" -eq 0 ]; then
  : > "$STATE"
fi
touch "$STATE"

# Untracked files we haven't already deferred to a task.
NEW=()
for f in "${ALL[@]}"; do
  grep -qxF -- "$f" "$STATE" || NEW+=("$f")
done
[ "${#NEW[@]}" -eq 0 ] && exit 0

if [ "${#NEW[@]}" -eq 1 ]; then
  LABEL="$(basename "${NEW[0]}")"
else
  LABEL="${#NEW[@]} new wallpapers"
fi

ACTION="$(notify-send --wait -a Wallpapers -i preferences-desktop-wallpaper \
  --action=commit="Commit & push" \
  --action=rename="Rename & push" \
  --action=task="Add to tasks" \
  "New wallpaper: ${LABEL}" \
  "$(printf '%s\n' "${NEW[@]:0:10}")" 2>/dev/null || true)"

commit_push() {
  git add -- "$@"
  git commit -m "add: $(printf '%s, ' "$@" | sed 's/, $//')"
  git push
  notify-send -a Wallpapers -i preferences-desktop-wallpaper "Wallpapers pushed" "${LABEL}"
}

case "$ACTION" in
  commit)
    commit_push "${NEW[@]}"
    ;;

  rename)
    RENAMED=()
    for f in "${NEW[@]}"; do
      dir="$(dirname "$f")"
      base="$(basename "$f")"
      ext="${base##*.}"
      stem="${base%.*}"
      new="$(yad --entry --title="Rename wallpaper" \
        --text="New name for ${base}" --entry-text="${stem}" --width=420 2>/dev/null || true)"
      [ -z "$new" ] && exit 0
      if [ "$dir" = "." ]; then
        newpath="${new}.${ext}"
      else
        newpath="${dir}/${new}.${ext}"
      fi
      git mv -- "$f" "$newpath"
      RENAMED+=("$newpath")
    done
    commit_push "${RENAMED[@]}"
    ;;

  task)
    title="Wallpaper: ${LABEL}"
    notes="New wallpaper(s) in ${REPO}:
$(printf '  %s\n' "${NEW[@]}")

Commit, rename, or clean up when you get to it."
    jq -n --arg t "$title" --arg n "$notes" \
      '{title: $t, notes: $n, todo: "TODO", tags: ["wallpaper"]}' \
      | curl -sS -X POST "$API" -H 'Content-Type: application/json' -d @- > /dev/null
    printf '%s\n' "${NEW[@]}" >> "$STATE"
    notify-send -a Wallpapers -i preferences-desktop-wallpaper "Task created" "${LABEL}"
    ;;

  *)
    : # dismissed; it'll be offered again next time the repo changes
    ;;
esac
