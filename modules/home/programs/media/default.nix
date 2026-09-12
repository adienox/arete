{ pkgs, ... }:
{
  imports = [
    ./spicetify.nix
    ./imv.nix
    ./mpv.nix
    ./easyeffects.nix
  ];

  home.packages = with pkgs; [
    gimp
    helvum
    yt-dlp
  ];
}
