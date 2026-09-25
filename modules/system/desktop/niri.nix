{ inputs, pkgs, ... }:
{
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  programs = {
    niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
    uwsm = {
      enable = true;
      waylandCompositors = {
        niri = {
          prettyName = "Niri";
          comment = "Niri compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/niri";
        };
      };
    };
  };
}
