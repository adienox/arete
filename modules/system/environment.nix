{
  pkgs,
  ...
}:
{
  nix = {
    settings = {
      warn-dirty = false;
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
      nautilus
    ];
    pathsToLink = [ "/share/applications" ];
    localBinInPath = true;
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.11";
}
