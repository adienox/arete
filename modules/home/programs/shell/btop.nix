{ config, ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
      rounded_corners = false;
      proc_tree = true;
      color_theme = if config.programs.dank-material-shell.enable then "dankcolors" else "default";
      theme_background = false;
      disks_filter = "/"; # use with btrfs
    };
  };
}
