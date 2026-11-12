{
  vars,
  config,
  ...
}:
{
  sops = {
    age.sshKeyPaths = [ "${vars.home}/.ssh/id_ed25519" ];
    defaultSopsFile = ../secrets/secrets.sops.yaml;
  };

  sops.secrets."services/karakeep" = { };
  xdg.configFile."karakeep/config.json".text = builtins.toJSON {
    url = "https://karakeep.chipmunk-teeth.ts.net";
    api_key_file = config.sops.secrets."services/karakeep".path;
  };
}
