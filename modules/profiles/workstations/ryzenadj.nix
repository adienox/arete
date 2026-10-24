{ pkgs, ... }:
let
  ryzenadj = "${pkgs.ryzenadj}/bin/ryzenadj";

  powerProfile = pkgs.writeShellScript "ryzenadj-power-profile" ''
    sleep 1   # let the battery status settle after a plug/unplug event

    on_battery=0
    for b in /sys/class/power_supply/BAT*; do
      [ -r "$b/status" ] || continue
      [ "$(cat "$b/status")" = "Discharging" ] && on_battery=1
    done

    if [ "$on_battery" = 1 ]; then
      exec ${ryzenadj} --stapm-limit=18000 --slow-limit=22000 --fast-limit=25000 --tctl-temp=85
    else
      exec ${ryzenadj} --stapm-limit=28000 --slow-limit=28000 --fast-limit=30000 --tctl-temp=95
    fi
  '';
in
{
  systemd.services.ryzenadj-power = {
    description = "Apply RyzenAdj limits based on power source";
    wantedBy = [
      "multi-user.target"
      "post-resume.target"
    ];
    after = [
      "multi-user.target"
      "post-resume.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = powerProfile;
    };
  };

  # Re-run whenever the power supply state changes (plug/unplug)
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ACTION=="change", TAG+="systemd", ENV{SYSTEMD_WANTS}+="ryzenadj-power.service"
  '';
}
