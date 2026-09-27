{
  pkgs,
  config,
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
      nautilus
    ];
    pathsToLink = [ "/share/applications" ];
    localBinInPath = true;
  };

  home-manager.backupCommand = pkgs.writeShellScript "hm-backup" ''
    file="$1"
    short="$(${pkgs.coreutils}/bin/basename "$(dirname "$file")")/$(${pkgs.coreutils}/bin/basename "$file")"

    echo "home-manager: replacing existing file $file (moving to trash)"

    # Don't notify for files under ~/.config/zen/default/browser-extension-data/
    case "$file" in
      "$HOME/.config/zen/default/browser-extension-data/"*)
        ;;
      *)
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(${pkgs.coreutils}/bin/id -u)/bus"
        ${pkgs.libnotify}/bin/notify-send \
          -a "Home Manager" \
          -i user-trash \
          "File replaced" \
          "$short was moved to trash" || true
        ;;
    esac

    ${pkgs.trash-cli}/bin/trash "$file"
  '';

  system.stateVersion = "26.11";
}
