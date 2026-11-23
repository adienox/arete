{ config, ... }: {
  virtualisation.quadlet.containers.redlib = {
    autoStart = true;
    containerConfig = {
      image = "ghcr.io/nachtalb/redlib:latest";
      publishPorts = [ "9090:8080" ];
      user = "nobody";

      readOnly = true;
      noNewPrivileges = true;
      dropCapabilities = [ "all" ];

      volumes = [
        "${config.sops.secrets."containers/redlib".path}:/cookie:ro"
      ];

      environments = {
        # Instance-specific settings
        REDLIB_SFW_ONLY = "off";
        REDLIB_BANNER = "";
        REDLIB_ROBOTS_DISABLE_INDEXING = "off";
        REDLIB_PUSHSHIFT_FRONTEND = "undelete.pullpush.io";
        REDLIB_REDDIT_COOKIE_FILE = "/cookie";
        REDLIB_STALE_CACHE_MB = "32";
        REDLIB_STALE_CACHE_MAX_AGE = "360";
        REDLIB_ENABLE_SCRAPE_FALLBACK = "on";
        REDLIB_SCRAPE_COMMENT_PREFETCH = "0";
        REDLIB_GQL_FEED_REQUESTS = "2";
        REDLIB_ENDPOINTS = "";
        REDLIB_ENABLE_RSS = "on";

        # Default user settings
        REDLIB_DEFAULT_THEME = "system";
        REDLIB_DEFAULT_FRONT_PAGE = "default";
        REDLIB_DEFAULT_LAYOUT = "card";
        REDLIB_DEFAULT_WIDE = "off";
        REDLIB_DEFAULT_POST_SORT = "hot";
        REDLIB_DEFAULT_COMMENT_SORT = "confidence";
        REDLIB_DEFAULT_BLUR_SPOILER = "off";
        REDLIB_DEFAULT_SHOW_NSFW = "on";
        REDLIB_DEFAULT_BLUR_NSFW = "off";
        REDLIB_DEFAULT_USE_HLS = "on";
        REDLIB_DEFAULT_HIDE_HLS_NOTIFICATION = "off";
        REDLIB_DEFAULT_AUTOPLAY_VIDEOS = "off";
        REDLIB_DEFAULT_SUBSCRIPTIONS = "";
        REDLIB_DEFAULT_FILTERS = "";
        REDLIB_DEFAULT_HIDE_AWARDS = "on";
        REDLIB_DEFAULT_HIDE_SIDEBAR_AND_SUMMARY = "off";
        REDLIB_DEFAULT_DISABLE_VISIT_REDDIT_CONFIRMATION = "on";
        REDLIB_DEFAULT_HIDE_SCORE = "off";
        REDLIB_DEFAULT_FIXED_NAVBAR = "on";
        REDLIB_DEFAULT_GEO_FILTER = "GLOBAL";
        REDLIB_DEFAULT_CLEAN_URLS = "on";
        REDLIB_DEFAULT_POSTS_PER_PAGE = "25";
        REDLIB_DEFAULT_MAX_COMMENT_THREAD_DEPTH = "0";
        REDLIB_DEFAULT_MORE_REPLIES_NEW_PAGE = "off";
      };
    };
    serviceConfig.TimeoutStartSec = "60";
  };

  sops.secrets."containers/redlib" = {
    owner = "nobody";
    mode = "0400";
    restartUnits = [ "redlib.service" ];
  };

  homelab.dns.hosts.redlib = 9090;
}
