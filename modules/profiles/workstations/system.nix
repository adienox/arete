# Workstation system tree: shared base + workstation-only extras.
#
# Desktop/GUI modules are composed separately in ../desktop.nix.
{
  imports = [
    ../../system/common.nix
    ../../system/virtualisation/libvirt.nix
    ../../system/development/platformio.nix
  ];
}
