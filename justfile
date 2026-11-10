# ntfy topic used by _notify. Override with the NTFY_TOPIC env var.
ntfy_topic := env_var_or_default("NTFY_TOPIC", "anomaly-alerts")

# ssh user used by `deploy`. Override with the REMOTE_USER env var.
remote_user := env_var_or_default("REMOTE_USER", "nox")

# list all recipes
_default:
    @just --list

# rebuild NixOS and switch
update:
    @just _diff
    @nh os switch
    #@git add --all
    #@gen=$(nixos-rebuild list-generations | awk '/True/ {print $1}');\
    #just _commit "nixos-rebuild: generation $gen"
    #@just _notify "system successfully updated"

# build locally and deploy to a remote host (e.g. `just deploy anomaly`)
deploy host:
    @just _diff
    @nh os switch .#{{ host }} -H {{ host }} --target-host {{ remote_user }}@{{ host }}

# Fetch a day's report from anomaly and view it with glow
report date=`date +%F`:
    #!/usr/bin/env bash
    set -euo pipefail

    host="anomaly"
    src_dir="/var/lib/cache-builder/reports"
    dest_dir="${TMPDIR:-/tmp}/cache-builder-reports"

    src="$src_dir/{{date}}-axiom.md"
    dest="$dest_dir/{{date}}.md"

    mkdir -p "$dest_dir"

    if [[ ! -e "$dest" ]]; then
        scp -q "$host:$src" "$dest"
    fi

    cat "$dest"

vm host:
    @nixos-rebuild build-vm -F .#{{ host }}

# rebuild NixOS for next boot
update-at-boot:
    @just _diff
    @nh os boot
    @git add --all
    @gen=$(nixos-rebuild list-generations | awk '/True/ {print $1}');\
    just _commit "nixos-rebuild: generation $gen"

# diff and commit flake.lock
_git-flake:
    @git add flake.lock
    @just _commit "chore: update flake.lock"

# update flake inputs
flake:
    @echo "Updating flake inputs…"
    @nix flake update
    @just _git-flake

# update a single input
single-flake input:
    @echo "Updating {{ input }}…"
    @nix flake update {{ input }}
    @just _git-flake

# update (flake/system) → switch → commit
all:
    @just _diff
    @just flake
    @just update

# show diff of uncommitted changes in dir
_diff:
    #!/usr/bin/env bash
    if [ -n "$INSIDE_EMACS" ]; then
        exit
    fi

    git diff

# git commit
_commit msg:
    #!/usr/bin/env bash
    set -e
    echo "Committing: {{ msg }}"
    git commit -q -m "{{ msg }}" 2>/dev/null || true

_notify msg:
    #!/usr/bin/env bash
    notify-send -a "system" -i "system-software-update" "Update complete" "{{ msg }}"
    if tailscale status >/dev/null 2>&1; then
        ntfy publish \
            --title="Update complete" \
            --priority=low \
            {{ ntfy_topic }} \
            "{{ msg }}"
    fi

# nh clean
clean:
    nh clean all

addon addon:
    @nix run github:osipog/nix-firefox-addons#search-addon {{ addon }}

search package:
    nh search --limit 5 {{ package }}

# check the flake without building
check:
    nix flake check
