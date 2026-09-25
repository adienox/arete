{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-legion-15arh05h
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;

  hardware.nvidia = {
    enable = true;
    prime = lib.mkForce {
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    primeBatterySaverSpecialisation = true;
  };

  # sick and tired of these devices always switching names
  services.udev.extraRules = ''
    KERNEL=="card*", KERNELS=="0000:05:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/amd-igpu"
    KERNEL=="card*", KERNELS=="0000:01:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/nvidia-dgpu"
  '';
}
