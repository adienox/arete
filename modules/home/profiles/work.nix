# Work profile: Focused productivity setup for professional work
#
# This profile disables non-essential packages and heavy customization.
# Good for: Professional development, work VMs, minimal resource usage

{ config, pkgs, ... }:
{
  # Reduce package set for smaller footprint
  home.packages = pkgs.lib.mkForce [];

  # Disable heavy desktop customization
  programs.spicetify.enable = false;
}


