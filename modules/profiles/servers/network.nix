# Keep the server reachable: 802.11 power save lets the WiFi card (Intel
# AX200 here) sleep and drop/delay packets when idle, which shows up as
# intermittent Tailscale/SSH unreachability. Workstations keep the shared
# default (enabled).
{
  lib,
  ...
}:
{
  networking.networkmanager.wifi.powersave = lib.mkForce false;
}
