{ pkgs, vars, ... }: {
  users.users.dynacat = {
    isSystemUser = true;
    group = "dynacat";
  };

  users.groups.dynacat = { };

  users.users.${vars.user}.extraGroups = [ "dynacat" ];

  systemd.tmpfiles.rules = [
    "d /var/lib/dynacat 0775 dynacat dynacat -"
  ];

  systemd.services.dynacat = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.dynacat}/bin/dynacat --config /var/lib/dynacat/dynacat.yml";
      User = "dynacat";
      Group = "dynacat";
      WorkingDirectory = "/var/lib/dynacat";
      Restart = "on-failure";
    };
  };

  homelab.dns.hosts.homepage = 1337;
}
