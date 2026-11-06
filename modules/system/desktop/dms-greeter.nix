{ vars, ... }:
{
  services.displayManager = {
    dux-greeter = {
      enable = true;
      compositor.name = "niri";

      configHome = vars.home;

      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };
    };
  };

  security.pam.services.greetd = {
    fprintAuth = true;
    enableGnomeKeyring = true;
  };
}
