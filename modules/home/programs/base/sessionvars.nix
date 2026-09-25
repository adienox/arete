{ config, ... }:
let
  xdg = config.xdg;
in
{
  home.sessionVariables = {
    # Reducing direnv logs
    DIRENV_LOG_FORMAT = "";

    # ~/ Clean-up:
    XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";

    ANDROID_SDK_HOME = "${xdg.configHome}/android";
    ANSIBLE_CONFIG = "${xdg.configHome}/ansible/ansible.cfg";
    MBSYNCRC = "${xdg.configHome}/mbsync/config";

    ELECTRUMDIR = "${xdg.dataHome}/electrum";
    UNISON = "${xdg.dataHome}/unison";

    CARGO_HOME = "${xdg.dataHome}/cargo";
    GOPATH = "${xdg.dataHome}/go";
    SQLITE_HISTORY = "${xdg.dataHome}/sqlite_history";
    GOMODCACHE = "${xdg.cacheHome}/go/mod";
    #PYTHONSTARTUP = "${xdg.configHome}/python/pythonrc";
    IPYTHONDIR = "${xdg.configHome}/ipython";
    RSYNC_PARTIAL_DIR = "${xdg.cacheHome}/rsync";
    WGET_HSTS_FILE = "${xdg.dataHome}/wget-hsts";
    LESSHISTFILE = "${xdg.cacheHome}/less/history";

    NIXPKGS_ALLOW_UNFREE = 1;
    _ZO_EXCLUDE_DIRS = "/nix/*:/sys/*:/run/*";
  };
}
