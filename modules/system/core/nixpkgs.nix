{ inputs, ... }:
{
  nixpkgs.overlays = [
    (import ../../../overlays)
  ];

  nixpkgs.config.allowUnfree = true;
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
}
