{
  nixpkgs,
  home-manager,
  inputs,
  pkgs,
}:
{
  mkHost = import ./mk-host.nix {
    inherit
      nixpkgs
      home-manager
      inputs
      ;
  };
  mkApp = import ./mk-app.nix { inherit pkgs; };
}
