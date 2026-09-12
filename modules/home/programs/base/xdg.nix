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
        MAIL = "${config.xdg.dataHome}/Mail";
      };
      setSessionVariables = true;
    };
  };
}
