# Opt-in desktop/GUI profile (composes modules/system/desktop).
#
# The shared workstation base imports this, so workstations are full desktops
# by default. Other roles can opt in explicitly:
#   profiles = [ "desktop" ]
{ ... }:
{
  imports = [ ../system/desktop ];
}
