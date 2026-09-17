#!/usr/bin/env bash
set -euo pipefail

HOSTNAME="${1:?usage: #secrets <hostname> <user>}"
USER_NAME="${2:?usage: #secrets <hostname> <user>}"

ITEM_NAME="$HOSTNAME"

if mountpoint -q /mnt; then
  ROOT="/mnt"
else
  ROOT=""
fi

DEST="${ROOT}/home/${USER_NAME}/.ssh/id_ed25519"

echo "==> Bitwarden auth"
STATUS="$(bw status | jq -r '.status')"

if [ "$STATUS" = "unauthenticated" ]; then
  read -rp "Bitwarden email: " BW_EMAIL
  BW_SESSION="$(bw login "$BW_EMAIL" --raw)"
else
  BW_SESSION="$(bw unlock --raw)"
fi

export BW_SESSION

echo "==> Writing keys to $DEST"
sudo mkdir -p "$(dirname "$DEST")"
bw get item "$ITEM_NAME" | jq -r '.sshKey.privateKey' | sudo tee "$DEST" >/dev/null
bw get item "$ITEM_NAME" | jq -r '.sshKey.publicKey' | sudo tee "$DEST.pub" >/dev/null
sudo chmod 600 "$DEST"
bw lock
echo "==> Key written to $DEST"

echo "==> Fixing secrets ownership for ${USER_NAME}"
TARGET_UID="$(grep "^${USER_NAME}:" "${ROOT}/etc/passwd" | cut -d: -f3)"
TARGET_GID="$(grep "^${USER_NAME}:" "${ROOT}/etc/passwd" | cut -d: -f4)"
sudo chown -R "${TARGET_UID}:${TARGET_GID}" "${ROOT}/home/${USER_NAME}"
