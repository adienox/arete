{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  niriPkgs = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    inputs.niri.homeModules.niri
    ./screenshot-url-tag.nix
    ./rules.nix
    ./binds.nix
  ];

  nixpkgs.overlays = [ inputs.niri.overlays.niri ];
  home.packages = with pkgs; [
    wl-clipboard
    xwayland-satellite
    playerctl
    bibata-cursors
    satty
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
    settings = {
      xwayland-satellite.path = lib.getExe niriPkgs.xwayland-satellite-unstable;

      blur = {
        passes = 4;
        offset = 5.0;
        noise = 0.02;
        saturation = 2.0;
      };

      cursor = {
        theme = "Bibata-Modern-Ice";
        size = 24;
        hide-when-typing = true;
      };

      input = {
        keyboard.xkb = {
          options = "compose:ralt";
        };

        touchpad = {
          tap = true;
          dwt = true;
          drag-lock = true;
          natural-scroll = true;
        };

        mouse = {
          natural-scroll = true;
        };

        warp-mouse-to-focus = {
          enable = true;
          mode = "center-xy";
        };

        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "95%";
        };
      };

      outputs = {
        "eDP-1" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 120.030;
          };
          scale = 1;
          position = {
            x = 0;
            y = 0;
          };
        };

        "HDMI-A-1" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 144.002;
          };
          variable-refresh-rate = true;
          scale = 1;
          position = {
            x = 1920;
            y = 0;
          };
          focus-at-startup = true;
        };
      };

      workspaces = {
        "01-web" = {
          name = "web";
          open-on-output = "HDMI-A-1";
        };
        "02-editor" = {
          name = "editor";
          open-on-output = "HDMI-A-1";
        };
        "03-notes" = {
          name = "notes";
          open-on-output = "HDMI-A-1";
        };
      };

      layout = {
        gaps = 5;
        center-focused-column = "never";

        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];

        default-column-width = {
          proportion = 0.5;
        };

        focus-ring = {
          enable = false;
        };

        border = {
          enable = false;
        };

        shadow = {
          enable = true;
          softness = 30;
          spread = 5;
          offset = {
            x = 0;
            y = 5;
          };
          color = "#0007";
        };

        struts = { };
      };

      prefer-no-csd = true;

      screenshot-path = "${config.xdg.userDirs.pictures}/Screenshots/%Y-%m-%d %H-%M-%S.png";

      animations = { };

      debug = {
        honor-xdg-activation-with-invalid-serial = [ ];
        emulate-zero-presentation-time = [ ];
        render-drm-device = "/dev/dri/nvidia-dgpu";
        wait-for-frame-completion-before-queueing = [ ];
      };

      hotkey-overlay.skip-at-startup = true;
    };
  };
}
