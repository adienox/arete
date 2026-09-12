{ vars, config, ... }:
{
  programs.ghostty = {
    enable = true;
    systemd.enable = true;
    settings = {
      font-size = 14;
      font-family = [
        vars.fonts.monospace
        vars.fonts.emoji
      ];
      theme = if config.programs.dank-material-shell.enable then "dankcolors" else "dark modern";
      cursor-style = "bar";
      cursor-style-blink = true;
      quit-after-last-window-closed = false;
      gtk-single-instance = true;
      app-notifications = "no-clipboard-copy";
      shell-integration-features = [
        "sudo"
        "ssh-env"
        "ssh-terminfo"
        "cursor"
        "title"
      ];

      window-padding-balance = true;
      copy-on-select = "clipboard";
      clipboard-trim-trailing-spaces = true;
      mouse-hide-while-typing = true;
    };
  };
}
