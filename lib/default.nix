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
        ../hosts/${hostname}/hardware.nix
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
