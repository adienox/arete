# Host metadata consumed by flake.nix (host auto-discovery).
# Software configuration lives in modules/profiles/<role>/anomaly.nix
# (currently modules/profiles/servers/anomaly.nix).
{
  role = "server";
  profiles = [ "nvidia" ];
}
