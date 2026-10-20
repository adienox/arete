# Core system primitives: identity, users and Nix plumbing.
{
  imports = [
    ./arete.nix
    ./environment.nix
    ./locale.nix
    ./nix-ld.nix
    ./nixpkgs.nix
    ./users.nix
  ];
}
