{ homelab, vars, ... }:
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
  imports = (map resolveService homelab) ++ [ ./networking.nix ];

  homelab.dns = {
    zone = vars.domain;
    ip = "100.125.152.83";
  };
}
