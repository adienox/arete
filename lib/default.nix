{
  nixpkgs,
  inputs,
  pkgs,
}:
{
  mkHost = import ./mk-host.nix {
    inherit
      nixpkgs
      inputs
      ;
  };
  mkApp = import ./mk-app.nix { inherit pkgs; };
}
