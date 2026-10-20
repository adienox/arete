# Watch the wallpapers repo and offer to commit/push, rename, or task new files.
{
  pkgs,
  lib,
  vars,
  ...
}:
let
  binPath = lib.makeBinPath [
    pkgs.bash
    pkgs.git
    pkgs.openssh
    pkgs.curl
    pkgs.jq
    pkgs.libnotify
    pkgs.yad
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.gnused
    pkgs.findutils
  ];
in
{
  systemd.user.paths.wallpaper-git = {
    Unit.Description = "Watch the wallpapers repo for new files";

    Path = {
      PathChanged = vars.paths.wallpapers;
      Unit = "wallpaper-git.service";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.wallpaper-git = {
    Unit = {
      Description = "Offer to commit/push, rename, or file a newly added wallpaper";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${vars.paths.scripts}/wallpaper-git.sh ${vars.paths.wallpapers}";
      Environment = [ "PATH=${binPath}" ];
    };
  };
}
