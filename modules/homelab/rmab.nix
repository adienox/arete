{ config, vars, ... }:
let
  dataDir = "/var/lib/readmeabook";
  uid = config.users.users.readmeabook.uid;
  gid = config.users.groups.media.gid;
in
{
  users.groups.media.gid = 2000;

  users.users.readmeabook = {
    isSystemUser = true;
    uid = 2001;
    group = "media";
    description = "ReadMeABook service user";
  };

  # Audiobookshelf reads/writes the library through the shared group
  users.users.audiobookshelf.extraGroups = [ "media" ];

  systemd.tmpfiles.rules = [
    "d ${dataDir}           0755 root root - -"
    "d ${dataDir}/config    0750 ${toString uid} ${toString gid} - -"
    "d ${dataDir}/cache     0750 ${toString uid} ${toString gid} - -"
    "d ${dataDir}/downloads 0775 ${toString uid} ${toString gid} - -"
    # setgid (2775) so new subfolders inherit the media group
    "d ${dataDir}/media     2775 ${toString uid} ${toString gid} - -"
    # pgdata/redis: the container entrypoint chowns these itself at startup
    # (postgres keeps UID 102). Don't switch these to Z/z.
    "d ${dataDir}/redis     0755 ${toString uid} ${toString gid} - -"
    "d ${dataDir}/pgdata    0700 102 ${toString gid} - -"
  ];

  virtualisation.quadlet.containers.readmeabook = {
    autoStart = true;

    containerConfig = {
      name = "readmeabook";
      image = "ghcr.io/kikootwo/readmeabook:latest";
      # autoUpdate = "registry"; # needs podman-auto-update.timer enabled
      publishPorts = [ "3030:3030" ];

      volumes = [
        "${dataDir}/config:/app/config"
        "${dataDir}/cache:/app/cache"
        "${dataDir}/downloads:/downloads"
        "${dataDir}/media:/media"
        "${dataDir}/pgdata:/var/lib/postgresql/data"
        "${dataDir}/redis:/var/lib/redis"
      ];

      environments = {
        PUID = toString uid;
        PGID = toString gid;
        UMASK = "002"; # group-writable: files 664, dirs 775
        PUBLIC_URL = "http://rmab.${vars.domain}";
      };

      healthCmd = "curl -f http://localhost:3030/api/health";
      healthInterval = "30s";
      healthTimeout = "10s";
      healthRetries = 3;
      healthStartPeriod = "60s";

      stopTimeout = 90;
    };

    serviceConfig = {
      Restart = "always";
      TimeoutStopSec = "100";
    };
  };

  homelab.dns.hosts.rmab = 3030;
}
