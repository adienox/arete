{
  config,
  ...
}:
{
  wayland.windowManager.niri.settings = {
    screenshot-path = "${config.xdg.userDirs.pictures}/Screenshots/%Y-%m-%d %H-%M-%S.png";

    cursor = {
      xcursor-theme = "Bibata-Modern-Ice";
      xcursor-size = 24;
      hide-when-typing = { };
    };

    debug = {
      emulate-zero-presentation-time = { };
      honor-xdg-activation-with-invalid-serial = { };
      render-drm-device = "/dev/dri/nvidia-dgpu";
      wait-for-frame-completion-before-queueing = { };
    };

    blur = {
      passes = 4;
      offset = 5.000000;
      noise = 0.020000;
      saturation = 2.000000;
    };

    input = {
      keyboard = {
        xkb = {
          layout = "";
          model = "";
          rules = "";
          variant = "";
          options = "compose:ralt";
        };

        repeat-delay = 600;
        repeat-rate = 25;
        track-layout = "global";
      };

      touchpad = {
        tap = { };
        dwt = { };
        drag-lock = { };
        natural-scroll = { };
      };

      mouse.natural-scroll = { };

      focus-follows-mouse._props.max-scroll-amount = "95%";
    };

    layout = {
      gaps = 5;

      struts = {
        left = 0;
        right = 0;
        top = 0;
        bottom = 0;
      };

      focus-ring.off = { };
      border.off = { };

      shadow = {
        on = { };

        offset._props = {
          x = 0;
          y = 5;
        };

        softness = 30;
        spread = 5;
        draw-behind-window = false;
        color = "#0007";
      };

      default-column-width.proportion = 0.500000;

      preset-column-widths._children = [
        { proportion = 0.333330; }
        { proportion = 0.500000; }
        { proportion = 0.666670; }
      ];

      center-focused-column = "never";
    };

    prefer-no-csd = { };

    hotkey-overlay.skip-at-startup = { };

    _children = [
      {
        output = {
          _args = [ "HDMI-A-1" ];
          scale = 1;
          focus-at-startup = { };
          transform = "normal";

          position._props = {
            x = 1920;
            y = 0;
          };

          mode = "2560x1440@144.002000";

          variable-refresh-rate._props = {
            on-demand = false;
          };
        };
      }

      {
        output = {
          _args = [ "eDP-1" ];
          scale = 1;
          transform = "normal";

          position._props = {
            x = 0;
            y = 0;
          };

          mode = "1920x1080@120.030000";
        };
      }

      {
        output = {
          _args = [ "eDP-2" ];
          scale = 1;
          transform = "normal";

          position._props = {
            x = 0;
            y = 0;
          };

          mode = "1920x1080@120.030000";
        };
      }

      {
        workspace = {
          _args = [ "web" ];
          open-on-output = "HDMI-A-1";
        };
      }

      {
        workspace = {
          _args = [ "editor" ];
          open-on-output = "HDMI-A-1";
        };
      }

      {
        workspace = {
          _args = [ "media" ];
          open-on-output = "HDMI-A-1";
        };
      }
    ]
    ++ (import ./rules.nix)
    ++ (import ./includes.nix { inherit config; });
  };
}
