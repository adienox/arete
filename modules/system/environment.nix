{
  pkgs,
  ...
}:
{
  nix = {
    settings = {
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://vicinae.cachix.org"
        "https://niri-epireyn.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
        "niri-epireyn.cachix.org-1:tlVyFN7CtsDT+ZcLPS+ekFWeT1X6X4OqvWqbBMyIzFA="
      ];
      warn-dirty = false;
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "nox"
      ];
      accept-flake-config = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      neovim
      wget
      git
      unzip
      cmake
      gnumake
      gcc
      ripgrep
      fd
    ];
    pathsToLink = [ "/share/applications" ];
    localBinInPath = true;
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.11";
}
