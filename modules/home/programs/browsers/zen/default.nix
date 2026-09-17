{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.zen-browser.homeModules.twilight
    ./search.nix
    ./shortcuts.nix
    ./settings.nix
    ./extensions.nix
  ];

  programs.zen-browser = {
    enable = true;

    nativeMessagingHosts = [
      inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
      pkgs.tridactyl-native
    ];

    setAsDefaultBrowser = true;
    policies = {
      AutofillAddressEnabled = false;
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
        "599a1599-e6ab-4749-ab22-de533860de2c" # Pimp your PiP
        "e74cb40a-f3b8-445a-9826-1b1b6e41b846" # Custom uiFont
        "ad97bb70-0066-4e42-9b5f-173a5e42c6fc" # SuperPins
        "b51ff956-6aea-47ab-80c7-d6c047c0d510" # Disable Status Bar
        "c8d9e6e6-e702-4e15-8972-3596e57cf398" # Zen Back Forward
        "72f8f48d-86b9-4487-acea-eb4977b18f21" # Better CtrlTab Panel
      ];

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

      userChrome = builtins.readFile ./userChrome.css;
    };
  };
}
