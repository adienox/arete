{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  dms-wallpaper-selector = pkgs.makeDesktopItem {
    icon = "preferences-desktop-wallpaper";
    name = "wallpaper-selector";
    exec = "dms ipc wallpaperCarousel toggle";
    desktopName = "Select Wallpaper";
    terminal = false;
  };
  dms-toggle-theme = pkgs.makeDesktopItem {
    icon = "applications-interfacedesign";
    name = "theme-toggle";
    exec = "dms ipc call theme toggle";
    desktopName = "Toggle Theme";
    terminal = false;
  };
in
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];

  home.packages = with pkgs; [
    gpu-screen-recorder
    dms-wallpaper-selector
    dms-toggle-theme
  ];

  programs.dank-material-shell = {
    enable = true;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    niri.includes = {
      enable = true;
      override = true;
      originalFileName = "home-manager";
      filesToInclude = [
        "alttab"
        "binds"
        "colors"
        "layout"
        "outputs"
        "wpblur"
      ];
    };
  };
}
