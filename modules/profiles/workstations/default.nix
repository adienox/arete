# Shared workstation base profile: full desktop system + home-manager.
#
# Loaded automatically by lib.mkHost for hosts with `role = "workstation"`.
# Per-machine overrides live in modules/profiles/workstations/<hostname>.nix
# and are picked up automatically when they exist.
{
  pkgs,
  inputs,
  hostname,
  vars,
  ...
}:
{
  imports = [
    ./system.nix
    ../desktop.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.vicinae.nixosModules.default
  ];

  environment.systemPackages = [ pkgs.nautilus ];

  security.pam.services.${vars.user}.enableGnomeKeyring = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs hostname vars; };

    backupCommand = pkgs.writeShellScript "hm-backup" ''
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

    users.${vars.user}.imports = [
      inputs.vicinae.homeManagerModules.default
      inputs.nix-index-database.homeModules.default
      inputs.sops-nix.homeManagerModules.sops

      ../../../lib/helpers-module.nix
      ../../home
    ];
  };
}
