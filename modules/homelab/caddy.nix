{ ... }: {
  services.caddy = {
    enable = true;
    email = "adwait@adhk.dev";
    openFirewall = true;
  };

  homelab.dns.hosts.fitness = 3004;
}
