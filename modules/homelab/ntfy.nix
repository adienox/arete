{
  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = ":2020";
      base-url = "http://ntfy.arete.io";
    };
  };

  services.caddy.virtualHosts."http://ntfy.arete.io".extraConfig = ''
    reverse_proxy 127.0.0.1:2020
  '';
}
