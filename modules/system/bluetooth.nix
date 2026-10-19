{
  pkgs,
  lib,
  ...
}:
let
  timeoutMinutes = 5;

  script = pkgs.writeShellApplication {
    name = "bluetooth-autooff";
    runtimeInputs = [
      pkgs.bluez
      pkgs.gnugrep
      pkgs.coreutils
    ];
    text = ''
      timeout=${toString (timeoutMinutes * 60)}
      interval=15
      idle=0

      while true; do
        show=$(bluetoothctl show 2>/dev/null || true)

        if grep -q 'Powered: yes' <<<"$show"; then
          connected=$(bluetoothctl devices Connected 2>/dev/null || true)

          if [ -n "$connected" ]; then
            idle=0
          else
            idle=$((idle + interval))
            if [ "$idle" -ge "$timeout" ]; then
              echo "No devices connected for ${toString timeoutMinutes} min, powering off"
              bluetoothctl power off || true
              idle=0
            fi
          fi
        else
          # adapter off or bluez not ready: reset the clock
          idle=0
        fi

        sleep "$interval"
      done
    '';
  };
in
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

  systemd.services.bluetooth-autooff = {
    description = "Power off Bluetooth when idle";
    wantedBy = [ "multi-user.target" ];
    after = [ "bluetooth.service" ];
    wants = [ "bluetooth.service" ];
    serviceConfig = {
      ExecStart = lib.getExe script;
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
