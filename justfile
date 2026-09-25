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
    @just _diff flake.lock
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
        curl -s -o /dev/null \
          -H "Title: Update complete" \
          -H "Priority: low" \
          -d "{{ msg }}" \
          https://ntfy.chipmunk-teeth.ts.net/anomaly-alerts
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
