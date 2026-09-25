{
  inputs,
  pkgs,
  vars,
  config,
  osConfig,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  extensions = inputs.vicinae-extensions.packages.${system};
  mkRayCastExtension = inputs.vicinae.lib.${system}.mkRayCastExtension;
  mkExtension = inputs.vicinae.lib.${system}.mkVicinaeExtension;
  uwsm = osConfig != null && (osConfig.programs.uwsm.enable or false);
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
        "@adienox/org-todos:list-tasks"
        "@mattisssa/spotify-player:yourLibrary"
        "@knoopx/home-assistant:home-assistant"
        "@semyon_surkov/freshrss:index"
        "@leonkohli/vicinae-extension-process-manager-0:processes"
      ];

      fallbacks = [
        "@adienox/org-todos:quick-add"
        "files:search"
        "@mattisssa/spotify-player:search"
        "@knoopx/home-assistant:home-assistant"
        "@adienox/fmhy:search"
        "@knoopx/vicinae-extension-nix-0:packages"
        "@knoopx/vicinae-extension-nix-0:home-manager-options"
      ];

      providers = {
        applications.preferences.launchPrefix = if uwsm then "uwsm app --" else "";
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

        "@samlinville/tailscale" = {
          preferences = {
            tailscalePath = "${pkgs.tailscale}/bin/tailscale";
          };
        };

        "@dagimg-dot/vicinae-extension-wifi-commander-0" = {
          preferences = {
            "network-cli-tool" = "nmcli";
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
        "@adienox/org-todos" = {
          preferences = {
            editorCommand = "emacsclient -c -F '((name . \"emacs-float\"))' +{line} {file}";
            todoKeywords = "TODO NEXT WAIT | DONE NOPE";
            todosFile = "~/Documents/notes/inbox/tasks.org";
            extraFiles = "~/Documents/notes/inbox/auto.org";
            archiveFile = "~/Documents/notes/inbox/archive.org";
          };
        };
      };
      imports = [ config.sops.templates."vicinae-secrets.json".path ];
    };

    extensions =
      with extensions;
      [
        bitwarden
        nix
        power-profile
        pulseaudio
        process-manager
        wifi-commander
      ]
      ++ (
        let
          raycastRev = "3c654737b0d566d3103fcdf72221a9f34664bdf2";
        in
        [
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
          (mkRayCastExtension {
            name = "freshrss";
            rev = raycastRev;
            sha256 = "sha256-vKT6G0QcP5/A/jKPS803uCTPWwgvDNwS1+g5oAqGn+0=";
          })
          (mkExtension {
            name = "fmhy";
            version = "0.0.1";
            src = ./extensions/fmhy;
          })
          (mkExtension {
            name = "home-assistant";
            version = "0.0.1";
            src = ./extensions/home-assistant;
          })
          (mkExtension {
            name = "org-todos";
            version = "0.0.1";
            src = ./extensions/org-todos;
          })
        ]
      );
  };

  sops.templates = {
    "vicinae-secrets.json".content = builtins.toJSON {
      providers = {
        "@knoopx/home-assistant" = {
          preferences = {
            url = "https://home.chipmunk-teeth.ts.net";
            token = config.sops.placeholder."services/homeassistant";
          };
        };
        "@semyon_surkov/freshrss" = {
          preferences = {
            baseUrl = "https://rss.adhk.dev";
            username = "adienox";
            apiPassword = config.sops.placeholder."services/freshrss";
          };
        };
      };
    };
  };
}
