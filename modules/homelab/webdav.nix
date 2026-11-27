{ config, ... }:
{
  sops.secrets."services/webdav/rikka" = {
    owner = "webdav";
    group = "webdav";
    mode = "0400";
  };
  sops.secrets."services/webdav/nox" = {
    owner = "webdav";
    group = "webdav";
    mode = "0400";
  };

  sops.templates."webdav.env" = {
    content = ''
      RIKKA_PASSWORD=${config.sops.placeholder."homelab/webdav/rikka"}
      NOX_PASSWORD=${config.sops.placeholder."homelab/webdav/nox"}
    '';
    restartUnits = [ "webdav.service" ];
  };

  services.webdav = {
    enable = true;
    environmentFile = config.sops.templates."webdav.env".path;
    settings = {
      address = "0.0.0.0";
      port = 6065;
      users = [
        {
          username = "rikka";
          password = "{env}RIKKA_PASSWORD";
          directory = "/srv/webdav/rikkahub";
          permissions = "CRUD";
        }
        {
          username = "nox";
          password = "{env}NOX_PASSWORD";
          directory = "/srv/webdav/nox";
          permissions = "CRUD";
        }
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/webdav          0750 webdav webdav -"
    "d /srv/webdav/rikkahub 0750 webdav webdav -"
    "d /srv/webdav/nox      0750 webdav webdav -"
  ];

  homelab.dns.hosts.webdav = config.services.webdav.settings.port;
}
