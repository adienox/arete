{
  inputs,
  pkgs,
  vars,
  config,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  extensions = inputs.vicinae-extensions.packages.${system};
  mkRayCastExtension = inputs.vicinae.lib.${system}.mkRayCastExtension;
in
{
  home.packages = with pkgs; [
    pulseaudio
    libsecret
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
      theme = {
        dark = {
          name = if config.programs.dank-material-shell.enable then "matugen" else "vicinae-dark";
          icon_theme = "Papirus";
        };
        light = {
          name = if config.programs.dank-material-shell.enable then "matugen" else "vicinae-light";
          icon_theme = "Papirus";
        };
      };
      launcher_window = {
        opacity = 0.7;
        layer_shell.layer = "overlay";
      };
      favorites = [
        "clipboard:history"
        "@mattisssa/spotify-player:yourLibrary"
        "@tonka3000/homeassistant:lights"
        "@rastsislaux/vicinae-extension-pulseaudio-0:outputDevices"
        "@leonkohli/vicinae-extension-process-manager-0:processes"
      ];

      fallbacks = [
        "files:search"
        "@mattisssa/spotify-player:search"
        "@knoopx/vicinae-extension-nix-0:packages"
        "@knoopx/vicinae-extension-nix-0:home-manager-options"
      ];

      providers = {
        applications.entrypoints = {
          cups.enabled = false;
          gvim.enabled = false;
          org-protocol.enabled = false;
          "org.kde.kdeconnect.nonplasma".enabled = false;
          "org.kde.kdeconnect.sms".enabled = false;
          scrcpy.enabled = false;
          scrcpy-console.enabled = false;
          vicinae.enabled = false;
          vim.enabled = false;
          yad-icon-browser.enabled = false;
          yad-settings.enabled = false;
        };
        core.entrypoints = {
          about.enabled = false;
          keybind-settings.enabled = false;
          list-extensions.enabled = false;
          open-config-file.enabled = false;
          open-default-config.enabled = false;
          report-bug.enabled = false;
          settings.enabled = false;
          sponsor.enabled = false;
        };

        "@tonka3000/homeassistant" = {
          preferences = {
            camerarefreshinterval = "3000";
            ignorecerts = false;
            instance = "https://home.chipmunk-teeth.ts.net";
            preferredapp = "browser";
            showEntityId = false;
            usePing = true;
          };
          entrypoints = {
            assist.enabled = false;
            attributes.enabled = false;
            batteries.enabled = false;
            binarysensors.enabled = false;
            buttons.enabled = false;
            calendar.enabled = false;
            cameras.enabled = false;
            climate.enabled = false;
            covers.enabled = false;
            customentities.enabled = false;
            dashboard.enabled = false;
            doors.enabled = false;
            fans.enabled = false;
            helpers.enabled = false;
            index.enabled = false;
            mediaplayers.enabled = false;
            motions.enabled = false;
            persons.enabled = false;
            runService.enabled = false;
            scenes.enabled = false;
            sensors.enabled = false;
            services.enabled = false;
            updates.enabled = false;
            vacuums.enabled = false;
            weather.enabled = false;
            windows.enabled = false;
            zones.enabled = false;
          };
        };
        "@samlinville/tailscale" = {
          preferences = {
            tailscalePath = "${pkgs.tailscale}/bin/tailscale";
          };
        };
        "@mattisssa/spotify-player" = {
          entrypoints = {
            yourLibrary.preferences."Default-View" = "all";
            search = {
              preferences = {
                musicOnly = true;
                topView = "tracks";
              };
            };
            startRadio.enable = true;
          };
        };
      };
    };

    extensions =
      with extensions;
      [
        bitwarden
        nix
        power-profile
        pulseaudio
        process-manager
        timer
      ]
      ++ (
        let
          raycastRev = "3c654737b0d566d3103fcdf72221a9f34664bdf2";
        in
        [
          (mkRayCastExtension {
            name = "homeassistant";
            rev = raycastRev;
            sha256 = "sha256-1C1rr2V/lGwsrt2T5WEF1I9GkHlxu3HtlVFFb93se4Q=";
          })
          (mkRayCastExtension {
            name = "spotify-player";
            rev = raycastRev;
            sha256 = "sha256-V/CY8/0IHb38JmQhzLuRa6AHnnRk8O9G0zVBv9W/tiw=";
          })
          (mkRayCastExtension {
            name = "tailscale";
            rev = raycastRev;
            sha256 = "sha256-RX2SyyPvG5RVxANGXymYIXEFzZq3koEcxWmPQcrPVig=";
          })
        ]
      );
  };
}
