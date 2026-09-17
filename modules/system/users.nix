{
  pkgs,
  ...
}:
{
  programs.fish.enable = true;
  services.accounts-daemon.enable = true;

  users.users.root = {
    initialHashedPassword = "$y$j9T$j95dMDQuPeqb4e/oOCWEr0$M.y9.SJYeaqYDvZD0RQFaHCXEAtDtMB8kGqlmoUCPa0";
  };

  users.users.nox = {
    isNormalUser = true;
    shell = pkgs.fish;
    initialHashedPassword = "$y$j9T$j95dMDQuPeqb4e/oOCWEr0$M.y9.SJYeaqYDvZD0RQFaHCXEAtDtMB8kGqlmoUCPa0";
    description = "Adienox";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "wireshark"
      "kvm"
    ];
  };
}
