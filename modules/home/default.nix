{ role, ... }:
{
  imports = [
    ./common.nix
    (if role == "server" then ./server.nix else ./workstation.nix)
  ];
}
