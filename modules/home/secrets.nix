{ hostname, ... }: {
  sops = {
    age.sshKeyPaths = [ "/home/nox/.ssh/id_ed25519" ];
    defaultSopsFile = ../secrets/secrets.sops.yaml;
    secrets = {
      "ids/email" = { };
      "syncthing/${hostname}/cert" = { };
      "syncthing/${hostname}/key" = { };
      "syncthing/password" = { };
      "services/homeassistant" = { };
      "services/freshrss" = { };
    };
  };
}
