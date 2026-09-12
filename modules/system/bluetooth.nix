{
  pkgs,
  ...
}:
{

  hardware.bluetooth.enable = true;

  hardware.bluetooth.settings = {
    General.ControllerMode = "bredr";
    Policy.ReconnectAttempts = 0;
  };

  # Brute force a reset after waking up from sleep, as some bluetooth devices
  # will fail to connect to a system that's been suspended at some point.
  powerManagement.enable = true;
  powerManagement.resumeCommands = ''
    ${pkgs.util-linux}/bin/rfkill block bluetooth
    ${pkgs.util-linux}/bin/rfkill unblock bluetooth
  '';
}
