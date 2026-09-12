{
  sops = {
    age.sshKeyPaths = [ "/home/nox/.ssh/id_ed25519" ];
    defaultSopsFile = ./secrets.sops.yaml;
  };
}
