{
  services.caddy = {
    enable = true;
    email = "you@example.com";
    openFirewall = true;
    virtualHosts."http://redlib.arete.io".extraConfig = ''
      reverse_proxy 127.0.0.1:9090
    '';
  };
}
