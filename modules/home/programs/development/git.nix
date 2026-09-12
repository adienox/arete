{ pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user.name = "Adienox";
        user.email = "github@adienox.anonaddy.com";
        init.defaultBranch = "main";
        pull.rebase = false;
        trailer."changeid".key = "Change-Id";
        color.ui = "auto";
      };
      ignores = [
        ".env"
        "*~"
        "*.swp"
      ];
      hooks = {
        post-commit = pkgs.writeShellScript "post-commit" ''
          emacsclient --eval '(+config/diff-hl-update-all-buffers)' >/dev/null 2>&1 &
        '';
      };
    };

    gh = {
      enable = true;
      settings.git_protocol = "ssh";
      gitCredentialHelper.enable = true;
    };

    difftastic = {
      enable = true;
      git.enable = true;
    };
  };

}
