#!/usr/bin/env bash
set -euo pipefail

# Usage: nix run github:adienox/arete#install <hostname> [role]
# Env:   FLAKE_REF  overrides where the flake is fetched from
#        USER_NAME  overrides the admin user (default: nox)

HOST="${1:?usage: nix run github:adienox/arete#install <hostname> [role]}"
USER_NAME="${USER_NAME:-nox}"
FLAKE_REF="${FLAKE_REF:-github:adienox/arete}"
REPO_URL="https://github.com/adienox/arete"

# One clone, used for both disko and the installed system. disko evaluates the
# flake, which requires a hardware.nix; if the repo has none yet, generate one
# here from the live machine (we are running on the target) with
# --no-filesystems, because disko owns fileSystems/swapDevices.
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
echo "==> fetching arete into ${WORK}"
git clone --depth 1 "${REPO_URL}" "${WORK}"

GENERATED_HW=0
HW_WORK="${WORK}/hosts/${HOST}/hardware.nix"
if [ ! -f "${HW_WORK}" ]; then
  echo "==> no hardware.nix for ${HOST}; generating from this machine"
  mkdir -p "$(dirname "${HW_WORK}")"
  sudo nixos-generate-config --no-filesystems --show-hardware-config | tee "${HW_WORK}" > /dev/null
  git -C "${WORK}" add "hosts/${HOST}/hardware.nix"
  GENERATED_HW=1
else
  echo "==> using committed hardware.nix for ${HOST}"
fi

echo "==> partitioning ${HOST} (destroy,format,mount)"
sudo nix run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --yes-wipe-all-disks \
  --flake "${WORK}#${HOST}"

TARGET_ARETE="/mnt/home/${USER_NAME}/Documents/projects/arete"
echo "==> copying arete into target (used for install + kept post-boot)"
sudo mkdir -p "/mnt/home/${USER_NAME}/Documents/projects"
sudo cp -a "${WORK}" "${TARGET_ARETE}"

echo "==> detecting role for ${HOST}"
ROLE="${2:-}"
if [ -z "${ROLE}" ]; then
  ROLE="$(nix eval --raw "${TARGET_ARETE}#nixosConfigurations.${HOST}.config.arete.role" 2>/dev/null || true)"
fi
ROLE="${ROLE:-workstation}"
echo "    role: ${ROLE}"

echo "==> installing NixOS for ${HOST}"
sudo nixos-install --flake "${TARGET_ARETE}#${HOST}" --no-root-passwd

read -rp "Fetch SSH key from Bitwarden? [y/N] " FETCH_SECRETS
FETCH_SECRETS="${FETCH_SECRETS,,}"  # lowercase

if [ "${FETCH_SECRETS}" = "y" ] || [ "${FETCH_SECRETS}" = "yes" ]; then
  echo "==> Fetching secrets (SSH key) from Bitwarden"
  nix run "${FLAKE_REF}#secrets" -- "${HOST}" "${USER_NAME}"
else
  echo "==> Skipping Bitwarden secrets fetch"
fi

if [ "${ROLE}" = "workstation" ]; then
  echo "==> cloning kairo into target"
  sudo git clone --depth 1 https://github.com/adienox/kairo \
    "/mnt/home/${USER_NAME}/Documents/projects/kairo"

  echo "==> adding wallpapers"
  sudo mkdir -p "/mnt/home/${USER_NAME}/Pictures"
  sudo git clone --depth 1 https://github.com/adienox/wallpapers \
    "/mnt/home/${USER_NAME}/Pictures/wallpapers"
else
  echo "==> server role: skipping kairo/wallpapers"
fi

echo "==> fixing ownership for ${USER_NAME}"
TARGET_UID="$(sudo grep "^${USER_NAME}:" /mnt/etc/passwd | cut -d: -f3)"
TARGET_GID="$(sudo grep "^${USER_NAME}:" /mnt/etc/passwd | cut -d: -f4)"
sudo chown -R "${TARGET_UID}:${TARGET_GID}" "/mnt/home/${USER_NAME}"

echo "✓ done — reboot into ${HOST}"

if [ "${GENERATED_HW}" = "1" ]; then
  echo
  echo "  NOTE: hosts/${HOST}/hardware.nix was generated and is staged but not"
  echo "  committed. After first boot, commit it:"
  echo "      cd ~/Documents/projects/arete && git add hosts/${HOST}/hardware.nix && git commit"
fi
