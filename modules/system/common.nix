# Role-agnostic system base. Imported by every profile.
#
# Only modules that make sense on both workstations and servers belong here.
# Desktop, GUI and opt-in feature modules live under ./desktop (composed by
# modules/profiles/desktop.nix) and modules/profiles/*.
{
  imports = [
    ./core
    ./network
    ./security
    ./hardware
    ./virtualisation/docker.nix
  ];
}
