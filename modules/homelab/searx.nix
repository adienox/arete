{ config, ... }: {
  services.searx = {
    enable = true;
    settings = {
      server.port = 9898;
      server.bind_address = "0.0.0.0";
      server.secret_key = "$SEARX_SECRET_KEY";
    };
    environmentFile = config.sops.templates."searx.env".path;
  };

  sops.secrets."services/searx/secret-key" = { };

  sops.templates."searx.env" = {
    content = ''
      SEARX_SECRET_KEY=${config.sops.placeholder."services/searx/secret-key"}
    '';
    restartUnits = [ "searx.service" ];
  };

  homelab.dns.hosts.search = config.services.searx.settings.server.port;
}
