{ pkgs, ... }: {
  services = {
    upower.enable = true;
    udisks2.enable = true;
    power-profiles-daemon.enable = true;
    tlp.enable = false;
  };
  powerManagement.powertop.enable = true;
  environment.systemPackages = [ pkgs.powertop ];
  services.auto-cpufreq = {
    enable = false;

    settings = {
      battery = {
        governor = "powersave";
        energy_performance_preference = "power";
        turbo = "never";
      };

      charger = {
        governor = "performance";
        energy_performance_preference = "performance";
        turbo = "auto";
      };
    };
  };
}
