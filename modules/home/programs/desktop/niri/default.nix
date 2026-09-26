{
  pkgs,
  helpers,
  ...
}:
{
  imports = [
    ./screenshot-url-tag.nix
    ./binds.nix
    ./settings.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard
    xwayland-satellite
    playerctl
    bibata-cursors
    satty
  ];

  wayland.windowManager.niri = {
    enable = true;
    enableDefaultConfig = true;
    package = pkgs.niri-unstable;
  };

  home.file = helpers.mkConfigFile {
    target = ".config/niri/animations.kdl";
    source = ./animations/directional-wipe.kdl;
  };
}
