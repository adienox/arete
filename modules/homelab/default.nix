{ homelab, ... }:
let
  resolveService =
    name:
    let
      path = ./. + "/${name}.nix";
    in
    if builtins.pathExists path then
      path
    else
      throw ''
        No homelab service named "${name}".
        Expected: ${toString path}
      '';
in
{
  imports = map resolveService homelab;
}
