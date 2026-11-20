{ lib, ... }: {
  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;
  };
  # give ability to bind to addresses like tailscale even without them existing
  # this fixes the race condition between tailscale and technituim
  boot.kernel.sysctl."net.ipv4.ip_nonlocal_bind" = 1;

  services.resolved.settings.Resolve.DNSStubListener = "no";

  networking.nameservers = lib.mkForce [
    "127.0.0.1"
    "1.1.1.1" # fallback
  ];

  services.caddy.virtualHosts."http://dns.arete.io".extraConfig = ''
    reverse_proxy 127.0.0.1:5380
  '';

  networking.firewall.interfaces."tailscale0" = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
