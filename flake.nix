{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # just for the home manager config, package is from nixos
    niri = {
      url = "github:epireyn/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae.url = "github:vicinaehq/vicinae";

    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms.url = "github:AvengeMedia/DankMaterialShell";

    xremap.url = "github:xremap/nix-flake";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    nix-firefox-addons.url = "github:osipog/nix-firefox-addons";

    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    disko.url = "github:nix-community/disko";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      overlays = [
        inputs.niri.overlays.niri
        inputs.emacs.overlays.default
        inputs.nix-firefox-addons.overlays.default
        (import ./overlays)
      ];
      lib = import ./lib {
        inherit
          nixpkgs
          home-manager
          inputs
          overlays
          ;
      };
    in
    {
      nixosConfigurations = {
        anomaly = lib.mkHost {
          hostname = "anomaly";
        };
      };
      homeConfigurations = {
        nox = lib.mkHome {
          profile = "personal";
        };
      };
    };
}
