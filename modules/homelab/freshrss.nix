{ config, ... }: {
  services.freshrss = {
    enable = true;
    baseUrl = "http://rss.arete.io";
    defaultUser = "nox";
    api.enable = true;
    passwordFile = config.sops.secrets."services/freshrss".path;
    webserver = "caddy";
    virtualHost = "http://rss.arete.io";
  };

  sops.secrets."services/freshrss" = {
    owner = "freshrss";
    group = "freshrss";
    mode = "0400";
  };
}
