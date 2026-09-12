{
  config,
  pkgs,
  vars,
  ...
}:
let
  taildropDir = "${config.xdg.userDirs.documents}/Taildrop";
in
{
  home.packages = with pkgs; [ inotify-tools ];
  systemd.user.services = {
    taildrop = {
      Unit = {
        Description = "Receive files over tailscale";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        ExecStart = "${pkgs.tailscale}/bin/tailscale file get --conflict=rename --loop ${taildropDir}";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };
    taildrop-notify = {
      Unit = {
        Description = "Notify about received files over tailscale";
        After = [
          "taildrop.service"
          "graphical-session.target"
        ];
        Requires = [ "taildrop.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${vars.paths.scripts}/taildrop-watcher.sh ${taildropDir}";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
