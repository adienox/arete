flake_dir := "."

# list all recipes
_default:
    @just --list

# rebuild NixOS and switch
system:
    @just _diff system
    @nh os switch --impure {{ flake_dir }}
    @git add --all
    @git reset modules/home
    @gen=$(nixos-rebuild list-generations | awk '/True/ {print $1}');\
    just _commit "nixos-rebuild: generation $gen"
    @just _notify "system successfully updated"

# rebuild NixOS for next boot
system-at-boot:
    @just _diff system
    @nh os boot --impure {{ flake_dir }}
    @git add --all
    @git reset modules/home
    @gen=$(nixos-rebuild list-generations | awk '/True/ {print $1}');\
    just _commit "nixos-rebuild: generation $gen"

# rebuild home-manager and switch
home:
    @just _diff home
    @nh home switch -b backup --impure {{ flake_dir }}
    @git add -- modules/home
    @gen=$(home-manager generations | awk '/current/ {print $5}');\
    just _commit "home-rebuild: generation $gen"
    @just _notify "home successfully updated"

home-hm:
    @just _diff home
    @home-manager switch --flake "{{ flake_dir }}#nox" --impure -b backup
    @git add -- modules/home
    @gen=$(home-manager generations | awk '/current/ {print $5}');\
    just _commit "home-rebuild: generation $gen"

# diff and commit flake.lock
_git-flake:
    @just _diff flake.lock
    @git add flake.lock
    @just _commit "chore: update flake.lock"

# update flake inputs
flake:
    @echo "Updating flake inputs…"
    @nix flake update --option access-tokens "github.com=$(gh auth token)"
    @just _git-flake

# update a single input
single-flake input:
    @echo "Updating {{ input }}…"
    @nix flake update {{ input }}
    @just _git-flake

# update (system/home) → switch → commit
all:
    @just _diff
    @just flake
    @just system
    @just home

# show diff of uncommitted changes in dir
_diff dir=flake_dir:
    #!/usr/bin/env bash
    DIR="{{ dir }}"

    if [ -n "$INSIDE_EMACS" ]; then
        exit
    fi

    if [[ "$DIR" == "system" ]]; then
        git diff -- . ':(exclude)modules/home' ':(exclude)flake.lock'
    elif [[ "$DIR" == "home" ]]; then
        git diff -- modules/home
    else
        git diff -- "$DIR" ':(exclude)flake.lock'
    fi

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
    nix flake check --impure
