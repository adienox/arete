{
  pkgs,
  config,
  lib,
  osConfig ? null,
  vars,
  ...
}:
let
  uwsm = osConfig != null && (osConfig.programs.uwsm.enable or false);
  notes = vars.paths.notes;
  disableApps =
    names:
    lib.genAttrs names (name: {
      enable = false;
    });
in
{
  programs.vicinae.settings = {
    providers = {
      applications.preferences.launchPrefix = if uwsm then "uwsm app --" else "";
      applications.entrypoints = disableApps [
        "cups"
        "gvim"
        "org-protocol"
        "org.kde.kdeconnect.nonplasma"
        "org.kde.kdeconnect.sms"
        "scrcpy"
        "scrcpy-console"
        "vicinae"
        "vim"
        "yad-icon-browser"
        "yad-settings"
      ];

      core.entrypoints = disableApps [
        "about"
        "keybind-settings"
        "list-extensions"
        "open-config-file"
        "open-default-config"
        "report-bug"
        "settings"
        "sponsor"
      ];

      "@samlinville/tailscale".preferences = {
        tailscalePath = "${pkgs.tailscale}/bin/tailscale";
      };

      "@dagimg-dot/vicinae-extension-wifi-commander-0".preferences = {
        network-cli-tool = "nmcli";
      };

      "@mattisssa/spotify-player".entrypoints = {
        yourLibrary.preferences."Default-View" = "all";
        search.preferences = {
          musicOnly = true;
          topView = "tracks";
        };
        startRadio.enable = true;
      };
      "@adienox/org-todos".preferences = {
        editorCommand = "emacsclient -c -F '((name . \"emacs-float\"))' +{line} {file}";
        todoKeywords = "TODO NEXT WAIT | DONE NOPE";
        todosFile = "${notes}/inbox/tasks.org";
        extraFiles = "${notes}/inbox/auto.org";
        archiveFile = "${notes}/inbox/archive.org";
      };
    };
    imports = [ config.sops.templates."vicinae-secrets.json".path ];
  };

  sops.templates = {
    "vicinae-secrets.json".content = builtins.toJSON {
      providers = {
        "@knoopx/home-assistant".preferences = {
          url = "https://home.chipmunk-teeth.ts.net";
          token = config.sops.placeholder."services/homeassistant";
        };
        "@semyon_surkov/freshrss".preferences = {
          baseUrl = "https://rss.adhk.dev";
          username = "adienox";
          apiPassword = config.sops.placeholder."services/freshrss";
        };
      };
    };
  };
}
