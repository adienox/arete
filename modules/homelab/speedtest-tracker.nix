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
      APP_KEY_FILE = config.sops.secrets."services/speedtest-tracker".path;
      SPEEDTEST_SCHEDULE = "*/30 * * * *";
      DISPLAY_TIMEZONE = "Asia/Kathmandu";
    };
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

  # speedtest-tracker serves a PHP app (no reverse_proxy), so it manages its
  # own Caddy vhost below; only request a DNS record here.
  homelab.dns.hosts.speedtest = { };
}
