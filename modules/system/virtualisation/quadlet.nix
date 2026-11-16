{ ... }: {
  virtualisation.quadlet = {
    enable = true;

    containers.nginx = {
      autoStart = true;
      containerConfig = {
        image = "docker.io/library/nginx:stable";
        publishPorts = [ "8888:80" ];
        volumes = [ "/srv/www:/usr/share/nginx/html:ro" ];
      };
      serviceConfig = {
        Restart = "always";
        TimeoutStartSec = "60";
      };
    };
  };

  # open the port if you want it reachable from the LAN
  networking.firewall.allowedTCPPorts = [ 8888 ];

  # make sure the served directory exists
  systemd.tmpfiles.rules = [ "d /srv/www 0755 root root -" ];
}
