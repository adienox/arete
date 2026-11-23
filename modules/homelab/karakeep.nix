{ config, vars, ... }:
{
  services.karakeep = {
    enable = true;

    extraEnvironment = {
      PORT = "3000";
      NEXTAUTH_URL = "http://karakeep.${vars.domain}";
      DISABLE_SIGNUPS = "false";
      DISABLE_NEW_RELEASE_CHECK = "true";

      CRAWLER_FULL_PAGE_ARCHIVE = "true";
      CRAWLER_VIDEO_DOWNLOAD = "true";
      CRAWLER_VIDEO_DOWNLOAD_MAX_SIZE = "-1";
      CRAWLER_YTDLP_ARGS = "--user-agent 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'";
      OPENAI_BASE_URL = "https://openrouter.ai/api/v1";

      INFERENCE_TEXT_MODEL = "openai/gpt-6-luna-pro";
      INFERENCE_IMAGE_MODEL = "openai/gpt-6-luna-pro";
      EMBEDDING_TEXT_MODEL = "openai/text-embedding-3-small";
    };

    environmentFile = config.sops.templates."karakeep.env".path;
  };

  sops.secrets."services/karakeep/ai-key" = { };

  sops.templates."karakeep.env" = {
    content = ''
      OPENAI_API_KEY=${config.sops.placeholder."services/karakeep/ai-key"}
    '';
    restartUnits = [
      "karakeep-web.service"
      "karakeep-workers.service"
    ];
  };

  homelab.dns.hosts.karakeep = {
    upstream = "127.0.0.1:${config.services.karakeep.extraEnvironment.PORT}";
  };
}
