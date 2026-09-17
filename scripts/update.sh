#!/usr/bin/env bash
nix flake update
nixos-rebuild switch --flake .#anomaly
