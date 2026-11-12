{
  pkgs,
  ...
}:

let
  stateFile = "/run/bluetooth-resume-devices";

  saveScript = pkgs.writeShellScript "bt-save-connected" ''
    set -u
    # Needs bluez >= 5.65 for the "Connected" filter
    ${pkgs.bluez}/bin/bluetoothctl devices Connected \
      | ${pkgs.gawk}/bin/awk '/^Device/ {print $2}' > ${stateFile}
    echo "Saved $(wc -l < ${stateFile}) connected device(s)"
  '';

  restoreScript = pkgs.writeShellScript "bt-restore-connected" ''
    set -u
    [ -s ${stateFile} ] || exit 0

    # Wait for the adapter to come back up (max ~15s)
    for i in $(seq 1 15); do
      if ${pkgs.bluez}/bin/bluetoothctl show | grep -q "Powered: yes"; then
        break
      fi
      sleep 1
    done

    while read -r mac; do
      [ -n "$mac" ] || continue
      for attempt in 1 2 3 4 5; do
        if ${pkgs.bluez}/bin/bluetoothctl --timeout 10 connect "$mac" \
            | grep -q "Connection successful"; then
          echo "Reconnected $mac"
          break
        fi
        echo "Attempt $attempt failed for $mac"
        sleep 2
      done
    done < ${stateFile}

    rm -f ${stateFile}
  '';
in
{
  hardware.bluetooth.enable = true;

  systemd.services.bluetooth-save-before-sleep = {
    description = "Save connected Bluetooth devices before sleep";
    before = [ "sleep.target" ];
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = saveScript;
    };
  };

  systemd.services.bluetooth-restore-after-sleep = {
    description = "Reconnect Bluetooth devices after resume";
    after = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    wantedBy = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    requires = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = restoreScript;
    };
  };
}
