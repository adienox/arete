{ config, ... }: {
  programs.bat = {
    enable = true;
    config = {
      style = "plain";
      theme = if config.programs.dank-material-shell.enable then "dank" else "base16-256";
    };
  };
}
