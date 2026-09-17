{
  pkgs,
  vars,
  ...
}:
{
  programs.niri.settings.binds = {
    "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

    # Applications
    "Mod+Return" = {
      action.spawn-sh = "${pkgs.ghostty}/bin/ghostty +new-window";
      hotkey-overlay.title = "Open a Terminal: ghostty";
    };
    "Mod+W" = {
      action.spawn = "zen-twilight";
      hotkey-overlay.title = "Open Browser: Zen";
    };

    "Mod+Ctrl+P" = {
      action.spawn-sh = "${vars.paths.scripts}/pip.py same";
    };
    "Mod+Shift+P" = {
      action.spawn-sh = "${vars.paths.scripts}/pip.py side";
    };

    # Emacs
    "Mod+E" = {
      action.spawn-sh = "${vars.paths.scripts}/emacs.sh";
      hotkey-overlay.title = "Open Emacs: New Frame";
    };

    "Mod+D" = {
      action.spawn-sh = "dired";
      hotkey-overlay.title = "Open Dired";
    };

    "Ctrl+Alt+Tab" = {
      action.spawn-sh = "${pkgs.wl-mirror}/bin/wl-mirror $(niri msg --json focused-output | ${pkgs.jq}/bin/jq -r .name)";
      hotkey-overlay.title = "Mirror Screen";
    };

    "Mod+Space" = {
      action.spawn-sh = "vicinae toggle";
      hotkey-overlay.title = "Open Launcher: Applications";
    };
    "Mod+I" = {
      action.spawn-sh = "vicinae vicinae://launch/core/search-emojis";
      hotkey-overlay.title = "Open Launcher: Emoji";
    };
    "Mod+P" = {
      action.spawn-sh = "vicinae vicinae://launch/@bl4zee1g/vicinae-extension-bitwarden-0/browse-vault";
      hotkey-overlay.title = "Open Launcher: Bitwarden";
    };
    "Mod+Shift+W" = {
      action.spawn-sh = "dms ipc wallpaperCarousel toggle";
      hotkey-overlay.title = "Open Launcher: Wallpaper";
    };
    "Ctrl+Alt+Delete" = {
      action.spawn-sh = "dms ipc call fullscreenPowerMenu toggle";
      hotkey-overlay.title = "Open Launcher: Session Menu";
    };
    "Mod+X" = {
      action.spawn-sh = "${pkgs.elogind}/bin/loginctl lock-session";
      hotkey-overlay.title = "Lock Screen";
    };
    "Ctrl+Alt+Comma" = {
      action.spawn-sh = "${vars.paths.scripts}/screenshot-annotate.sh";
      hotkey-overlay.title = "Annotate last screenshot";
    };

    "XF86Calculator" = {
      action.spawn = "gnome-calculator";
      hotkey-overlay.title = "Open Calculator";
    };

    "XF86AudioRaiseVolume" = {
      action.spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
      allow-when-locked = true;
    };
    "XF86AudioLowerVolume" = {
      action.spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      allow-when-locked = true;
    };
    "XF86AudioMute" = {
      action.spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      allow-when-locked = true;
    };
    "XF86AudioMicMute" = {
      action.spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      allow-when-locked = true;
    };

    "XF86AudioPlay" = {
      action.spawn-sh = "${pkgs.playerctl}/bin/playerctl -i kdeconnect play-pause";
      allow-when-locked = true;
    };
    "XF86AudioStop" = {
      action.spawn-sh = "${pkgs.playerctl}/bin/playerctl -i kdeconnect stop";
      allow-when-locked = true;
    };
    "XF86AudioPrev" = {
      action.spawn-sh = "${pkgs.playerctl}/bin/playerctl -i kdeconnect previous";
      allow-when-locked = true;
    };
    "XF86AudioNext" = {
      action.spawn-sh = "${pkgs.playerctl}/bin/playerctl -i kdeconnect next";
      allow-when-locked = true;
    };

    "XF86MonBrightnessUp" = {
      action.spawn-sh = "${vars.paths.scripts}/brightness.sh increment";
      allow-when-locked = true;
    };
    "XF86MonBrightnessDown" = {
      action.spawn-sh = "${vars.paths.scripts}/brightness.sh decrement";
      allow-when-locked = true;
    };
    "Shift+XF86AudioRaiseVolume" = {
      action.spawn-sh = "${vars.paths.scripts}/brightness.sh increment";
      allow-when-locked = true;
    };
    "Shift+XF86AudioLowerVolume" = {
      action.spawn-sh = "${vars.paths.scripts}/brightness.sh decrement";
      allow-when-locked = true;
    };

    "Mod+O" = {
      action.toggle-overview = [ ];
      repeat = false;
    };
    "Mod+Q" = {
      action.close-window = [ ];
      repeat = false;
    };

    "Mod+H".action.focus-column-or-monitor-left = [ ];
    "Mod+J".action.focus-window-down = [ ];
    "Mod+K".action.focus-window-up = [ ];
    "Mod+L".action.focus-column-or-monitor-right = [ ];

    "Mod+Ctrl+H".action.move-column-left = [ ];
    "Mod+Ctrl+J".action.move-window-down = [ ];
    "Mod+Ctrl+K".action.move-window-up = [ ];
    "Mod+Ctrl+L".action.move-column-right = [ ];

    "Mod+Home".action.focus-column-first = [ ];
    "Mod+End".action.focus-column-last = [ ];
    "Mod+Ctrl+Home".action.move-column-to-first = [ ];
    "Mod+Ctrl+End".action.move-column-to-last = [ ];

    "Mod+Shift+H".action.focus-monitor-left = [ ];
    "Mod+Shift+J".action.focus-monitor-down = [ ];
    "Mod+Shift+K".action.focus-monitor-up = [ ];
    "Mod+Shift+L".action.focus-monitor-right = [ ];

    "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
    "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
    "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
    "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];

    "Mod+Page_Down".action.focus-workspace-down = [ ];
    "Mod+Page_Up".action.focus-workspace-up = [ ];
    "Mod+U".action.focus-workspace-down = [ ];
    "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
    "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
    "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
    "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];

    "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
    "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
    "Mod+Shift+U".action.move-workspace-down = [ ];
    "Mod+Shift+I".action.move-workspace-up = [ ];

    "Mod+WheelScrollDown" = {
      action.focus-workspace-down = [ ];
      cooldown-ms = 150;
    };
    "Mod+WheelScrollUp" = {
      action.focus-workspace-up = [ ];
      cooldown-ms = 150;
    };
    "Mod+Ctrl+WheelScrollDown" = {
      action.move-column-to-workspace-down = [ ];
      cooldown-ms = 150;
    };
    "Mod+Ctrl+WheelScrollUp" = {
      action.move-column-to-workspace-up = [ ];
      cooldown-ms = 150;
    };

    "Mod+WheelScrollRight".action.focus-column-right = [ ];
    "Mod+WheelScrollLeft".action.focus-column-left = [ ];
    "Mod+Ctrl+WheelScrollRight".action.move-column-right = [ ];
    "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [ ];

    "Mod+Shift+WheelScrollDown".action.focus-column-right = [ ];
    "Mod+Shift+WheelScrollUp".action.focus-column-left = [ ];
    "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [ ];
    "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [ ];

    "Mod+1".action.focus-workspace = 1;
    "Mod+2".action.focus-workspace = 2;
    "Mod+3".action.focus-workspace = 3;
    "Mod+4".action.focus-workspace = 4;
    "Mod+5".action.focus-workspace = 5;
    "Mod+6".action.focus-workspace = 6;
    "Mod+7".action.focus-workspace = 7;
    "Mod+8".action.focus-workspace = 8;
    "Mod+9".action.focus-workspace = 9;

    "Mod+Shift+1".action.move-column-to-workspace = 1;
    "Mod+Shift+2".action.move-column-to-workspace = 2;
    "Mod+Shift+3".action.move-column-to-workspace = 3;
    "Mod+Shift+4".action.move-column-to-workspace = 4;
    "Mod+Shift+5".action.move-column-to-workspace = 5;
    "Mod+Shift+6".action.move-column-to-workspace = 6;
    "Mod+Shift+7".action.move-column-to-workspace = 7;
    "Mod+Shift+8".action.move-column-to-workspace = 8;
    "Mod+Shift+9".action.move-column-to-workspace = 9;

    "Mod+T".action.toggle-column-tabbed-display = [ ];
    "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
    "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
    "Mod+Comma".action.consume-window-into-column = [ ];
    "Mod+Period".action.expel-window-from-column = [ ];

    "Mod+R".action.switch-preset-column-width = [ ];
    "Mod+Shift+R".action.switch-preset-window-height = [ ];
    "Mod+Ctrl+R".action.reset-window-height = [ ];
    "Mod+F".action.maximize-column = [ ];
    "Mod+Shift+F".action.fullscreen-window = [ ];
    "F11".action.fullscreen-window = [ ];
    "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];
    "Mod+C".action.center-column = [ ];
    "Mod+Ctrl+C".action.center-visible-columns = [ ];

    "Mod+Minus".action.set-column-width = "-10%";
    "Mod+Equal".action.set-column-width = "+10%";
    "Mod+Shift+Minus".action.set-window-height = "-10%";
    "Mod+Shift+Equal".action.set-window-height = "+10%";

    "Mod+V".action.toggle-window-floating = [ ];
    "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];

    "XF86SelectiveScreenshot".action.screenshot = [ ];
    "Print".action.screenshot-screen = [ ];
    "Shift+Print".action.screenshot = [ ];
    "Alt+Print".action.screenshot-window = [ ];

    "Mod+Escape" = {
      action.toggle-keyboard-shortcuts-inhibit = [ ];
      allow-inhibiting = false;
    };
  };
}
