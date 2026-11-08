{ ... }:
{
  programs.starship = {
    enable = true;
    transientPrompt.enable = true;
  };

  programs.zoxide.enable = true;

  # System-managed (config lands in /etc/atuin/config.toml via
  # ATUIN_CONFIG_DIR), so it is available on servers without home-manager.
  programs.atuin = {
    enable = true;
    daemon.enable = true;
    settings = {
      update_check = false;
      keymap_mode = "vim-normal";
      enter_accept = true;
      sync_frequency = "5m";
      style = "compact";
      show_help = false;
      show_tabs = false;
      inline_height = 20;
      filter_mode_shell_up_key_binding = "directory";
      show_numeric_shortcuts = false;
      history_filter = [
        "^cd"
        "^z "
        "^ls"
        "^mv"
        "^cp"
        "^y$"
        "^cls"
        "^clear"
        "^rm"
        "^source"
        "^package-locate"
      ];
    };
  };
}
