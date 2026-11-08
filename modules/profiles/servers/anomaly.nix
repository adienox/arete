{
  systemd.services.battery-conservation = {
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      echo 1 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
    '';
  };
}
