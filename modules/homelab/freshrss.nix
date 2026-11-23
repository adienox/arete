{ pkgs, config, vars, ... }:
let
  buildExt = pkgs.freshrss-extensions.buildFreshRssExtension;
in
{
  services.freshrss = {
    enable = true;
    baseUrl = "http://rss.${vars.domain}";
    defaultUser = "nox";
    api.enable = true;
    passwordFile = config.sops.secrets."services/freshrss".path;
    webserver = "caddy";
    virtualHost = "http://rss.${vars.domain}";
    extensions = [
      (buildExt {
        FreshRssExtUniqueId = "af_readability";
        pname = "af-readability";
        version = "master-2026-11-20";
        src = pkgs.fetchFromGitHub {
          owner = "Niehztog";
          repo = "freshrss-af-readability";
          rev = "082472c34368a564ee7efdde29124ff68b021903";
          hash = "sha256-ClcNJLdXVWfwsqPPiFZlJDlFuUAUcU1i0ElhjDrRNQ8=";
        };
      })
      (buildExt {
        FreshRssExtUniqueId = "freshrss-comicsinfeed";
        pname = "freshrss-comicsinfeed";
        version = "1.6";
        src = pkgs.fetchFromGitHub {
          owner = "giventofly";
          repo = "freshrss-comicsinfeed";
          rev = "525027dafe9c6a80c4aee4b11cee1007416bad7a";
          hash = "sha256-9G7B3SfpaXJQmJ4WL0VwkEkdXZuCflRWonX+lzIKfKc=";
        };
      })
    ];
  };

  sops.secrets."services/freshrss" = {
    owner = "freshrss";
    group = "freshrss";
    mode = "0400";
  };

  # FreshRSS manages its own Caddy vhost (webserver = "caddy"), so only
  # request a DNS record here.
  homelab.dns.hosts.rss = { };
}
