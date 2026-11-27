{
  pkgs,
  helpers,
  vars,
  ...
}:
let
  yamlFormat = pkgs.formats.yaml { };
  ntfyConfig = yamlFormat.generate "client.yml" {
    default-host = "https://ntfy.${vars.domain}";
  };
in
{
  home.packages = [ pkgs.ntfy-sh ];

  home.file = helpers.mkConfigFile {
    target = ".config/ntfy/client.yml";
    source = ntfyConfig;
  };
}
