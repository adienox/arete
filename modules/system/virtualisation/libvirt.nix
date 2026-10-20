# Desktop virtualization: workstation-only, imported from the workstation tree.
{ vars, ... }:
{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.users.${vars.user}.extraGroups = [ "libvirtd" ];

  virtualisation.vmVariant = {
    virtualisation.memorySize = 4096;
    virtualisation.qemu.options = [
      "-object memory-backend-memfd,id=mem,size=4096M,share=on"
      "-numa node,memdev=mem"
    ];
  };
}
