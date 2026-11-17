{
  services.prowlarr = {
    enable = true;
  };

  services.caddy.virtualHosts."http://prowlarr.arete.io".extraConfig = ''
    reverse_proxy 127.0.0.1:9696
  '';
}
