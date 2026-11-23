{ config, ... }: {
  services.radicale = {
    enable = true;
    settings = {
      server.hosts = [ "127.0.0.1:5232" ];
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.sops.secrets."services/radicale".path;
        htpasswd_encryption = "bcrypt";
      };
    };
  };
  sops.secrets."services/radicale" = {
    owner = "radicale";
    restartUnits = [ "radicale.service" ];
  };

  homelab.dns.hosts.cal = 5232;
}
