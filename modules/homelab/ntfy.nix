{ vars, ... }: {
  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = ":2020";
      base-url = "http://ntfy.${vars.domain}";
    };
  };

  homelab.dns.hosts.ntfy = 2020;
}
