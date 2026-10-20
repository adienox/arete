# Shared server base profile: barebones system for containers and services.
#
# Loaded automatically by lib.mkHost for hosts with `role = "server"`.
# Per-machine overrides live in modules/profiles/servers/<hostname>.nix
# and are picked up automatically when they exist.
#
# No desktop stack and no home-manager. The shared ./system/common.nix base
# provides networking, SSH, Tailscale, sops, the admin user, Docker, etc.
{
  imports = [
    ../../system/common.nix
  ];
}
