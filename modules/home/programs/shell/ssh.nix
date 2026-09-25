{
  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;

        ControlMaster = "auto";
        ControlPath = "~/.ssh/sockets/%r@%h-%p";
        ControlPersist = "10m";
      };

      "hawk" = {
        HostName = "hawk";
        User = "u0_a141";
        Port = 8022;
      };
    };
  };

  # ControlPath needs the sockets/ directory to actually exist
  home.file.".ssh/sockets/.keep".text = "";
}
