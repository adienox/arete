{ vars, ... }:
{
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";

    configHome = vars.home;

    logs = {
      save = true;
      path = "/tmp/dms-greeter.log";
    };
  };
}
