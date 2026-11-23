{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  inherit (config.virtualisation.quadlet) networks;

  common = {
    autoStart = true;
    containerConfig.networks = [ networks.piped.ref ];
    serviceConfig = {
      Restart = "always";
      TimeoutStartSec = "120";
    };
  };

  frontendEntrypoint = pkgs.writeScript "piped-frontend-entrypoint" ''
    #!/bin/sh
    sed -i "s#https://pipedapi.kavin.rocks#$API_URL#g; s#pipedapi.kavin.rocks#$BACKEND_HOSTNAME#g" /usr/share/nginx/html/assets/*
    exec /docker-entrypoint.sh nginx -g "daemon off;"
  '';
in
{
  virtualisation.quadlet = {
    networks.piped = { };

    containers = {
      piped-postgres = lib.mkMerge [
        common
        {
          containerConfig = {
            image = "docker.io/library/postgres:16-alpine";
            networkAliases = [ "postgres" ];
            environments = {
              POSTGRES_DB = "piped";
              POSTGRES_USER = "piped";
            };
            environmentFiles = [ config.sops.templates."piped-postgres.env".path ];
            volumes = [ "/var/lib/piped/postgres:/var/lib/postgresql/data" ];
          };
        }
      ];

      piped-backend = lib.mkMerge [
        common
        {
          containerConfig = {
            image = "ghcr.io/spendable1569/piped-backend:beta";
            publishPorts = [ "8081:8080" ];
            volumes = [
              "${config.sops.templates."piped-config.properties".path}:/app/config.properties:ro"
            ];
            environments = {
              DISABLE_PUBSUB = "true"; # disabling YouTube websub as this is a private instance
              FEED_REFRESH = "true";
            };
          };
          unitConfig = {
            Requires = [ "piped-postgres.service" ];
            After = [ "piped-postgres.service" ];
          };
        }
      ];

      piped-proxy = lib.mkMerge [
        common
        {
          containerConfig = {
            image = "docker.io/1337kavin/piped-proxy:latest";
            publishPorts = [ "8082:8080" ];
          };
        }
      ];

      piped-frontend = lib.mkMerge [
        common
        {
          containerConfig = {
            image = "docker.io/1337kavin/piped-frontend:latest";
            publishPorts = [ "8080:80" ];
            addCapabilities = [ "NET_BIND_SERVICE" ];
            entrypoint = "/entrypoint.sh";
            volumes = [ "${frontendEntrypoint}:/entrypoint.sh:ro" ];
            environments = {
              API_URL = "https://piped-api.${vars.domain}";
              BACKEND_HOSTNAME = "piped-api.${vars.domain}";
              HTTP_MODE = "https";
            };
          };
        }
      ];
    };
  };

  sops.secrets."containers/piped-postgres" = { };

  sops.templates."piped-postgres.env".content = ''
    POSTGRES_PASSWORD=${config.sops.placeholder."containers/piped-postgres"}
  '';

  sops.templates."piped-config.properties" = {
    restartUnits = [ "piped-backend.service" ];
    content = ''
      PORT:8080
      HTTP_WORKERS: 2
      PROXY_PART: https://piped-proxy.${vars.domain}
      API_URL: https://piped-api.${vars.domain}
      FRONTEND_URL: https://piped.${vars.domain}

      # Set true to disable new account registration
      DISABLE_REGISTRATION: false
      COMPROMISED_PASSWORD_CHECK: true
      DISABLE_SERVER_SIDE_REQUESTS: false

      hibernate.connection.url:jdbc:postgresql://postgres:5432/piped
      hibernate.connection.username:piped
      hibernate.connection.password:${config.sops.placeholder."containers/piped-postgres"}
    '';
  };

  systemd.tmpfiles.rules = [ "d /var/lib/piped/postgres 0755 root root -" ];

  homelab.dns.hosts = {
    piped = 8080;
    piped-api = 8081;
    piped-proxy = 8082;
  };
}
