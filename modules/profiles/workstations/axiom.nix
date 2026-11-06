{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    #    ./ryzenadj.nix
  ];
  # boot.kernelPackages = pkgs.linuxPackages_zen;

  systemd.sleep.settings.Sleep = {
    AllowSuspendThenHibernate = "yes";
    HibernateDelaySec = "30min";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend";
    HandleSuspendKey = "suspend-then-hibernate";
    HandlePowerKey = lib.mkForce "suspend-then-hibernate";
  };

  boot.initrd.availableKernelModules = [
    "tpm_tis"
    "tpm_crb"
  ];

  security = {
    tpm2.enable = true;
    pam.services = {
      polkit-1.fprintAuth = true;
      sudo.fprintAuth = true;
    };
  };

  systemd.services.fprintd-resume = {
    description = "Restart fprintd after resume";
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
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.systemd.package}/bin/systemctl restart fprintd.service";
    };
  };
}
