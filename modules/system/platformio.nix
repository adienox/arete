{ pkgs, ... }: {
  services.udev.packages = with pkgs; [ platformio-core.udev ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
