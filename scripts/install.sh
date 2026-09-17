#!/usr/bin/env bash
set -euo pipefail

# FIXME: user for now is only for this script, the created user will always be nox
# Usage: nix run github:adienox/arete#install <hostname> [user]
# Env:   FLAKE_REF  overrides where the flake is fetched from

HOST="${1:?usage: nix run github:adienox/arete#install <hostname>}"
USER_NAME="nox"
FLAKE_REF="${FLAKE_REF:-github:adienox/arete}"

echo "==> partitioning ${HOST} (destroy,format,mount)"
sudo nix run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --yes-wipe-all-disks \
  --flake "${FLAKE_REF}#${HOST}"

echo "==> installing NixOS for ${HOST}"
sudo nixos-install --flake "${FLAKE_REF}#${HOST}" --no-root-passwd

read -rp "Fetch SSH key from Bitwarden? [y/N] " FETCH_SECRETS
FETCH_SECRETS="${FETCH_SECRETS,,}"  # lowercase

if [ "$FETCH_SECRETS" = "y" ] || [ "$FETCH_SECRETS" = "yes" ]; then
  echo "==> Fetching secrets (SSH key) from Bitwarden"
  nix run "${FLAKE_REF}#secrets" -- "${HOST}" "${USER_NAME}"
else
  echo "==> Skipping Bitwarden secrets fetch"
fi

echo "==> cloning arete into target"
sudo mkdir -p "/mnt/home/${USER_NAME}/Documents/projects"
sudo git clone --depth 1 https://github.com/adienox/arete \
  "/mnt/home/${USER_NAME}/Documents/projects/arete"

echo "==> cloning kairo into target"
sudo git clone --depth 1 https://github.com/adienox/kairo \
  "/mnt/home/${USER_NAME}/Documents/projects/kairo"

echo "==> adding wallpapers"
sudo mkdir -p "/mnt/home/${USER_NAME}/Pictures"
sudo git clone --depth 1 https://github.com/adienox/wallpapers \
  "/mnt/home/${USER_NAME}/Pictures/wallpapers"

echo "==> fixing ownership for ${USER_NAME}"
TARGET_UID="$(sudo grep "^${USER_NAME}:" /mnt/etc/passwd | cut -d: -f3)"
TARGET_GID="$(sudo grep "^${USER_NAME}:" /mnt/etc/passwd | cut -d: -f4)"
sudo chown -R "${TARGET_UID}:${TARGET_GID}" "/mnt/home/${USER_NAME}"

echo "✓ done — reboot into ${HOST}"
