{
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";

    configHome = "/home/nox";

    logs = {
      save = true;
      path = "/tmp/dms-greeter.log";
    };
  };
}
