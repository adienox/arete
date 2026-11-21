{ vars, ... }: {
  services.prowlarr = {
    enable = true;
  };

  services.flaresolverr.enable = true;

  services.caddy.virtualHosts."http://prowlarr.${vars.domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:9696
  '';
}
