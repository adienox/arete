# Hardware/OS tuning shared by workstations and servers.
# Laptop power daemons (upower, udisks2, power-profiles-daemon) live in
# modules/system/desktop/power.nix.
{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  services.smartd.enable = true;

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
