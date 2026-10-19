{
  inputs,
  pkgs,
  helpers,
  vars,
  ...
}:
let
  dms-wallpaper-selector = pkgs.makeDesktopItem {
    icon = "preferences-desktop-wallpaper";
    name = "wallpaper-selector";
    exec = "dms ipc call dash toggle wallpaper";
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
  dms-toggle-inhibit = pkgs.makeDesktopItem {
    icon = "caffeine-cup-full";
    name = "inhibit-toggle";
    exec = "dms ipc call inhibit toggle";
    desktopName = "Toggle Keep Awake";
    terminal = false;
  };
in
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms-plugin.nixosModules.default
  ];

  home.packages = with pkgs; [
    gpu-screen-recorder
    dms-wallpaper-selector
    dms-toggle-theme
    dms-toggle-inhibit
    jq
  ];

  programs.dank-material-shell = {
    enable = true;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    managePluginSettings = false;

    plugins = {
      dankKDEConnect.enable = true;
      hiddenBar.enable = true;
      systemMonitorPlus.enable = true;
      wallpaperCarousel.enable = true;
      fullscreenPowerMenu.enable = true;
      smartTimer.enable = true;
    };
  };

  # DMS sets Freedesktop/GTK `color-scheme` immediately on a theme toggle, but
  # matugen only rewrites ~/.config/gtk-4.0/dank-colors.css ~1-2s later. Running
  # GTK4 apps (Nautilus, ...) reload their CSS on the color-scheme change, so
  # they pick up the *old* colors and never reload when the file is rewritten,
  # making the theme lag one toggle behind (light in dark mode and vice versa).
  #
  # DMS_ENABLE_GTK_REFRESH makes the matugen worker do a color-scheme round-trip
  # *after* the CSS has been generated, forcing running GTK4 apps to reload with
  # the new colors. Chromium/Electron can latch the wrong mode with this, so drop
  # the env var if a browser misbehaves.
  systemd.user.services.dms.Service.Environment = [ "DMS_ENABLE_GTK_REFRESH=1" ];

  home.file = helpers.mkSymlinkedFiles [
    {
      target = ".config/DankMaterialShell/settings.json";
      source = "${vars.paths.homeFiles}/dms/settings.json";
    }
    {
      target = ".config/DankMaterialShell/plugin_settings.json";
      source = "${vars.paths.homeFiles}/dms/plugin_settings.json";
    }
  ];
}
