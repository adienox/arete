# Stack Picture-in-Picture windows in the corner and keep them on the active
# workspace. See modules/home/files/scripts/niri-pip-stack.py.
{ pkgs, lib, vars, ... }:
{
  systemd.user.services.niri-pip-stack = {
    Unit = {
      Description = "Keep Picture-in-Picture windows stacked and following the active workspace";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.python3}/bin/python3 ${vars.paths.scripts}/niri-pip-stack.py";
      # The daemon shells out to `niri msg`; give it the same client as the compositor.
      Environment = [ "PATH=${lib.makeBinPath [ pkgs.niri-unstable ]}" ];
      Restart = "always";
      RestartSec = 2;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
