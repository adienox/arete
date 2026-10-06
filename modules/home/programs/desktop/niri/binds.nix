{
  pkgs,
  lib,
  vars,
  osConfig ? null,
  ...
}:
let
  scripts = vars.paths.scripts;
  uwsm = osConfig != null && (osConfig.programs.uwsm.enable or false);

  # ── applications (long-running / GUI: get their own scope under uwsm) ──
  appBinds = lib.mapAttrs (_: wrap) {
    "Mod+Return" = titled "Open a Terminal: ghostty" {
      spawn-sh = [ "${pkgs.ghostty}/bin/ghostty +new-window" ];
    };
    "Mod+E" = titled "Open Emacs: New Frame" {
      spawn-sh = [ "${scripts}/emacs.sh" ];
    };
    "Mod+W" = titled "Open Browser: Zen" {
      spawn = [ "zen-twilight" ];
    };
    "Mod+D" = titled "Open Dired" {
      spawn-sh = [ "dired" ];
    };
    "XF86Calculator" = titled "Open Calculator" {
      spawn-sh = [ "${pkgs.gnome-calculator}/bin/gnome-calculator" ];
    };
    "Ctrl+Alt+Tab" = titled "Mirror Screen" {
      spawn-sh = [ "${scripts}/wl-mirror.sh" ];
    };
  };

  # ── launchers and overlays (quick IPC calls, not wrapped) ──────────────
  launcherBinds = {
    "Mod+Space" = titled "Open Launcher: Applications" {
      spawn-sh = [ "vicinae toggle" ];
    };
    "Mod+I" = titled "Open Launcher: Emoji" {
      spawn-sh = [ "vicinae vicinae://launch/core/search-emojis" ];
    };
    "Mod+Backslash" = titled "Open Emacs: Journal" {
      spawn-sh = [
        "emacsclient -c -F '((name . \"emacs-float\"))' -e '(denote-journal-new-or-existing-entry)'"
      ];
    };
    "Mod+P" = titled "Open Launcher: Bitwarden" {
      spawn-sh = [
        "vicinae vicinae://launch/@bl4zee1g/vicinae-extension-bitwarden-0/browse-vault"
      ];
    };
    "Mod+Shift+W" = titled "Open Launcher: Wallpaper" {
      spawn-sh = [ "dms ipc call dash toggle wallpaper" ];
    };
    "Mod+Shift+O" = titled "Open Launcher: Overview" {
      spawn-sh = [ "dms ipc call dash toggle overview" ];
    };
    "Ctrl+Alt+Delete" = titled "Open Launcher: Session Menu" {
      spawn-sh = [ "dms ipc call fullscreenPowerMenu toggle" ];
    };
  };

  # ── session / compositor ───────────────────────────────────────────────
  sessionBinds = {
    "Mod+Shift+Slash" = titled "Show Hotkey Overlay" { show-hotkey-overlay = { }; };
    "Mod+O" = titledWith "Toggle Overview" { repeat = false; } {
      toggle-overview = { };
    };
    "Mod+X" = titled "Lock Screen" {
      spawn-sh = [ "${pkgs.elogind}/bin/loginctl lock-session" ];
    };
    "Mod+Escape" = titledWith "Toggle Keyboard Shortcuts Inhibit" { allow-inhibiting = false; } {
      toggle-keyboard-shortcuts-inhibit = { };
    };
  };

  # ── screenshots ────────────────────────────────────────────────────────
  screenshotBinds = {
    "Print" = titled "Screenshot: Screen" { screenshot-screen = { }; };
    "Shift+Print" = titled "Screenshot: Select Area" { screenshot = { }; };
    "Alt+Print" = titled "Screenshot: Window" { screenshot-window = { }; };
    "XF86SelectiveScreenshot" = titled "Screenshot: Select Area" {
      screenshot = { };
    };
    "Ctrl+Alt+Comma" = titled "Annotate Last Screenshot" {
      spawn-sh = [ "${scripts}/screenshot-annotate.sh" ];
    };
  };

  # ── media, volume, brightness ──────────────────────────────────────────
  mediaBinds = {
    "XF86AudioRaiseVolume" = titledWith "Volume Up" { allow-when-locked = true; } {
      spawn-sh = [ "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+" ];
    };
    "XF86AudioLowerVolume" = titledWith "Volume Down" { allow-when-locked = true; } {
      spawn-sh = [ "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" ];
    };
    "XF86AudioMute" = titledWith "Mute Audio" { allow-when-locked = true; } {
      spawn-sh = [ "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" ];
    };
    "XF86AudioMicMute" = titledWith "Mute Microphone" { allow-when-locked = true; } {
      spawn-sh = [ "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" ];
    };

    "XF86AudioPlay" = titledWith "Media: Play/Pause" { allow-when-locked = true; } {
      spawn-sh = [ "${pkgs.playerctl}/bin/playerctl -i kdeconnect play-pause" ];
    };
    "XF86AudioNext" = titledWith "Media: Next" { allow-when-locked = true; } {
      spawn-sh = [ "${pkgs.playerctl}/bin/playerctl -i kdeconnect next" ];
    };
    "XF86AudioPrev" = titledWith "Media: Previous" { allow-when-locked = true; } {
      spawn-sh = [ "${pkgs.playerctl}/bin/playerctl -i kdeconnect previous" ];
    };
    "XF86AudioStop" = titledWith "Media: Stop" { allow-when-locked = true; } {
      spawn-sh = [ "${pkgs.playerctl}/bin/playerctl -i kdeconnect stop" ];
    };

    "XF86MonBrightnessUp" = titledWith "Brightness Up" { allow-when-locked = true; } {
      spawn-sh = [ "${scripts}/brightness.sh increment" ];
    };
    "XF86MonBrightnessDown" = titledWith "Brightness Down" { allow-when-locked = true; } {
      spawn-sh = [ "${scripts}/brightness.sh decrement" ];
    };
    "Shift+XF86AudioRaiseVolume" = titledWith "Brightness Up" { allow-when-locked = true; } {
      spawn-sh = [ "${scripts}/brightness.sh increment" ];
    };
    "Shift+XF86AudioLowerVolume" = titledWith "Brightness Down" { allow-when-locked = true; } {
      spawn-sh = [ "${scripts}/brightness.sh decrement" ];
    };
  };

  # ── focus ──────────────────────────────────────────────────────────────
  focusBinds = {
    "Mod+H" = titled "Focus Column/Monitor Left" { focus-column-or-monitor-left = { }; };
    "Mod+L" = titled "Focus Column/Monitor Right" { focus-column-or-monitor-right = { }; };
    "Mod+J" = titled "Focus Window Down" { focus-window-down = { }; };
    "Mod+K" = titled "Focus Window Up" { focus-window-up = { }; };
    "Mod+Home" = titled "Focus First Column" { focus-column-first = { }; };
    "Mod+End" = titled "Focus Last Column" { focus-column-last = { }; };
  };

  # ── moving columns and windows ─────────────────────────────────────────
  moveBinds = {
    "Mod+Ctrl+H" = titled "Move Column Left" { move-column-left = { }; };
    "Mod+Ctrl+L" = titled "Move Column Right" { move-column-right = { }; };
    "Mod+Ctrl+J" = titled "Move Window Down" { move-window-down = { }; };
    "Mod+Ctrl+K" = titled "Move Window Up" { move-window-up = { }; };
    "Mod+Ctrl+Home" = titled "Move Column to First" { move-column-to-first = { }; };
    "Mod+Ctrl+End" = titled "Move Column to Last" { move-column-to-last = { }; };

    "Mod+BracketLeft" = titled "Consume/Expel Window Left" {
      consume-or-expel-window-left = { };
    };
    "Mod+BracketRight" = titled "Consume/Expel Window Right" {
      consume-or-expel-window-right = { };
    };
    "Mod+Comma" = titled "Consume Window into Column" { consume-window-into-column = { }; };
    "Mod+Period" = titled "Expel Window from Column" { expel-window-from-column = { }; };
  };

  # ── window state, layout and sizing ────────────────────────────────────
  windowBinds = {
    "Mod+Q" = titledWith "Close Window" { repeat = false; } { close-window = { }; };

    "Mod+F" = titled "Maximize Column" { maximize-column = { }; };
    "Mod+Shift+F" = titled "Fullscreen Window" { fullscreen-window = { }; };
    "F11" = titled "Fullscreen Window" { fullscreen-window = { }; };
    "Mod+Ctrl+F" = titled "Expand Column to Available Width" {
      expand-column-to-available-width = { };
    };

    "Mod+C" = titled "Center Column" { center-column = { }; };
    "Mod+Ctrl+C" = titled "Center Visible Columns" { center-visible-columns = { }; };

    "Mod+Equal" = titled "Column Width +10%" { set-column-width = [ "+10%" ]; };
    "Mod+Minus" = titled "Column Width -10%" { set-column-width = [ "-10%" ]; };
    "Mod+Shift+Equal" = titled "Window Height +10%" { set-window-height = [ "+10%" ]; };
    "Mod+Shift+Minus" = titled "Window Height -10%" { set-window-height = [ "-10%" ]; };
    "Mod+Shift+R" = titled "Cycle Window Height Presets" { switch-preset-window-height = { }; };
    "Mod+Ctrl+R" = titled "Reset Window Height" { reset-window-height = { }; };

    "Mod+T" = titled "Toggle Tabbed Column" { toggle-column-tabbed-display = { }; };
    "Mod+V" = titled "Toggle Floating" { toggle-window-floating = { }; };
    "Mod+Shift+V" = titled "Switch Focus: Floating/Tiling" {
      switch-focus-between-floating-and-tiling = { };
    };

    "Mod+Ctrl+P" = titled "Picture-in-Picture: Same Size" {
      spawn-sh = [ "${scripts}/pip.py same" ];
    };
    "Mod+Shift+P" = titled "Picture-in-Picture: Side" {
      spawn-sh = [ "${scripts}/pip.py side" ];
    };
  };

  # ── workspaces ─────────────────────────────────────────────────────────
  workspaceBinds = {
    "Mod+U" = titled "Focus Workspace Down" { focus-workspace-down = { }; };
    "Mod+Page_Down" = titled "Focus Workspace Down" { focus-workspace-down = { }; };
    "Mod+Page_Up" = titled "Focus Workspace Up" { focus-workspace-up = { }; };

    "Mod+Ctrl+U" = titled "Move Column to Workspace Down" {
      move-column-to-workspace-down = { };
    };
    "Mod+Ctrl+I" = titled "Move Column to Workspace Up" {
      move-column-to-workspace-up = { };
    };
    "Mod+Ctrl+Page_Down" = titled "Move Column to Workspace Down" {
      move-column-to-workspace-down = { };
    };
    "Mod+Ctrl+Page_Up" = titled "Move Column to Workspace Up" {
      move-column-to-workspace-up = { };
    };

    "Mod+Shift+U" = titled "Move Workspace Down" { move-workspace-down = { }; };
    "Mod+Shift+I" = titled "Move Workspace Up" { move-workspace-up = { }; };
    "Mod+Shift+Page_Down" = titled "Move Workspace Down" { move-workspace-down = { }; };
    "Mod+Shift+Page_Up" = titled "Move Workspace Up" { move-workspace-up = { }; };
  }
  # Mod+1..9 focus, Mod+Shift+1..9 move column
  // lib.listToAttrs (
    lib.concatMap (
      n:
      let
        s = toString n;
      in
      [
        {
          name = "Mod+${s}";
          value = titled "Focus Workspace ${s}" { focus-workspace = n; };
        }
        {
          name = "Mod+Shift+${s}";
          value = titled "Move Column to Workspace ${s}" {
            move-column-to-workspace = n;
          };
        }
      ]
    ) (lib.range 1 9)
  );

  # ── monitors ───────────────────────────────────────────────────────────
  monitorBinds = {
    "Mod+Shift+H" = titled "Focus Monitor Left" { focus-monitor-left = { }; };
    "Mod+Shift+L" = titled "Focus Monitor Right" { focus-monitor-right = { }; };
    "Mod+Shift+J" = titled "Focus Monitor Down" { focus-monitor-down = { }; };
    "Mod+Shift+K" = titled "Focus Monitor Up" { focus-monitor-up = { }; };

    "Mod+Shift+Ctrl+H" = titled "Move Column to Monitor Left" {
      move-column-to-monitor-left = { };
    };
    "Mod+Shift+Ctrl+L" = titled "Move Column to Monitor Right" {
      move-column-to-monitor-right = { };
    };
    "Mod+Shift+Ctrl+J" = titled "Move Column to Monitor Down" {
      move-column-to-monitor-down = { };
    };
    "Mod+Shift+Ctrl+K" = titled "Move Column to Monitor Up" {
      move-column-to-monitor-up = { };
    };
  };

  wheelBinds = {
    "Mod+WheelScrollDown" = hideWith { cooldown-ms = 150; } { focus-workspace-down = { }; };
    "Mod+WheelScrollUp" = hideWith { cooldown-ms = 150; } { focus-workspace-up = { }; };
    "Mod+WheelScrollLeft" = hide { focus-column-left = { }; };
    "Mod+WheelScrollRight" = hide { focus-column-right = { }; };

    "Mod+Shift+WheelScrollDown" = hide { focus-column-right = { }; };
    "Mod+Shift+WheelScrollUp" = hide { focus-column-left = { }; };

    "Mod+Ctrl+WheelScrollDown" = hideWith { cooldown-ms = 150; } {
      move-column-to-workspace-down = { };
    };
    "Mod+Ctrl+WheelScrollUp" = hideWith { cooldown-ms = 150; } {
      move-column-to-workspace-up = { };
    };
    "Mod+Ctrl+WheelScrollLeft" = hide { move-column-left = { }; };
    "Mod+Ctrl+WheelScrollRight" = hide { move-column-right = { }; };

    "Mod+Ctrl+Shift+WheelScrollDown" = hide { move-column-right = { }; };
    "Mod+Ctrl+Shift+WheelScrollUp" = hide { move-column-left = { }; };
  };

  # ── helpers ────────────────────────────────────────────────────────────
  # Add a hotkey-overlay title to a bind.
  titled = title: action: { _props.hotkey-overlay-title = title; } // action;

  # Same, with extra bind properties (repeat, cooldown-ms, allow-when-locked...).
  titledWith =
    title: props: action:
    {
      _props = {
        hotkey-overlay-title = title;
      }
      // props;
    }
    // action;

  # Hide a bind from the overlay (niri: hotkey-overlay-title=null).
  hide = titled null;
  hideWith = titledWith null;

  # Prefix spawn / spawn-sh binds with `uwsm app --` when uwsm is enabled.
  # Identity when uwsm is off, so output matches a non-uwsm setup.
  wrap =
    bind:
    if !uwsm then
      bind
    else
      bind
      // lib.optionalAttrs (bind ? spawn-sh) {
        spawn-sh = map (c: "uwsm app -- ${c}") bind.spawn-sh;
      }
      // lib.optionalAttrs (bind ? spawn) {
        spawn = [
          "uwsm"
          "app"
          "--"
        ]
        ++ bind.spawn;
      };

in
{
  wayland.windowManager.niri.settings.binds =
    appBinds
    // launcherBinds
    // sessionBinds
    // screenshotBinds
    // mediaBinds
    // focusBinds
    // moveBinds
    // windowBinds
    // workspaceBinds
    // monitorBinds
    // wheelBinds;
}
