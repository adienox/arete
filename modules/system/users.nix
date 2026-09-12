{
  pkgs,
  ...
}:
{
  programs.fish.enable = true;
  services.accounts-daemon.enable = true;

  users.users.nox = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "Adienox";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "wireshark"
    ];
  };
}
