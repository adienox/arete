{ config, ... }: {
  services.freshrss = {
    enable = true;
    baseUrl = "http://rss.arete.io";
    defaultUser = "nox";
    api.enable = true;
    passwordFile = config.sops.secrets."services/freshrss".path;
    webserver = "caddy";
    virtualHost = "rss.arete.io";
  };

  services.caddy.virtualHosts."rss.arete.io".extraConfig = ''
    tls internal
  '';

  sops.secrets."services/freshrss" = { };
}
