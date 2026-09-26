{
  pkgs,
  vars,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    pulseaudio
    libsecret
  ];

  imports = [
    ./extensions.nix
    ./providers.nix
  ];

  programs.vicinae = {
    enable = true;

    systemd = {
      enable = true;
      autoStart = true;
      environment = {
        EMOJI_FONT = vars.fonts.emoji;
      };
    };

    settings = {
      favicon_service = "twenty";
      pop_to_root_on_close = false;
      search_files_in_root = false;
      close_on_focus_loss = true;
      font = {
        rendering = "native";
        normal = {
          family = vars.fonts.variable;
          size = 12.5;
        };
      };
      theme =
        let
          dms = config.programs.dank-material-shell.enable;
        in
        {
          dark = {
            name = if dms then "matugen" else "vicinae-dark";
            icon_theme = "Papirus";
          };
          light = {
            name = if dms then "matugen" else "vicinae-light";
            icon_theme = "Papirus";
          };
        };
      launcher_window = {
        opacity = 0.7;
        layer_shell.layer = "overlay";
      };
      favorites = [
        "clipboard:history"
        "@adienox/org-todos:list-tasks"
        "@mattisssa/spotify-player:yourLibrary"
        "@knoopx/home-assistant:home-assistant"
        "@semyon_surkov/freshrss:index"
        "@leonkohli/vicinae-extension-process-manager-0:processes"
      ];

      fallbacks = [
        "@adienox/org-todos:list-tasks"
        "files:search"
        "@mattisssa/spotify-player:search"
        "@knoopx/home-assistant:home-assistant"
        "@adienox/fmhy:search"
        "@knoopx/vicinae-extension-nix-0:packages"
        "@knoopx/vicinae-extension-nix-0:home-manager-options"
        "@knoopx/vicinae-extension-niri-0:keybinds"
      ];
    };
  };
}
