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
}
