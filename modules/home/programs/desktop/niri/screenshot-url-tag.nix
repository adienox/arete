{ pkgs, config, ... }:
let
  screenshotDir = config.xdg.userDirs.extraConfig.SCREENSHOTS;

  targetAppId = "zen-twilight";

  script = pkgs.writeShellScript "screenshot-url-tag" ''
    URL_FILE="$HOME/.local/share/arete-state/url"

    # Only tag if active window is targetApp
    ACTIVE=$(${pkgs.niri}/bin/niri msg --json focused-window | ${pkgs.gojq}/bin/gojq -r '.app_id')
    [[ "$ACTIVE" != "${targetAppId}" ]] && exit 0

    LATEST=$(${pkgs.findutils}/bin/find "${screenshotDir}" -maxdepth 1 -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
    [[ -z "$LATEST" ]] && exit 0

    # Never tag Screenshot_* files
    [[ "''${LATEST##*/}" == Screenshot_* ]] && exit 0

    # Already has a comment (including our own previous write), so skip
    [[ -n "$(${pkgs.exiftool}/bin/exiftool -s3 -Comment "$LATEST")" ]] && exit 0

    [[ -f "$URL_FILE" ]] || exit 0
    ${pkgs.exiftool}/bin/exiftool -overwrite_original -Comment="$(cat "$URL_FILE")" "$LATEST" &>/dev/null
  '';
in
{
  systemd.user.paths.screenshot-url-tag = {
    Unit.Description = "Watch for new screenshots";
    Path = {
      PathChanged = screenshotDir;
      Unit = "screenshot-url-tag.service";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.screenshot-url-tag = {
    Unit.Description = "Tag latest screenshot with active URL";
    Service = {
      Type = "oneshot";
      ExecStart = "${script}";
    };
  };
}
