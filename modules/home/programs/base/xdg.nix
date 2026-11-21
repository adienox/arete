{
  config,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.xdg-utils ];
  home.preferXdgDirectories = true;

  xdg = {
    enable = true;
    cacheHome = config.home.homeDirectory + "/.local/cache";
    mime.enable = true;
    #configFile."mimeapps.list".force = true;

    userDirs =
      let
        userDirs = config.xdg.userDirs;
      in
      {
        enable = true;
        createDirectories = true;
        desktop = null;
        publicShare = null;
        templates = null;
        projects = "${userDirs.documents}/projects";
        extraConfig = {
          SCREENSHOTS = "${userDirs.pictures}/Screenshots";
          RECORDINGS = "${userDirs.videos}/Recordings";
          MAIL = "${config.xdg.dataHome}/Mail";
          TAILDROP = "${userDirs.documents}/Taildrop";
        };
        setSessionVariables = true;
      };

    mimeApps = {
      enable = true;
      defaultApplications =
        let
          browser = "org.qutebrowser.qutebrowser.desktop";
        in
        {
          "text/html" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/unknown" = browser;
        };
    };
  };
}
