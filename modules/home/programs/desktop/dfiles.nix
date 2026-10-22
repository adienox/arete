{ inputs, ... }:
{
  imports = [
    inputs.dfiles.homeModules.dank-files
  ];
  programs.dank-files = {
    enable = true;

    systemd = {
      enable = true;
      target = "graphical-session.target";
      restartIfChanged = true;
    };

    portal = {
      enable = true;
      preferred = true;
      desktop = "niri";
    };
  };
}
