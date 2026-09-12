{ config, pkgs, ... }:
{
  networking.hostName = "anomaly";
  programs.gpu-screen-recorder.enable = true;
  services.nvidia-otg.enable = true;
  services.nvidia.enable = true;

  services.udev.packages = with pkgs; [ platformio-core.udev ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    extraModulePackages = with config.boot.kernelPackages; [
      ddcci-driver
      acpi_call
    ];

    kernelModules = [
      "amdgpu"
      "i2c-dev"
      "ddcci_backlight"
      "acpi_call"
    ];

    kernelParams = [
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];

    extraModprobeConfig = ''
      options iwlwifi power_save=1
      options iwlmvm power_scheme=3
      options snd_hda_intel power_save=1
      options nvidia NVreg_RegistryDwords="PowerMizerEnable=0x1; PowerMizerDefault=0x1; PowerMizerDefaultAC=0x1; PerfLevelSrc=0x2222"

      blacklist sp5100_tco
    '';

    kernel.sysctl = {
      "vm.dirty_writeback_centisecs" = 1500;
      "vm.laptop_mode" = 5;
    };

    kernelPackages = pkgs.linuxPackages_zen;

    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 3;
      systemd-boot.enable = true;
    };

    plymouth.enable = true;
  };

  # sick and tired of these devices always switching names
  services.udev.extraRules = ''
    KERNEL=="card*", KERNELS=="0000:05:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/amd-igpu"
    KERNEL=="card*", KERNELS=="0000:01:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/nvidia-dgpu"
  '';
}
