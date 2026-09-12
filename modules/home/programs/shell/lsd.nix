{ ... }:
{
  programs.lsd = {
    enable = true;
    settings = {
      date = "+%d %b %Y";
      ignore-globs = [
        ".android"
        ".dart-tool"
        ".mozilla"
        ".dartServer"
        ".npm"
        ".nv"
        ".platformio"
        ".pub-cache"
        ".nix-profile"
        ".nix-defexpr"
        ".pki"
        ".devenv"
        ".direnv"
        ".ssh"
        ".local"
        ".cache"
        ".face"
        ".manpath"
        ".XCompose"
        ".git"
        "__pycache__"
      ];
      display = "almost-all";
      size = "short";
      sorting.dir-grouping = "first";
      blocks = [
        "permission"
        "user"
        "size"
        "date"
        "name"
      ];
    };
  };

  xdg.configFile."lsd/icons.yaml".text = ''
    filetype:
      dir: 
    name:
      .envrc: 󰒓
    extension:
      nix: 
      gpg: 󰦝
      md : 󰍔
  '';
}
