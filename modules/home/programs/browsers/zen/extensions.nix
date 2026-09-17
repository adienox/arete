{ pkgs, config, ... }: {
  # nix run github:osipog/nix-firefox-addons#search-addon vimium
  programs.zen-browser.profiles.default = {
    extensionButtons = {
      "nav-bar" = [
        "addon@karakeep.app"
      ];
    };

    extensions = {
      packages = with pkgs.firefoxAddons; [
        bitwarden-password-manager
        darkreader
        enhancer-for-youtube
        facebook-container
        multi-account-containers
        imagus
        karakeep
        redirector
        refined-github-
        remove-youtube-s-suggestions
        sponsorblock
        ublock-origin
        tridactyl-vim
        clearurls
        skip-redirect
        github-file-icons
        watchmarker-for-youtube
        tab-reloader
        youtube-unhook
        vicinae
      ];

      settings."uBlock0@raymondhill.net" = {
        force = true;
        settings = {
          selectedFilterLists = [
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-unbreak"
            "easylist"
            "adguard-generic"
            "easyprivacy"
            "adguard-spyware-url"
            "urlhaus-1"
            "plowe-0"
            "fanboy-cookiemonster"
            "ublock-cookies-easylist"
            "adguard-cookies"
            "ublock-cookies-adguard"
            "fanboy-social"
            "adguard-social"
            "fanboy-ai-suggestions"
            "easylist-chat"
            "easylist-newsletters"
            "easylist-notifications"
            "easylist-annoyances"
            "adguard-mobile-app-banners"
            "adguard-other-annoyances"
            "adguard-popup-overlays"
            "adguard-widgets"
            "ublock-annoyances"
          ];
        };
      };
      settings."redirector@einaregilsson.com" = {
        force = true;
        settings = {
          enableNotifications = false;
          redirects = [
            {
              appliesTo = [ "main_frame" ];
              description = "Reddit -> redlib";
              disabled = false;
              error = null;
              exampleResult = "https://redlib.chipmunk-teeth.ts.net/r/linux/";
              exampleUrl = "https://www.reddit.com/r/linux/";
              excludePattern = "";
              grouped = false;
              includePattern = "^https?://(www\\.|old\\.|np\\.|new\\.)?reddit\\.com/(.*)";
              patternDesc = "Reddit links redirected to self-hosted redlib instance.";
              patternType = "R";
              processMatches = "noProcessing";
              redirectUrl = "https://redlib.catsarch.com/$2";
            }
            {
              appliesTo = [ "main_frame" ];
              description = "redd.it -> redlib";
              disabled = false;
              error = null;
              exampleResult = "https://redlib.chipmunk-teeth.ts.net/abc123";
              exampleUrl = "https://redd.it/abc123";
              excludePattern = "";
              grouped = false;
              includePattern = "^https?://redd\\.it/(.*)";
              patternDesc = "Reddit short links redirected to self-hosted redlib instance.";
              patternType = "R";
              processMatches = "noProcessing";
              redirectUrl = "https://redlib.catsarch.com/$1";
            }
          ];
        };
      };
      settings."tridactyl.vim@cmcaine.co.uk" = {
        force = true;
        settings = {
          theme = if config.programs.dank-material-shell.enable then "matugen" else "dark";
        };
      };
      settings."enhancerforyoutube@maximerf.addons.mozilla.org" = {
        force = true;
        settings = {
          controlbar = {
            active = false;
            autohide = false;
            centered = true;
            position = "absolute";
          };
          controlsvisible = false;
          convertshorts = true;
          disableautoplay = true;
          hidechat = false;
          hiderelated = true;
          hideshorts = true;
          miniplayerposition = "_bottom-right";
          newestcomments = false;
          qualityembeds = "hd1440";
          qualityplaylists = "hd1440";
          qualityvideos = "hd1440";
          selectquality = true;
          theatermode = true;
        };
      };
      settings."{21f1ba12-47e1-4a9b-ad4e-3a0260bbeb26}" = {
        force = true;
        settings = {
          add_reveal_end_of_video = false;
          add_reveal_homepage = false;
          add_reveal_sidebar = false;
          global_enable = true;
          normalize_shorts = true;
          redirect_to_subs = true;
          remove_all_shorts = true;
          remove_end_of_video = true;
          remove_homepage = true;
          remove_left_nav_bar = true;
          remove_search_suggestions = true;
          remove_sidebar = true;
        };
      };
    };
  };
}
