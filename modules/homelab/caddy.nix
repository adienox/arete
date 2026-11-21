{ vars, ... }: {
  services.caddy = {
    enable = true;
    email = "you@example.com";
    openFirewall = true;
  };

  services.caddy.virtualHosts."http://fitness.${vars.domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:3004
  '';
}
