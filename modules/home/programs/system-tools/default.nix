{ pkgs, ... }:
{
  imports = [
    ./nix-index.nix
    ./taildrop.nix
    ./udiskie.nix
    ./nh.nix
    ./commands-api.nix
    ./syncthing.nix
  ];

  home.packages = with pkgs; [
    android-tools
    scrcpy
    pmbootstrap
  ];
}
