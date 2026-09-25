[
  {
    window-rule._children = [
      { match._props.title = "^Picture-in-Picture$"; }

      {
        default-column-width.fixed = 650;
        default-window-height.fixed = 365;
        open-floating = true;
        open-focused = false;
        default-floating-position._props = {
          relative-to = "bottom-right";
          x = 5;
          y = 5;
        };
      }
    ];
  }

  {
    window-rule._children = [
      { match._props.app-id = "at.yrlf.wl_mirror"; }

      {
        open-on-output = "HDMI-A-1";
        open-fullscreen = true;
      }
    ];
  }

  {
    window-rule._children = [
      { match._props.app-id = "yad"; }

      { open-floating = true; }
    ];
  }

  {
    window-rule._children = [
      { match._props.app-id = "org\\.kde\\.kdeconnect\\.daemon"; }

      {
        open-fullscreen = false;
        open-floating = true;
        draw-border-with-background = false;
        border.off = { };
        focus-ring.off = { };
        shadow.off = { };
        opacity = 0.700000;
        min-width = 1920;
        min-height = 1080;
        default-floating-position._props = {
          relative-to = "top-left";
          x = 0;
          y = 0;
        };
      }
    ];
  }

  {
    window-rule._children = [
      { match._props.app-id = "org.gnome.NautilusPreviewer"; }
      { match._props.app-id = "com.gabm.satty"; }
      { match._props.app-id = "imv"; }

      {
        default-column-width.fixed = 1150;
        default-window-height.fixed = 800;
        open-floating = true;
      }
    ];
  }

  {
    window-rule._children = [
      { match._props.app-id = "org.gnome.Calculator"; }

      {
        default-column-width.fixed = 450;
        default-window-height.fixed = 760;
        open-floating = true;
      }
    ];
  }

  {
    window-rule._children = [
      { match._props.title = "^agenda$"; }
      { match._props.title = "^emacs-capture$"; }
      { match._props.title = "^emacs-float$"; }

      {
        default-column-width.fixed = 1100;
        default-window-height.fixed = 650;
        open-floating = true;
      }
    ];
  }

  {
    window-rule._children = [
      { match._props.app-id = "org.kde.kdeconnect.daemon"; }

      {
        default-column-width.fixed = 380;
        default-window-height.fixed = 200;
        open-floating = true;
      }
    ];
  }

  {
    window-rule._children = [
      { match._props.app-id = "emacs"; }
      { match._props.app-id = "spotify"; }
      { match._props.app-id = "org.gnome.Nautilus"; }
      { match._props.app-id = "org.freecad.FreeCAD"; }
      { match._props.app-id = "Spotify"; }
      { match._props.app-id = "zen-twilight"; }
      { match._props.app-id = "org.pipewire.Helvum"; }
      { match._props.app-id = "btop.desktop"; }

      { open-maximized = true; }
    ];
  }

  {
    window-rule._children = [
      { match._props.app-id = "zen-twilight"; }

      {
        open-on-workspace = "web";
        opacity = 0.999900;
      }
    ];
  }

  {
    window-rule._children = [
      { match._props.app-id = ".scrcpy-wrapped"; }

      {
        default-column-width.fixed = 448;
        default-window-height.fixed = 1000;
        open-floating = true;
      }
    ];
  }

  {
    window-rule._children = [
      {
        match._props = {
          app-id = "emacs";
          title = "emacs-main";
        };
      }

      { open-on-workspace = "editor"; }
    ];
  }

  {
    window-rule._children = [
      { match._props.app-id = "obsidian"; }

      {
        open-on-workspace = "notes";
        open-focused = false;
      }
    ];
  }

  {
    window-rule._children = [
      {
        match._props = {
          app-id = "org.freecad.FreeCAD";
          title = "^FreeCAD$";
        };
      }

      {
        default-column-width.fixed = 580;
        default-window-height.fixed = 500;
        open-floating = true;
        shadow.off = { };
      }
    ];
  }

  {
    window-rule._children = [
      { match._props.is-window-cast-target = true; }

      {
        shadow.color = "#7d0d2d70";
        tab-indicator = {
          active-color = "#f38ba8";
          inactive-color = "#7d0d2d";
        };
      }
    ];
  }

  {
    window-rule = {
      geometry-corner-radius = [
        12.000000
        12.000000
        12.000000
        12.000000
      ];
      clip-to-geometry = true;
      background-effect = {
        blur = true;
        xray = true;
      };
    };
  }

  { layer-rule.background-effect.xray = false; }

  {
    layer-rule._children = [
      { match._props.namespace = "dms:blurwallpaper"; }
      { place-within-backdrop = true; }
    ];
  }
]
