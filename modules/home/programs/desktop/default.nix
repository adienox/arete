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
    ./vicinae
    ./dms.nix
    ./dcal.nix
    ./xremap.nix
  ];

  services.kdeconnect.enable = true;

  home.packages = [
    phone-connect
  ];

  dconf.settings = {
    "org/gnome/nautilus/preferences" = {
      always-use-location-entry = true;
      show-create-link = true;
      show-delete-permanently = true;
    };

    "org/gnome/nautilus/icon-view" = {
      default-zoom-level = "standard";
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      sort-directories-first = true;
      show-hidden = true;
    };
  };
}
