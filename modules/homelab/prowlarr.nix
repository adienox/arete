{ ... }: {
  services.prowlarr = {
    enable = true;
  };

  services.flaresolverr.enable = true;

  homelab.dns.hosts.prowlarr = 9696;
}
