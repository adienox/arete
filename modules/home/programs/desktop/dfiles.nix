{ inputs, ... }:
{
  imports = [
    inputs.dfiles.homeModules.dux-files
  ];

  programs.dux-files = {
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
