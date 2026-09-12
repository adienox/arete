{ pkgs, ... }:
let
  script = pkgs.writeShellScript "screenshot-url-tag" ''
    URL_FILE="$HOME/.local/share/arete-state/url"
    SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

    # Only tag if active window is Zen
    ACTIVE=$(${pkgs.niri}/bin/niri msg --json focused-window | ${pkgs.gojq}/bin/gojq -r '.app_id')
    [[ "$ACTIVE" != "zen-twilight" ]] && exit 0

    LATEST=$(ls -t "$SCREENSHOT_DIR"/*.png 2>/dev/null | head -1)
    [[ -z "$LATEST" ]] && exit 0

    if [[ -f "$URL_FILE" ]]; then
      URL=$(cat "$URL_FILE")
      ${pkgs.exiftool}/bin/exiftool -overwrite_original -Comment="$URL" "$LATEST" &>/dev/null
    fi
  '';
in
{
  systemd.user.paths.screenshot-url-tag = {
    Unit.Description = "Watch for new screenshots";
    Path = {
      PathChanged = "%h/Pictures/Screenshots";
      Unit = "screenshot-url-tag.service";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.screenshot-url-tag = {
    Unit.Description = "Tag latest screenshot with active URL";
    Service = {
      Type = "oneshot";
      ExecStart = "${script}";
    };
  };
}
