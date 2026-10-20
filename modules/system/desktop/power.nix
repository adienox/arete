# Laptop/desktop power and removable-media daemons (workstation-only).
{
  services = {
    upower.enable = true;
    udisks2.enable = true;
    power-profiles-daemon.enable = true;
  };
}
