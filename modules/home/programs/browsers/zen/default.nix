{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.zen-browser.homeModules.twilight
    ./search.nix
    ./shortcuts.nix
    ./settings.nix
    ./pins.nix
  ];

  programs.zen-browser = {
    enable = true;

    nativeMessagingHosts = [
      inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
      pkgs.tridactyl-native
    ];

    setAsDefaultBrowser = true;
    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      Preferences = {
        "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = true;
        "extensions.autoDisableScopes" = 0;
      };
    };
    profiles.default = {
      mods = [
        "f7c71d9a-bce2-420f-ae44-a64bd92975ab" # Better Unloaded Tabs
        # "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better Find Bar
        "599a1599-e6ab-4749-ab22-de533860de2c" # Pimp your PiP
        "e74cb40a-f3b8-445a-9826-1b1b6e41b846" # Custom uiFont
        "ad97bb70-0066-4e42-9b5f-173a5e42c6fc" # SuperPins
        "b51ff956-6aea-47ab-80c7-d6c047c0d510" # Disable Status Bar
        "c8d9e6e6-e702-4e15-8972-3596e57cf398" # Zen Back Forward
        "72f8f48d-86b9-4487-acea-eb4977b18f21" # Better CtrlTab Panel
      ];

      # nix run github:osipog/nix-firefox-addons#search-addon vimium
      extensions = {
        packages = with pkgs.firefoxAddons; [
          bitwarden-password-manager
          darkreader
          enhancer-for-youtube
          facebook-container
          multi-account-containers
          imagus
          karakeep
          redirector
          refined-github-
          remove-youtube-s-suggestions
          sponsorblock
          ublock-origin
          tridactyl-vim
          clearurls
          skip-redirect
          github-file-icons
          watchmarker-for-youtube
          tab-reloader
          youtube-unhook
          vicinae
        ];
        settings."uBlock0@raymondhill.net".force = true;
        settings."uBlock0@raymondhill.net".settings = {
          userSettings = rec {
            importedLists = [
              "https://raw.githubusercontent.com/gijsdev/ublock-hide-yt-shorts/master/list.txt"
            ];
            externalLists = lib.concatStringsSep "\n" importedLists;
          };
          selectedFilterLists = [
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-unbreak"
            "easylist"
            "adguard-generic"
            "easyprivacy"
            "adguard-spyware-url"
            "urlhaus-1"
            "plowe-0"
            "fanboy-cookiemonster"
            "ublock-cookies-easylist"
            "adguard-cookies"
            "ublock-cookies-adguard"
            "fanboy-social"
            "adguard-social"
            "fanboy-ai-suggestions"
            "easylist-chat"
            "easylist-newsletters"
            "easylist-notifications"
            "easylist-annoyances"
            "adguard-mobile-app-banners"
            "adguard-other-annoyances"
            "adguard-popup-overlays"
            "adguard-widgets"
            "ublock-annoyances"
            "https://raw.githubusercontent.com/gijsdev/ublock-hide-yt-shorts/master/list.txt"
          ];
        };
      };

      containersForce = true; # Delete containers not declared here
      containers = {
        Personal = {
          color = "purple";
          icon = "fingerprint";
          id = 1;
        };
        Work = {
          color = "blue";
          icon = "briefcase";
          id = 2;
        };
        Shopping = {
          color = "yellow";
          icon = "dollar";
          id = 3;
        };
        Dev = {
          color = "orange";
          icon = "gift";
          id = 4;
        };
        Google = {
          color = "red";
          icon = "chill";
          id = 5;
        };
      };

      spacesForce = true; # Delete spaces not declared here
      spaces = {
        "Home" = {
          id = "c6de089c-410d-4206-961d-ab11f988d40a";
          position = 1000;
          icon = "🏠";
        };
        "Study" = {
          id = "cdd10fab-4fc5-494b-9041-325e5759195b";
          position = 2000;
          icon = "📚";
        };
        "Work" = {
          id = "78aabdad-8aae-4fe0-8ff0-2a0c6c4ccc24";
          position = 3000;
          icon = "💼";
        };
        "School" = {
          id = "89ef733c-24f1-47d5-9d0b-e0d6dd0d4c37";
          icon = "🎓";
          position = 4000;
        };
      };

      userChrome = builtins.readFile ./userChrome.css;
    };
  };
}
