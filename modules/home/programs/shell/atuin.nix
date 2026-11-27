{ ... }:
{
  programs.atuin = {
    enable = true;
    daemon.enable = true;
    settings = {
      update_check = false;
      keymap_mode = "vim-normal";
      enter_accept = true;
      style = "compact";
      show_help = false;
      show_tabs = false;
      inline_height = 20;
      filter_mode_shell_up_key_binding = "directory";
      show_numeric_shortcuts = false;
      ai.enabled = true;
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
