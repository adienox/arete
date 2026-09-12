{ config, pkgs, ... }:
{
  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";

    # Reducing direnv logs
    DIRENV_LOG_FORMAT = "";

    # ~/ Clean-up:
    XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";

    ANDROID_SDK_HOME = "${config.xdg.configHome}/android";
    ANSIBLE_CONFIG = "${config.xdg.configHome}/ansible/ansible.cfg";
    MBSYNCRC = "${config.xdg.configHome}/mbsync/config";

    ELECTRUMDIR = "${config.xdg.dataHome}/electrum";
    UNISON = "${config.xdg.dataHome}/unison";

    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    GOPATH = "${config.xdg.dataHome}/go";
    SQLITE_HISTORY = "${config.xdg.dataHome}/sqlite_history";
    GOMODCACHE = "${config.xdg.cacheHome}/go/mod";
    #PYTHONSTARTUP = "${config.xdg.configHome}/python/pythonrc";
    IPYTHONDIR = "${config.xdg.configHome}/ipython";
    RSYNC_PARTIAL_DIR = "${config.xdg.cacheHome}/rsync";
    WGET_HSTS_FILE = "${config.xdg.dataHome}/wget-hsts";
    LESSHISTFILE = "${config.xdg.cacheHome}/less/history";

    NIXPKGS_ALLOW_UNFREE = 1;
    _ZO_EXCLUDE_DIRS = "/nix/*:/sys/*:/run/*";
  };
}
