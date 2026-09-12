# Minimal profile: Bare essentials for testing or minimal systems
#
# This profile removes optional packages and disables non-essential services.
# Good for: Testing, minimal installations, container environments

{ config, pkgs, ... }:
{
  # Remove all optional packages
  home.packages = pkgs.lib.mkForce [];

  # Disable optional services and programs
  programs.spicetify.enable = false;
  services.syncthing.enable = false;
  services.gnome-keyring.enable = false;
  services.kdeconnect.enable = false;
}

