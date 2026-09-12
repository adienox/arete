{
  config,
  pkgs,
  vars,
  ...
}:
{
  programs.mpv = {
    enable = true;
    defaultProfiles = [ "gpu-hq" ];

    bindings = {
      l = "seek 5";
      h = "seek -5";
      k = "add volume 5";
      j = "add volume -5";
      s = "screenshot";
      WHEEL_UP = "add volume 5";
      WHEEL_DOWN = "add volume -5";
    };

    config = {
      # Screenshots
      screenshot-template = "${config.xdg.userDirs.extraConfig.SCREENSHOTS}/%F (%P)";

      # Playback / resume
      save-position-on-quit = true;
      write-filename-in-watch-later-config = true;
      ignore-path-in-watch-later-config = true;
      keep-open = true;
      watch-later-options-remove = "sub-pos";

      # Cache
      cache = "yes";
      demuxer-max-bytes = "800M";
      demuxer-max-back-bytes = "200M";

      # Hardware decoding
      hwdec = "auto-safe";

      # IPC socket for external control
      input-ipc-server = "/tmp/mpv-socket";

      # Subtitles
      sub-auto = "fuzzy";
      blend-subtitles = "video";

      # UI / cursor
      volume = 100;
      msg-color = true;
      cursor-autohide-fs-only = true;
      cursor-autohide = 1000;
      border = "no";

      # modernz replaces mpv's built-in OSC, so these stay off
      osc = "no";
      osd-bar = "no";
      osd-font = vars.fonts.variable;

      include = "${config.xdg.configHome}/mpv/mpv-colors.conf";
    };

    scripts = with pkgs.mpvScripts; [
      mpris
      sponsorblock
      thumbfast
      modernz
      autosub
    ];

    scriptOpts = {
      sponsorblock = {
        skip_categories = "sponsor,intro,outro,interaction,selfpromo,filler";
      };
      modernz = {
        icon_theme = "material";
        keeponpause = "bottombar";
        window_top_bar = "no";
        hide_empty_playlist_button = "no";
      };
    };
  };
}
