{ config, ... }:
let
  cfg = config.services.speedtest-tracker;
  domain = "http://speedtest.arete.io";
in
{
  services.speedtest-tracker = {
    enable = true;
    virtualHost = domain;
    group = config.services.caddy.group;
    settings.APP_URL = domain;
    settings.APP_KEY_FILE = config.sops.secrets."services/speedtest-tracker".path;
  };

  sops.secrets."services/speedtest-tracker" = {
    owner = "speedtest-tracker";
    restartUnits = [ "speedtest-tracker.service" ];
  };

  services.caddy.virtualHosts.${domain}.extraConfig = ''
    root * ${cfg.package}/public
    php_fastcgi unix/${config.services.phpfpm.pools.speedtest-tracker.socket}
    file_server
  '';
}
