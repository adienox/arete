{ hostname, ... }: {
  imports = [
    ../../system/common.nix
    ./lid.nix
    ./linger.nix
    ./network.nix
  ];
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
