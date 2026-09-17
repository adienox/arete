{
  sops = {
    age.sshKeyPaths = [ "/home/nox/.ssh/id_ed25519" ];
    defaultSopsFile = ../secrets/secrets.sops.yaml;
    secrets."services/tailscale" = { };
  };
}
