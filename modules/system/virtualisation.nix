{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.users.nox.extraGroups = [ "libvirtd" ];

  virtualisation.vmVariant = {
    virtualisation.memorySize = 4096;
    virtualisation.qemu.options = [
      "-object memory-backend-memfd,id=mem,size=4096M,share=on"
      "-numa node,memdev=mem"
    ];
  };

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}
