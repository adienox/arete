{ pkgs, inputs, ... }: {
  # nix run github:osipog/nix-firefox-addons#search-addon vimium
  #nixpkgs.overlays = [ inputs.nix-firefox-addons.overlays.default ];

  programs.zen-browser.nativeMessagingHosts = [
    inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.tridactyl-native
    pkgs.tab-handoff.host
  ];

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
        floccus
        pkgs.tab-handoff.xpi
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
          userconfig = {
            configversion = "2.0";
            hintfiltermode = "simple";
            hintchars = "asdfjkl;gh";
            nmaps = {
              "j" = "scrollline 5";
              "k" = "scrollline -5";
              "d" = "composite tabclose";
              "u" = "composite undo";
              "gg" = "scrollto 0";
              "G" = "scrollto 100";
              "J" = "tabnext";
              "K" = "tabprev";
              "gd" = "tabdetach";
              "gD" = "composite tabduplicate; tabdetach";
              "gm" = "tabmove +1";
              "gM" = "tabmove -1";
              "gng" = "tabopen https://github.com";
              "gog" = "open https://github.com";
              "gwg" = "winopen https://github.com";
              "gpg" = "winopen -private https://github.com";
              "gnn" = "tabopen https://search.nixos.org/packages";
              "gon" = "open https://search.nixos.org/packages";
              "gwn" = "winopen https://search.nixos.org/packages";
              "gpn" = "winopen -private https://search.nixos.org/packages";
              "gno" = "tabopen https://search.nixos.org/options";
              "goo" = "open https://search.nixos.org/options";
              "gwo" = "winopen https://search.nixos.org/options";
              "gpo" = "winopen -private https://search.nixos.org/options";
              "gnh" = "tabopen https://home-manager-options.extranix.com";
              "goh" = "open https://home-manager-options.extranix.com";
              "gwh" = "winopen https://home-manager-options.extranix.com";
              "gph" = "winopen -private https://home-manager-options.extranix.com";
              ";s" = "composite fillcmdline open nixpkgs";
              "ZZ" = "!s killall firefox";
              ",r" = "reloadtheme";
            };
            editorcmd = "emacsclient -c";
            searchengine = "google";
            searchurls = {
              nixpkgs = "https://search.nixos.org/packages?query=%s";
              hmopts = "https://home-manager-options.extranix.com/?query=%s";
              gh = "https://github.com/search?q=%s";
            };
            #bindurls
            subconfigs = {
              "news.ycombinator.com".nmaps = {
                "f" = "hint -c span.titleline";
              };
              "youtube.com".nmaps = {
                "f" =
                  "hint -Jc a#video-title, ytd-channel-name#channel-name, h3.ytLockupMetadataViewModelHeadingReset, a.yt-simple-endpoint, div.ytTabShapeTab, button.ytp-button";
              };
              "search.brave.com".nmaps = {
                "f" = "hint -Jc div.title, a.enrichment-card-item, button, textarea, input";
              };
            };
            autocmds = {
              DocStart = {
                "docs.google.com" = "mode ignore";
                "mail.google.com/mail" = "mode ignore";
              };
              TabEnter = {
                ".*" = "reloadtheme";
              };
            };
            allowautofocus = "false";
            smoothscroll = "true";
            tabsclosetoend = "false";
            exaliases = {
              reloadtheme = "composite colourscheme dark ; colourscheme matugen";
            };
          };
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
