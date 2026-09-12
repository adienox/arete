{ ... }:
{
  programs.niri.settings = {
    window-rules = [
      # Open picture-in-picture as floating
      {
        matches = [
          {
            title = "^Picture-in-Picture$";
          }
        ];
        open-floating = true;

        default-floating-position = {
          x = 5;
          y = 5;
          relative-to = "bottom-right";
        };

        default-column-width.fixed = 650;
        default-window-height.fixed = 365;
        open-focused = false;
      }

      {
        background-effect = {
          blur = true;
          xray = true;
        };
      }

      # Mirror window
      {
        matches = [
          { app-id = "at.yrlf.wl_mirror"; }
        ];
        open-fullscreen = true;
        open-on-output = "HDMI-A-1";
      }
      {
        matches = [
          { app-id = "yad"; }
        ];
        open-floating = true;
      }
      # KDE Connect presentation remote
      {
        matches = [
          { app-id = "org\\.kde\\.kdeconnect\\.daemon"; }
        ];
        open-floating = true;
        open-fullscreen = false;
        default-floating-position = {
          x = 0;
          y = 0;
          relative-to = "top-left";
        };
        min-height = 1080;
        min-width = 1920;
        opacity = 0.7;
        focus-ring.enable = false;
        border.enable = false;
        shadow.enable = false;
        draw-border-with-background = false;
      }
      {
        matches = [
          { app-id = "org.gnome.NautilusPreviewer"; }
          { app-id = "com.gabm.satty"; }
          { app-id = "imv"; }
        ];
        open-floating = true;

        default-column-width.fixed = 1150;
        default-window-height.fixed = 800;
      }
      {
        matches = [
          {
            app-id = "org.gnome.Calculator";
          }
        ];
        open-floating = true;

        default-column-width.fixed = 450;
        default-window-height.fixed = 760;
      }
      # floating info windows
      {
        matches = [
          { title = "^agenda$"; }
          { title = "^emacs-capture$"; }
          {
            app-id = "zen-twilight";
            title = "Extension";
          }
        ];
        open-floating = true;

        default-column-width.fixed = 1100;
        default-window-height.fixed = 650;
      }
      # kdeconnect reply window
      {
        matches = [
          { app-id = "org.kde.kdeconnect.daemon"; }
        ];
        open-floating = true;

        default-column-width.fixed = 380;
        default-window-height.fixed = 200;
      }
      # full width windows
      {
        matches = [
          { app-id = "emacs"; }
          { app-id = "spotify"; }
          { app-id = "org.gnome.Nautilus"; }
          { app-id = "org.freecad.FreeCAD"; }
          { app-id = "Spotify"; }
          { app-id = "zen-twilight"; }
          { app-id = "org.pipewire.Helvum"; }
        ];
        excludes = [
          { title = "Extension"; }
        ];
        open-maximized = true;
      }
      {
        matches = [
          { app-id = "zen-twilight"; }
        ];
        open-on-workspace = "web";
        opacity = 0.9999;
      }

      {
        matches = [
          { app-id = ".scrcpy-wrapped"; }
        ];
        open-floating = true;

        default-column-width.fixed = 448;
        default-window-height.fixed = 1000;
      }
      {
        matches = [
          {
            app-id = "emacs";
            title = "emacs-main";
          }
        ];
        open-on-workspace = "editor";
      }
      {
        matches = [
          { app-id = "obsidian"; }
        ];
        open-on-workspace = "notes";
        open-focused = false;
      }
      {
        matches = [
          {
            title = "^FreeCAD$";
            app-id = "org.freecad.FreeCAD";
          }
        ];
        open-floating = true;
        default-column-width.fixed = 580;
        default-window-height.fixed = 500;
        shadow.enable = false;
      }
      # screencasted window with red shadow
      {
        matches = [
          {
            is-window-cast-target = true;
          }
        ];
        shadow.color = "#7d0d2d70";
        tab-indicator = {
          active.color = "#f38ba8";
          inactive.color = "#7d0d2d";
        };
      }
      # Rounded corners for all windows
      {
        geometry-corner-radius =
          let
            r = 12.0;
          in
          {
            top-left = r;
            top-right = r;
            bottom-left = r;
            bottom-right = r;
          };
        clip-to-geometry = true;
      }
    ];

    layer-rules = [
      {
        background-effect = {
          xray = false;
        };
      }
    ];
  };
}
