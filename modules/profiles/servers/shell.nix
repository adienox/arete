# Shell/QoL for the server profile.
#
# Servers don't use home-manager, so starship comes from the NixOS module
# instead of modules/home/programs/shell/starship.nix. This mirrors that
# config: enable starship and the fish transient prompt.
{ ... }:
{
  programs.starship = {
    enable = true;
    transientPrompt.enable = true;
  };
}
