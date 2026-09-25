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
    inputs.dms-plugin-registry.nixosModules.default
  ];

  home.packages = with pkgs; [
    gpu-screen-recorder
    dms-wallpaper-selector
    dms-toggle-theme
    dms-toggle-inhibit
  ];

  programs.dank-material-shell = {
    enable = true;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    # niri.includes = {
    #   enable = true;
    #   override = true;
    #   originalFileName = "home-manager";
    #   filesToInclude = [
    #     "alttab"
    #     "binds"
    #     "colors"
    #     "layout"
    #     "outputs"
    #     "wpblur"
    #   ];
    # };

    managePluginSettings = false;

    plugins = {
      dankKDEConnect.enable = true;
      hiddenBar.enable = true;
      systemMonitorPlus.enable = true;
      wallpaperCarousel.enable = true;
      fullscreenPowerMenu.enable = true;
    };
  };

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
