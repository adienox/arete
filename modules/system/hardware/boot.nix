{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.sbctl ];
  boot.loader = {
    efi.canTouchEfiVariables = true;
    timeout = 1;
  };

  boot.loader.limine = {
    enable = true;
    maxGenerations = 8;

    style = {
      wallpapers = [ ./assets/limine-wallpaper.png ];
      wallpaperStyle = "stretched";

      graphicalTerminal = {
        font.scale = "2x2";
        font.spacing = 1;
        margin = 64;
        marginGradient = 20;
      };
    };

    secureBoot = {
      enable = true;
      autoGenerateKeys = true;
      autoEnrollKeys = {
        enable = true;
        extraArgs = [
          "--microsoft"
          "--firmware-builtin"
        ];
      };
    };

    extraConfig = ''
      quiet: yes
      terse: yes
      firmware_logo: yes
    '';
  };

  boot.plymouth.enable = true;
  boot.plymouth.theme = "bgrt";
  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=false"
    "systemd.show_status=false"
    "vt.global_cursor_default=0"
  ];
}
