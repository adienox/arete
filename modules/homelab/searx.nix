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

  services.caddy.virtualHosts."http://search.arete.io".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString config.services.searx.settings.server.port}
  '';

  sops.secrets."services/searx/secret-key" = { };

  sops.templates."searx.env" = {
    content = ''
      SEARX_SECRET_KEY=${config.sops.placeholder."services/searx/secret-key"}
    '';
    restartUnits = [ "searx.service" ];
  };
}
