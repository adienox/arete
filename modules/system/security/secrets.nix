{ vars, ... }:
{
  sops = {
    age.sshKeyPaths = [ "${vars.home}/.ssh/id_ed25519" ];
    defaultSopsFile = ../../secrets/secrets.sops.yaml;
    secrets."services/tailscale" = { };
    secrets."services/github" = { };
  };
}
