{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
{
  gtk = {
    enable = true;

    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    font = {
      name = vars.fonts.variable;
      size = 12;
    };

    theme = {
      name = lib.mkForce "adw-gtk3";
      package = lib.mkForce pkgs.adw-gtk3;
    };

    gtk3.bookmarks = [
      "file://${config.home.homeDirectory}/Documents"
      "file://${config.home.homeDirectory}/Documents/projects Projects"
      "sftp://impel/home/nox Impel"
      "sftp://hawk/data/data/com.termux/files/home/storage/shared Hawk"
      "sftp://kindle/mnt/us/koreader Kindle"
    ];

    gtk3.theme = {
      name = lib.mkForce "adw-gtk3";
      package = lib.mkForce pkgs.adw-gtk3;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };
}
