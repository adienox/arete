{
  pkgs,
  config,
  helpers,
  ...
}:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      not set -q INSIDE_EMACS; and ${pkgs.fastfetch}/bin/fastfetch
    '';
    shellInit = ''
      set -g fish_greeting
      set -g async_prompt_functions fish_prompt fish_right_prompt
    '';
    plugins = [
      {
        name = "autopair";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "autopair.fish";
          rev = "4d1752ff5b39819ab58d7337c69220342e9de0e2";
          hash = "sha256-qt3t1iKRRNuiLWiVoiAYOu+9E7jsyECyIqZJ/oRIT1A=";
        };
      }
      {
        name = "bang-bang";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-bang-bang";
          rev = "ec991b80ba7d4dda7a962167b036efc5c2d79419";
          hash = "sha256-oPPCtFN2DPuM//c48SXb4TrFRjJtccg0YPXcAo0Lxq0=";
        };
      }
      # {
      #   name = "fish-async-prompt";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "acomagu";
      #     repo = "fish-async-prompt";
      #     rev = "b90e8a8c6d1634d8f04f1532b164b99530445159";
      #     hash = "sha256-HWW9191RP//48HkAHOZ7kAAAPSBKZ+BW2FfCZB36Y+g=";
      #   };
      # }
    ];
    functions = {
      mkcd = {
        description = "Create directory and change to it";
        body = ''
          mkdir -pv $argv
          cd $argv
        '';
      };
      yt-dlp = {
        description = "yt-dlp with desktop notification on completion";
        wraps = "yt-dlp";
        body = ''
          if ${pkgs.yt-dlp}/bin/yt-dlp $argv
            ${pkgs.libnotify}/bin/notify-send -a "yt-dlp" "Success" "yt-dlp has finished." --icon=youtube
          else
            ${pkgs.libnotify}/bin/notify-send -a "yt-dlp" "Error" "yt-dlp has failed." --icon=error
          end
        '';
      };
      taildrop = {
        description = "Send files to another machine via Tailscale";
        body = ''
          set -l file $argv[1]
          set -l target $argv[2]
          if not set -q target[1]
            set target hawk
          end
          string match -q -- "*:" "$target"; or set targetp "$target:"
          if ${pkgs.tailscale}/bin/tailscale file cp "$file" "$targetp"
            ${pkgs.libnotify}/bin/notify-send -a "Taildrop" "Success" "Sent $file to $target" --icon=network-transmit
          else
            ${pkgs.libnotify}/bin/notify-send -a "Taildrop" "Error" "Failed to send $file to $target" --icon=error
          end
        '';
      };
      get-url = {
        description = "Print the URL tagged on the screenshot's Comment field";
        body = ''
          ${pkgs.exiftool}/bin/exiftool -s3 -Comment $argv
        '';
      };
    }
    // (
      let
        dir = "${config.xdg.stateHome}/dtach";
        dtach = "${pkgs.dtach}/bin/dtach";
      in
      {
        ds = {
          description = "Attach to or create a named dtach session";
          body = ''
            mkdir -p -m 700 ${dir}
            set -l sock ${dir}/$argv[1]
            if test (count $argv) -ge 2
              ${dtach} -A $sock -r winch $argv[2..-1]
            else if test -S $sock
              ${dtach} -a $sock -r winch
            else
              echo "no session '$argv[1]' (usage: ds NAME COMMAND...)" >&2
              return 1
            end
          '';
        };
        dsl = {
          description = "List dtach sessions";
          body = "ls ${dir}";
        };
      }
    );

    completions = {
      ds = "complete -c ds -n '__fish_is_first_arg' -a '(ls ${config.xdg.stateHome}/dtach 2>/dev/null)'";
    };
  };

  home.file = helpers.mkConfigFiles [
    {
      source = ./compress.fish;
      target = ".config/fish/functions/compress.fish";
    }
    {
      source = ./decompress.fish;
      target = ".config/fish/functions/decompress.fish";
    }
    {
      source = ./__archive_run.fish;
      target = ".config/fish/functions/__archive_run.fish";
    }
  ];
}
