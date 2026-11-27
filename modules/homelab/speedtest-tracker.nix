{ config, vars, ... }:
let
  cfg = config.services.speedtest-tracker;
  domain = "http://speedtest.${vars.domain}";
in
{
  services.speedtest-tracker = {
    enable = true;
    virtualHost = domain;
    group = config.services.caddy.group;
    settings = {
      APP_URL = domain;
      APP_KEY_FILE = config.sops.secrets."homelab/speedtest".path;
      SPEEDTEST_SCHEDULE = "*/30 * * * *";
      DISPLAY_TIMEZONE = "Asia/Kathmandu";
    };
  };

  sops.secrets."homelab/speedtest" = {
    owner = "speedtest-tracker";
    restartUnits = [ "speedtest-tracker.service" ];
  };

  homelab.dns.hosts.speedtest.extraConfig = ''
    root * ${cfg.package}/public
    php_fastcgi unix/${config.services.phpfpm.pools.speedtest-tracker.socket}
    file_server
  '';
}
