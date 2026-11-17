{
  services.audiobookshelf = {
    enable = true;
    openFirewall = true;
  };

  services.caddy.virtualHosts."http://abs.arete.io".extraConfig = ''
    reverse_proxy 127.0.0.1:8000
  '';
}
