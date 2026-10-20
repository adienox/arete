# Host metadata consumed by flake.nix (host auto-discovery).
# Software configuration lives in modules/profiles/workstations/anomaly.nix.
{
  role = "workstation";
  profiles = [ "nvidia" ];
}
