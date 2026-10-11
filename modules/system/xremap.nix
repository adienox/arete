{ lib, config, ... }: {

  options.modules.xremap = {
    enable = lib.mkEnableOption "xremap";
  };

  config = lib.mkIf config.modules.xremap.enable {
    hardware.uinput.enable = true;
    users.groups.uinput.members = [ "nox" ];
    users.groups.input.members = [ "nox" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", TAG+="uaccess"
    '';

    programs.ydotool.enable = true;
    users.groups.ydotool.members = [ "nox" ];
  };
}
