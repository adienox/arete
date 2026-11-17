{ lib, ... }: {
  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;
  };

  services.resolved.settings.Resolve.DNSStubListener = "no";

  networking.nameservers = lib.mkForce [
    "127.0.0.1"
    "1.1.1.1" # fallback
  ];

  services.caddy.virtualHosts."http://dns.arete.io".extraConfig = ''
    reverse_proxy 127.0.0.1:5380
  '';
}
