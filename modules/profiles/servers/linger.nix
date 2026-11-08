# Keep user-level services running across logins.
#
# Rootless Docker runs as a systemd *user* service (see
# modules/system/virtualisation/docker.nix). Without lingering, logging out
# tears down the user manager and stops it, taking every container with it --
# e.g. the Piped stack's 0.0.0.0:8080 container on anomaly, which is why it
# only worked while an SSH session was open.
{ vars, ... }:
{
  users.users.${vars.user}.linger = true;
}
