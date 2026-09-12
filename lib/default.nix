{
  nixpkgs,
  home-manager,
  inputs,
  overlays,
}:
{
  mkHost =
    {
      hostname,
      system ? "x86_64-linux",
    }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        vars = import ./variables.nix;
      };
      modules = [
        {
          nixpkgs.overlays = overlays;
          nixpkgs.config.allowUnfree = true;
        }
        inputs.disko.nixosModules.disko
        ../hosts/${hostname}/disko.nix
        ../hosts/${hostname}/hardware.nix
        ./helpers-module.nix
        ../hosts/${hostname}
        ../modules/system
        inputs.vicinae.nixosModules.default
      ];
    };
  mkHome =
    {
      system ? "x86_64-linux",
      profile ? "personal",
    }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = {
        inherit inputs;
        vars = import ./variables.nix;
      };
      modules = [
        {
          nixpkgs.overlays = overlays;
          nixpkgs.config.allowUnfree = true;
        }
        inputs.vicinae.homeManagerModules.default
        inputs.nix-index-database.homeModules.default
        inputs.sops-nix.homeManagerModules.sops
        ./helpers-module.nix
        ../modules/home
        ../modules/home/profiles/${profile}.nix
      ];
    };
}
