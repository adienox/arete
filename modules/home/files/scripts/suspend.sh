#!/usr/bin/env bash
# suspend -- pre-suspend hook + systemd suspend
# Place in your writeShellScriptBin / home.packages

set -euo pipefail

check_media() {
  if command -v playerctl &>/dev/null; then
    local status
    status=$(playerctl status 2>/dev/null || true)
    if [[ "$status" == "Playing" ]]; then
      echo "suspend: media is playing, aborting." >&2
      exit 1
    fi
  fi
}

check_ssh() {
  local sessions
  sessions=$(who | awk '$2 ~ /^pts/ {print}')
  if [[ -n "$sessions" ]]; then
    echo "suspend: active SSH session(s) detected, aborting." >&2
    echo "$sessions" >&2
    exit 1
  fi
}

check_cpu() {
  local load cores threshold
  load=$(awk '{print $2}' /proc/loadavg)  # 5-minute average
  cores=$(nproc)
  threshold=$(echo "$cores * 0.75" | bc)
  if (( $(echo "$load > $threshold" | bc -l) )); then
    echo "suspend: CPU load ${load} exceeds threshold ${threshold} (${cores} cores × 0.75), aborting." >&2
    exit 1
  fi
}

check_nix() {
  if pgrep -x "nix" -x "nix-build" -x "nix-store" -x "nixos-rebuild" -x "nh" &>/dev/null; then
    echo "suspend: nix build in progress, aborting." >&2
    exit 1
  fi
}

check_media
check_ssh
check_cpu
check_nix
loginctl lock-session
systemctl suspend
