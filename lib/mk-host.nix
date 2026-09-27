{
  nixpkgs,
  home-manager,
  inputs,
}:
let
  vars = import ./variables.nix;

  findHardwareConfig =
    hostname:
    let
      repoHw = ../hosts/${hostname}/hardware.nix;
      etcHw = /etc/nixos/hardware-configuration.nix;
    in
    if builtins.pathExists repoHw then
      repoHw
    else if builtins.pathExists etcHw then
      etcHw
    else
      throw ''
        No hardware-configuration.nix found for host "${hostname}".
        Checked:
          - ${toString repoHw}
          - ${toString etcHw}
        Run `nixos-generate-config` on the target machine, then either
        commit the result into hosts/${hostname}/, or re-run the install
        (it will pick up /etc/nixos/hardware-configuration.nix).
      '';

  findProfile =
    profile:
    let
      path = ../modules/home/profiles/${profile}.nix;
    in
    if builtins.pathExists path then
      path
    else
      throw ''
        No home profile named "${profile}".
        Expected: ${toString path}
      '';
in
{
  hostname,
  system ? "x86_64-linux",
  profile ? "personal",
}:
let
  hwPath = findHardwareConfig hostname;
  profilePath = findProfile profile;
  commonArgs = {
    inherit inputs vars hostname;
  };
in
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = commonArgs;
  modules = [
    inputs.disko.nixosModules.disko
    inputs.vicinae.nixosModules.default
    inputs.sops-nix.nixosModules.sops

    ../hosts/${hostname}/disko.nix
    hwPath
    ./helpers-module.nix
    ../hosts/${hostname}
    ../modules/system

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = commonArgs;
      home-manager.users.nox.imports = [
        inputs.vicinae.homeManagerModules.default
        inputs.nix-index-database.homeModules.default
        inputs.sops-nix.homeManagerModules.sops

        ./helpers-module.nix
        ../modules/home
        profilePath
      ];
    }
  ];
}
