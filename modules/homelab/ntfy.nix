{ vars, ... }: {
  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = ":2020";
      base-url = "http://ntfy.${vars.domain}";
    };
  };

  services.caddy.virtualHosts."http://ntfy.${vars.domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:2020
  '';
}
