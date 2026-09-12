{
  inputs,
  pkgs,
  vars,
  ...
}:
let
  extensions = inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system};
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
          name = "matugen";
          icon_theme = "Papirus";
        };
        light = {
          name = "matugen";
          icon_theme = "Papirus";
        };
      };
      launcher_window = {
        opacity = 0.7;
        layer_shell.layer = "overlay";
      };
      favorites = [
        "clipboard:history"
        "@mattisssa/store.raycast.spotify-player:yourLibrary"
        "@tonka3000/store.raycast.homeassistant:lights"
        "@knoopx/store.vicinae.nix:packages"
        "@rastsislaux/vicinae-extension-pulseaudio-0:outputDevices"
        "@leonkohli/vicinae-extension-process-manager-0:processes"
      ];

      fallbacks = [
        "shortcuts:sct-f126be0e1d67" # Brave Search
        "shortcuts:sct-75a4f4048446" # Youtube Search
        "@mattisssa/store.raycast.spotify-player:search"
        "@knoopx/store.vicinae.nix:packages"
        "@knoopx/store.vicinae.nix:home-manager-options"
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

        "@tonka3000/store.raycast.homeassistant" = {
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
        "@samlinville/store.raycast.tailscale" = {
          preferences = {
            tailscalePath = "${pkgs.tailscale}/bin/tailscale";
          };
        };
      };
    };

    # only vicinae extensions for now
    extensions = with extensions; [
      bitwarden
      nix
      power-profile
      pulseaudio
      process-manager
      timer
    ];
  };
}
