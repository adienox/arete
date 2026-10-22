{
  description = "NixOS configuration";

  nixConfig = {
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
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae.url = "github:vicinaehq/vicinae";

    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms.url = "github:AvengeMedia/DankMaterialShell";

    dcal.url = "github:AvengeMedia/dankcalendar";

    dms-plugin = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:epireyn/niri-flake";

    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    nix-firefox-addons.url = "github:osipog/nix-firefox-addons";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = import ./lib {
        inherit
          nixpkgs
          inputs
          pkgs
          ;
      };
    in
    {
      apps.${system} = {
        install = lib.mkApp {
          name = "install";
          script = ./scripts/install.sh;
          runtimeInputs = with pkgs; [
            nix
            git
          ];
        };
        update = lib.mkApp {
          name = "update";
          script = ./scripts/update.sh;
          runtimeInputs = [ pkgs.nix ];
        };
        secrets = lib.mkApp {
          name = "secrets";
          script = ./scripts/secrets.sh;
          runtimeInputs = with pkgs; [
            bitwarden-cli
            jq
          ];
        };
      };
      # Hosts are auto-discovered from hosts/<name>/. Role and opt-in
      # profiles come from hosts/<name>/meta.nix.
      nixosConfigurations = nixpkgs.lib.mapAttrs (
        hostname: _:
        let
          metaPath = ./hosts/${hostname}/meta.nix;
          meta = if builtins.pathExists metaPath then import metaPath else { };
        in
        lib.mkHost {
          inherit hostname;
          role = meta.role or "workstation";
          profiles = meta.profiles or [ ];
        }
      ) (nixpkgs.lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts));
    };
}
