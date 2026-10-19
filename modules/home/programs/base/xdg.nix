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

    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = null;
      publicShare = null;
      templates = null;
      projects = "${config.xdg.userDirs.documents}/projects";
      extraConfig = {
        SCREENSHOTS = "${config.xdg.userDirs.pictures}/Screenshots";
        RECORDINGS = "${config.xdg.userDirs.videos}/Recordings";
        MAIL = "${config.xdg.dataHome}/Mail";
        TAILDROP = "${config.xdg.userDirs.documents}/Taildrop";
      };
      setSessionVariables = true;
    };
  };
}
