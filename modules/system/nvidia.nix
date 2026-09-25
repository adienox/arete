{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.hardware.nvidia = {
    enable = lib.mkEnableOption "nvidia";
  };

  config = lib.mkIf config.hardware.nvidia.enable {
    hardware = {
      # Make sure opengl is enabled
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
        ];
      };

      nvidia = {
        # Modesetting is needed for most wayland compositors
        modesetting.enable = true;
        powerManagement.enable = true;

        # Use the open source version of the kernel module
        # Only available on driver 515.43.04+
        open = true;

        # Enable the nvidia settings menu
        nvidiaSettings = true;
      };
    };
  };
}
