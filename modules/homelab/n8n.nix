{
  config,
  lib,
  ...
}:
{
  sops.secrets."services/n8n-runners-auth" = { };

  services.n8n = {
    enable = true;
    taskRunners.enable = true;
    environment = {
      N8N_PORT = "5678";
      N8N_HOST = "n8n.arete.io";
      N8N_PROTOCOL = "http";
      WEBHOOK_URL = "http://n8n.arete.io/";
      GENERIC_TIMEZONE = "Asia/Kathmandu";
      TZ = "Asia/Kathmandu";
      N8N_DIAGNOSTICS_ENABLED = "false";
      N8N_RUNNERS_AUTH_TOKEN_FILE = config.sops.secrets."services/n8n-runners-auth".path;
      N8N_SECURE_COOKIE = false;
    };
  };

  # n8n's license (Sustainable Use) is classed as unfree in nixpkgs
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "n8n" ];

  services.caddy.virtualHosts."http://n8n.arete.io".extraConfig = ''
    reverse_proxy 127.0.0.1:${config.services.n8n.environment.N8N_PORT}
  '';
}
