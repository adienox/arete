{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  services = {
    upower.enable = true;
    udisks2.enable = true;
    fstrim.enable = true;
    smartd.enable = true;
    power-profiles-daemon.enable = true;
  };

  systemd.oomd = {
    enable = true;

    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserSlices = true;

    settings.OOM = {
      DefaultMemoryPressureLimit = "60%";
      SwapUsedLimit = "90%";
    };
  };
  systemd.services.sshd.serviceConfig.ManagedOOMPreference = "avoid";
  systemd.slices."system".sliceConfig.ManagedOOMMemoryPressureLimit = "60%";
  systemd.slices."user".sliceConfig.ManagedOOMMemoryPressureLimit = "60%";
}
