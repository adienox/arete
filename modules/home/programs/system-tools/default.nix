{ pkgs, ... }:
{
  imports = [
    ./udiskie.nix
    ./commands-api.nix
    ./syncthing.nix
    ./wallpaper-git.nix
  ];

  home.packages = with pkgs; [
    android-tools
    scrcpy
    pmbootstrap
  ];
}
