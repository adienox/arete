{ pkgs, config, ... }:
let
  screenshotPath = config.wayland.windowManager.niri.settings.screenshot-path;
  screenshotDir = dirOf screenshotPath;
  screenshotFile = baseNameOf screenshotPath;

  targetAppId = "zen-twilight";

  screenshotGlob = builtins.replaceStrings [ " " ] [ "\\ " ] (
    builtins.replaceStrings
      [ "%Y" "%m" "%d" "%H" "%M" "%S" ]
      [ "[0-9][0-9][0-9][0-9]" "[0-9][0-9]" "[0-9][0-9]" "[0-9][0-9]" "[0-9][0-9]" "[0-9][0-9]" ]
      screenshotFile
  );

  script = pkgs.writeShellScript "screenshot-url-tag" ''
    URL_FILE="$HOME/.local/share/arete-state/url"
    LAST_TAGGED="$HOME/.local/share/arete-state/last-tagged-screenshot"
    SCREENSHOT_DIR="${screenshotDir}"

    # Only tag if active window is Zen
    ACTIVE=$(${pkgs.niri}/bin/niri msg --json focused-window | ${pkgs.gojq}/bin/gojq -r '.app_id')
    [[ "$ACTIVE" != "${targetAppId}" ]] && exit 0

    LATEST=$(ls -t "$SCREENSHOT_DIR"/${screenshotGlob} 2>/dev/null | head -1)
    [[ -z "$LATEST" ]] && exit 0

    # Skip if we already tagged this file (exiftool's own write retriggers PathChanged)
    [[ -f "$LAST_TAGGED" ]] && [[ "$(cat "$LAST_TAGGED")" == "$LATEST" ]] && exit 0

    if [[ -f "$URL_FILE" ]]; then
      URL=$(cat "$URL_FILE")
      ${pkgs.exiftool}/bin/exiftool -overwrite_original -Comment="$URL" "$LATEST" &>/dev/null
      echo "$LATEST" > "$LAST_TAGGED"
    fi
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
