{ pkgs, ... }:
let
  youtube-icon = pkgs.fetchurl {
    url = "https://www.youtube.com/s/desktop/dbf5c200/img/favicon_144x144.png";
    hash = "sha256-lQ5gbLyoWCH7cgoYcy+WlFDjHGbxwB8Xz0G7AZnr9vI=";
  };
  brave-icon = pkgs.fetchurl {
    url = "https://brave.com/static-assets/images/brave-logo-sans-text.svg";
    hash = "sha256-JTD4D98hRLYvlpU6gcaYjJwxpsx8necuBpB5SFgXy+c=";
  };
in
{
  programs.zen-browser.profiles.default.search = {
    force = true; # Enforce declared search engines on each rebuild
    default = "brave";
    engines = {
      nixpkgs = {
        urls = [
          {
            template = "https://search.nixos.org/packages";
            params = [
              {
                name = "type";
                value = "packages";
              }
              {
                name = "channel";
                value = "unstable";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "np" ];
      };
      mynixos = {
        name = "My NixOS";
        urls = [
          {
            template = "https://mynixos.com/search?q={searchTerms}";
            params = [
              {
                name = "query";
                value = "searchTerms";
              }
            ];
          }
        ];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "nx" ];
      };
      github = {
        name = "GitHub Search";
        urls = [
          {
            template = "https://github.com/search?q={searchTerms}";
          }
        ];
        definedAliases = [ "gh" ];
      };
      youtube = {
        urls = [
          {
            template = "https://www.youtube.com/results";
            params = [
              {
                name = "search_query";
                value = "{searchTerms}";
              }
            ];
          }
        ];

        icon = youtube-icon;
        definedAliases = [ "yt" ];
      };
      brave = {
        urls = [
          {
            template = "https://search.brave.com/search";
            params = [
              {
                name = "q";
                value = "{searchTerms}";
              }
            ];
          }
        ];

        icon = brave-icon;
        definedAliases = [ "bb" ];
      };
      google.metaData.alias = "gg";
    };
  };
}
