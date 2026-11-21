{ vars, ... }: {
  services.audiobookshelf = {
    enable = true;
    openFirewall = true;
  };

  services.caddy.virtualHosts."http://abs.${vars.domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:8000
  '';
}
