{ vars, ... }:
{
  sops = {
    age.sshKeyPaths = [ "${vars.home}/.ssh/id_ed25519" ];
    defaultSopsFile = ../../secrets/secrets.sops.yaml;
    secrets."services/tailscale" = { };
    secrets."services/github" = { };
  };

  # System secrets are decrypted by the initrd activation script, before
  # /home is normally mounted, but the age identity above lives in the
  # user's home. Without mounting /home early, sops fails with
  #   Cannot read ssh key '${vars.home}/.ssh/id_ed25519': No such file or directory
  # and system secrets (e.g. services/tailscale) are never created.
  fileSystems."/home".neededForBoot = true;
}
