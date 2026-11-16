{
  pkgs,
  helpers,
  ...
}:
{
  imports = [
    ./screenshot-url-tag.nix
    ./binds.nix
    ./settings.nix
    ./pip-stack.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard
    satty
    niri-sidebar
  ];

  wayland.windowManager.niri = {
    enable = true;
    enableDefaultConfig = true;
  };

  home.file = helpers.mkConfigFile {
    target = ".config/niri/animations.kdl";
    source = ./animations/directional-wipe.kdl;
  };

  systemd.user.services.niri-sidebar = {
    Unit = {
      Description = "niri-sidebar";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "NIRI_SOCKET";
    };
    Service = {
      ExecStart = "${pkgs.niri-sidebar}/bin/niri-sidebar listen";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
