{ pkgs, lib, config, ... }:
{
  options.modules.monitor.enable = lib.mkEnableOption "Monitor Configuration" // { default = true; };

  config = lib.mkIf config.modules.monitor.enable {
    services.udev.extraRules = ''
      SUBSYSTEM=="i2c-dev", ACTION=="add",\
        ATTR{name}=="NVIDIA i2c adapter*",\
        TAG+="ddcci",\
        TAG+="systemd",\
        ENV{SYSTEMD_WANTS}+="ddcci@$kernel.service"
    '';

    systemd.services."ddcci@" = {
      scriptArgs = "%i";
      script = ''
        echo Trying to attach ddcci to $1
        i=0
        id=$(echo $1 | cut -d "-" -f 2)
        counter=5
        while [ $counter -gt 0 ]; do
          if ${pkgs.ddcutil}/bin/ddcutil getvcp 10 -b $id; then
            echo ddcci 0x37 > /sys/bus/i2c/devices/$1/new_device
            break
          fi
          sleep 1
          counter=$((counter - 1))
        done
      '';
      serviceConfig.Type = "oneshot";
    };

    environment.systemPackages = [ pkgs.ddcutil ];

    hardware.i2c.enable = true;
    users.users.nox.extraGroups = [ "i2c" ];
  };
}
