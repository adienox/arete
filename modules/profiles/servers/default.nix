{
  hostname,
  inputs,
  vars,
  role,
  ...
}:
{
  imports = [
    ../../system/common.nix
    ./lid.nix
    ./linger.nix
    ./network.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit
        inputs
        hostname
        vars
        role
        ;
    };
    backupFileExtension = "hm-bak";

    users.${vars.user} = {
      programs.home-manager.enable = true;

      home = {
        enableNixpkgsReleaseCheck = false;
        stateVersion = vars.stateVersion;
      };

      imports = [
        inputs.nix-index-database.homeModules.default
        ../../../lib/helpers-module.nix
        ../../home
      ];
    };
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
    persistent = true;
  };

  nix.optimise.automatic = true;

  system.autoUpgrade = {
    enable = true;
    flake = "github:adienox/arete#${hostname}";
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L"
    ];
    dates = "weekly";
    randomizedDelaySec = "45min";
    persistent = true;
    allowReboot = false;
  };
}
