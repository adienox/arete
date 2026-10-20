{
  pkgs,
  config,
  vars,
  ...
}:
{
  nix = {
    channel.enable = false;
    settings = {
      warn-dirty = false;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
      accept-flake-config = true;
      access-tokens = "!include ${config.sops.templates."access-tokens.conf".path}";
    };
  };

  sops.templates."access-tokens.conf".content = "github.com=${
    config.sops.placeholder."services/github"
  }";

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

  system.stateVersion = vars.stateVersion;
}
