{ pkgs, vars, ... }:
{
  systemd.user.services.commands-api = {
    Unit = {
      Description = "Commands API";
      After = [ "graphical-session.target" ];
      Requires = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.uv}/bin/uv run ${vars.paths.scripts}/commands-api.py";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
