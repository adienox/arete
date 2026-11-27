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

  sops.secrets."homelab/karakeep/api-key" = { };
  xdg.configFile."karakeep/config.json".text = builtins.toJSON {
    url = "https://karakeep.${vars.domain}";
    api_key_file = config.sops.secrets."homelab/karakeep/api-key".path;
  };
}
