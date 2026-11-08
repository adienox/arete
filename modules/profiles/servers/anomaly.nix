{ config, ... }: {
  imports = [ ./cache-builder.nix ];

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

  services.cacheBuilder = {
    enable = true;
    repoUrl = "git@github.com:adienox/arete.git";
    sshKeyFile = config.sops.secrets."anomaly/arete-deploy".path;
    signKeyFile = config.sops.secrets."anomaly/harmonia".path;
  };

  sops.secrets."anomaly/arete-deploy".owner = "cache-builder";
  sops.secrets."anomaly/harmonia" = { };
}
