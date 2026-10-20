{ hostname, vars, ... }: {
  sops = {
    age.sshKeyPaths = [ "${vars.home}/.ssh/id_ed25519" ];
    defaultSopsFile = ../secrets/secrets.sops.yaml;
    secrets = {
      "ids/email" = { };
      "syncthing/${hostname}/cert" = { };
      "syncthing/${hostname}/key" = { };
      "syncthing/password" = { };
      "services/homeassistant" = { };
      "services/freshrss" = { };
      "services/pi" = { };
      "services/dmsOpenRouter" = { };
    };
  };
}
