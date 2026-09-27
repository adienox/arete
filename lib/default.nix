{
  nixpkgs,
  home-manager,
  inputs,
  pkgs,
}:
let
  vars = import ./variables.nix;
in
{
  mkHost =
    {
      hostname,
      system ? "x86_64-linux",
      profile ? "personal",
    }:
    let
      repoHw = ../hosts/${hostname}/hardware.nix;
      etcHw = /etc/nixos/hardware-configuration.nix;

      hwPath =
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
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs vars hostname;
      };
      modules = [
        {
          nixpkgs.overlays = [
            inputs.nix-firefox-addons.overlays.default
            (import ../overlays)
          ];
          nixpkgs.config.allowUnfree = true;
          nix.registry.nixpkgs.flake = nixpkgs;
          nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
        }

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
          home-manager.extraSpecialArgs = {
            inherit inputs vars hostname;
          };
          home-manager.users.nox.imports = [
            inputs.vicinae.homeManagerModules.default
            inputs.nix-index-database.homeModules.default
            inputs.sops-nix.homeManagerModules.sops

            ./helpers-module.nix
            ../modules/home
            ../modules/home/profiles/${profile}.nix
          ];
        }
      ];
    };
  mkApp =
    {
      name,
      script,
      runtimeInputs ? [ ],
    }:
    {
      type = "app";
      program = "${
        pkgs.writeShellApplication {
          inherit name runtimeInputs;
          text = builtins.readFile script;
        }
      }/bin/${name}";
    };
}
