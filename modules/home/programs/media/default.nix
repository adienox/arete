{ pkgs, ... }:
{
  imports = [
    ./spicetify.nix
    ./imv.nix
    ./mpv.nix
    ./easyeffects
  ];

  home.packages = with pkgs; [
    helvum
    yt-dlp
  ];
}
