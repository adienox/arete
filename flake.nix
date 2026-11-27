{
  description = "NixOS configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://vicinae.cachix.org"
      "https://cache.adhk.dev"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "cache.adhk.dev-1:2TOvRLSnWOKtQRCqhWcMIMb9nIclsRAtmGw5BAeinAo="
    ];
  };

  outputs =
    { ... }@args:
    let
      inputs = (import ./.tack) { overrides = args.tackOverrides or { }; };
      system = "x86_64-linux";
      nixpkgs = inputs.nixpkgs;
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
          # bootstrap.sh clones the repo and execs the freshly cloned
          # install.sh, so a cached `nix run github:...` app never runs
          # stale installer logic.
          script = ./scripts/bootstrap.sh;
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
        enroll-tpm = lib.mkApp {
          name = "enroll-tpm";
          script = ./scripts/tpm.sh;
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
