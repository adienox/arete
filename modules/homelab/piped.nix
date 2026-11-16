{ config, pkgs, ... }:
let
  inherit (config.virtualisation.quadlet) networks;

  frontendEntrypoint = pkgs.writeScript "piped-frontend-entrypoint" ''
    #!/bin/sh
    sed -i "s#https://pipedapi.kavin.rocks#$API_URL#g; s#pipedapi.kavin.rocks#$BACKEND_HOSTNAME#g" /usr/share/nginx/html/assets/*
    /docker-entrypoint.sh
    exec nginx -g "daemon off;"
  '';
in
{
  virtualisation.quadlet = {
    networks.piped = { };

    containers = {
      piped-postgres = {
        autoStart = true;
        containerConfig = {
          image = "docker.io/library/postgres:16-alpine";
          containerName = "piped-postgres";
          networks = [ networks.piped.ref ];
          networkAliases = [ "postgres" ];
          environments = {
            POSTGRES_DB = "piped";
            POSTGRES_USER = "piped";
          };
          environmentFiles = [ config.sops.templates."piped-postgres.env".path ];
          volumes = [ "/var/lib/piped/postgres:/var/lib/postgresql/data" ];
        };
        serviceConfig = {
          Restart = "always";
          TimeoutStartSec = "120";
        };
      };

      piped-backend = {
        autoStart = true;
        containerConfig = {
          image = "ghcr.io/spendable1569/piped-backend:beta";
          containerName = "piped-backend";
          networks = [ networks.piped.ref ];
          networkAliases = [ "piped" ];
          publishPorts = [ "8081:8080" ];
          volumes = [
            "${config.sops.templates."piped-config.properties".path}:/app/config.properties:ro"
          ];
        };
        unitConfig = {
          Requires = [ "piped-postgres.service" ];
          After = [ "piped-postgres.service" ];
        };
        serviceConfig = {
          Restart = "always";
          TimeoutStartSec = "120";
        };
      };

      piped-proxy = {
        autoStart = true;
        containerConfig = {
          image = "docker.io/1337kavin/piped-proxy:latest";
          containerName = "piped-proxy";
          networks = [ networks.piped.ref ];
          publishPorts = [ "8082:8080" ];
        };
        serviceConfig = {
          Restart = "always";
          TimeoutStartSec = "120";
        };
      };

      piped-frontend = {
        autoStart = true;
        containerConfig = {
          image = "docker.io/1337kavin/piped-frontend:latest";
          containerName = "piped-frontend";
          networks = [ networks.piped.ref ];
          publishPorts = [ "8080:80" ];
          addCapabilities = [ "NET_BIND_SERVICE" ];
          entrypoint = "/entrypoint.sh";
          volumes = [ "${frontendEntrypoint}:/entrypoint.sh:ro" ];
          environments = {
            API_URL = "https://anomaly:8081";
            BACKEND_HOSTNAME = "anomaly:8081";
          };
        };
        unitConfig = {
          Requires = [ "piped-backend.service" ];
          After = [ "piped-backend.service" ];
        };
        serviceConfig = {
          Restart = "always";
          TimeoutStartSec = "120";
        };
      };
    };
  };

  # Secrets
  sops.secrets."container/piped-postgres".restartUnits = [
    "piped-postgres.service"
    "piped-backend.service"
  ];

  sops.templates."piped-postgres.env".content = ''
    POSTGRES_PASSWORD=${config.sops.placeholder."container/piped-postgres"}
  '';

  # Paste your existing config.properties here; only the password changes
  sops.templates."piped-config.properties" = {
    restartUnits = [ "piped-backend.service" ];
    content = ''
      PORT:8080
      HTTP_WORKERS: 2
      PROXY_PART: http://anomaly:8082
      API_URL: http://anomaly:8081
      FRONTEND_URL: http://anomaly:8080

      Set true to disable new account registration
      DISABLE_REGISTRATION: false
      COMPROMISED_PASSWORD_CHECK: true
      DISABLE_SERVER_SIDE_REQUESTS: false

      hibernate.connection.url:jdbc:postgresql://postgres:5432/piped
      hibernate.connection.username:piped
      hibernate.connection.password:${config.sops.placeholder."containers/piped-postgres"}
    '';
  };

  systemd.tmpfiles.rules = [ "d /var/lib/piped/postgres 0755 root root -" ];
}
