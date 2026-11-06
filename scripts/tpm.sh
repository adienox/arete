#!/usr/bin/env sh

sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-partlabel/disk-main-luks
