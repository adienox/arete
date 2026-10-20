# Networking primitives: connectivity, remote access and network tooling.
{
  imports = [
    ./networking.nix
    ./ssh.nix
    ./tailscale.nix
    ./wireshark.nix
  ];
}
