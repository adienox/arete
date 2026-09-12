{ pkgs, vars, ... }:
let
  phone-connect = pkgs.makeDesktopItem {
    icon = "smartphone";
    name = "phone-connect";
    exec = "${pkgs.bash}/bin/bash ${vars.paths.scripts}/phone-connect";
    desktopName = "Phone Connect";
    terminal = false;
  };
in
{
  imports = [
    ./niri
    ./dms.nix
    ./vicinae.nix
    ./xremap.nix
  ];

  services.kdeconnect.enable = true;

  home.packages = [
    phone-connect
  ];
}
