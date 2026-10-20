{ lib, config, vars, ... }: {

  options.modules.xremap = {
    enable = lib.mkEnableOption "xremap";
  };

  config = lib.mkIf config.modules.xremap.enable {
    hardware.uinput.enable = true;
    users.groups.uinput.members = [ vars.user ];
    users.groups.input.members = [ vars.user ];
    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", TAG+="uaccess"
    '';

    programs.ydotool.enable = true;
    users.groups.ydotool.members = [ vars.user ];
  };
}
