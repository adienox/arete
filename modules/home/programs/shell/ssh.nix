{
  vars,
  ...
}:
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

      "koreader" = {
        HostName = "kindle";
        User = "root";
        Port = 2222;
        RemoteCommand = "cd /mnt/us/koreader && bash -l";
        RequestTTY = "yes";
      };

      "services" = {
        HostName = "impel";
        User = vars.user;
        RemoteCommand = "cd ${vars.home}/services && fish -l";
        RequestTTY = "yes";
      };

      "kindle" = {
        HostName = "kindle";
        User = "root";
        Port = 2222;
      };
    };
  };

  # ControlPath needs the sockets/ directory to actually exist
  home.file.".ssh/sockets/.keep".text = "";
}
