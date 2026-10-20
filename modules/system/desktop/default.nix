# Desktop/GUI cluster. Imported by modules/profiles/desktop.nix.
{
  imports = [
    ./niri.nix
    ./polkit.nix
    ./dms-greeter.nix
    ./fonts.nix
    ./audio.nix
    ./audio-devices.nix
    ./bluetooth.nix
    ./monitor.nix
    ./xremap.nix
    ./power.nix
  ];

  programs.dconf.enable = true;

  services = {
    logind.settings.Login = {
      HandlePowerKey = "suspend";
    };

    libinput.enable = true;
    ddccontrol.enable = true;
  };
  services = {
    gvfs.enable = true;
    tumbler.enable = true;
    gnome = {
      sushi.enable = true;
      localsearch.enable = true;
    };
  };

  environment = {
    # https://unix.stackexchange.com/a/657578
    variables = {
      LIBSEAT_BACKEND = "logind";
    };

    # hint electron apps to use wayland:
    sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
