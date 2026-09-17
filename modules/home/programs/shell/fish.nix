{ pkgs, ... }:
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
    };
  };
}
