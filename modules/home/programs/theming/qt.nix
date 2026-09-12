{
  pkgs,
  config,
  lib,
  vars,
  ...
}:
{
  home.packages = with pkgs; [
    libsForQt5.qt5ct
    kdePackages.qt6ct
  ];

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    qt5ctSettings = {
      Appearance = {
        custom_palette = true;
        icon_theme = "Papirus-Dark";
        standard_dialogs = "default";
        style = "Fusion";
        color_scheme_path = lib.mkForce "${config.xdg.configHome}/qt5ct/colors/matugen.conf";
      };
      Fonts = {
        fixed = "\"${vars.fonts.monospace},12\"";
        general = "\"${vars.fonts.variable},12\"";
      };
    };
    qt6ctSettings = {
      Appearance = {
        custom_palette = true;
        icon_theme = "Papirus-Dark";
        standard_dialogs = "default";
        style = "Fusion";
        color_scheme_path = lib.mkForce "${config.xdg.configHome}/qt5ct/colors/matugen.conf";
      };
      Fonts = {
        fixed = "\"${vars.fonts.monospace},12\"";
        general = "\"${vars.fonts.variable},12\"";
      };
    };
  };
}
