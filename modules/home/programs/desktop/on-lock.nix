{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.session-hooks;

  # Each command runs in its own subshell, so one failing hook
  # (or `set -e`) can't kill the listener or block the others.
  hookLines =
    cmds:
    lib.concatMapStringsSep "\n" (
      c: "(${c}) || echo ${lib.escapeShellArg "session-hooks: failed: ${c}"} >&2"
    ) cmds;

  sessionHooks = pkgs.writeShellApplication {
    name = "session-hooks";
    runtimeInputs = [
      pkgs.dbus
      pkgs.coreutils
    ]
    ++ cfg.extraPackages;
    text = ''
      stdbuf -oL dbus-monitor --system \
        "type='signal',interface='org.freedesktop.login1.Session',member='Lock'" \
        "type='signal',interface='org.freedesktop.login1.Session',member='Unlock'" |
      while read -r line; do
        case "$line" in
          *member=Lock*)
            :
            ${hookLines cfg.onLock}
            ;;
          *member=Unlock*)
            :
            ${hookLines cfg.onUnlock}
            ;;
        esac
      done
    '';
  };
in
{
  options.services.session-hooks = {
    enable = lib.mkEnableOption "logind lock/unlock hooks";

    onLock = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Shell commands to run when the session locks.";
    };

    onUnlock = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Shell commands to run when the session unlocks.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Packages added to PATH for the hook commands.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.session-hooks = {
      Unit = {
        Description = "Run commands on session lock/unlock";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = lib.getExe sessionHooks;
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
