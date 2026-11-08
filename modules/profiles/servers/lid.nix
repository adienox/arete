# Laptop used as a server: closing the lid must not suspend the machine.
#
# logind ignores the lid (default is to suspend) and acpid powers the panel
# backlight off, so the machine keeps serving with the lid shut.
{
  lib,
  ...
}:
{
  services.logind.settings.Login = {
    HandleLidSwitch = lib.mkDefault "ignore";
    HandleLidSwitchExternalPower = lib.mkDefault "ignore";
    HandleLidSwitchDocked = lib.mkDefault "ignore";
  };

  services.acpid = {
    enable = true;

    # Run on button/lid events. Read the ACPI lid state directly (instead of
    # parsing the event payload) and toggle the panel backlight:
    # bl_power=1 is DPMS off, bl_power=0 brings it back.
    lidEventCommands = ''
      lid=""
      for f in /proc/acpi/button/lid/*/state; do
        [ -r "$f" ] || continue
        read -r _ lid < "$f"
        break
      done

      case "$lid" in
        closed)
          for bl in /sys/class/backlight/*; do
            [ -w "$bl/bl_power" ] && echo 1 > "$bl/bl_power"
          done
          ;;
        open)
          for bl in /sys/class/backlight/*; do
            [ -w "$bl/bl_power" ] && echo 0 > "$bl/bl_power"
          done
          ;;
      esac
    '';
  };
}
