{
  pkgs,
  config,
  vars,
  ...
}:
{
  home.packages = with pkgs; [ devenv ];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };

  home.file = {
    ".config/direnv/direnvrc".source =
      config.lib.file.mkOutOfStoreSymlink "${vars.paths.homeFiles}/direnvrc";
  };
}
