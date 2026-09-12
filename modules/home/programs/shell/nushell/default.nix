{
  config,
  pkgs,
  lib,
  ...
}:
let
  nu_scripts = "${pkgs.nu_scripts}/share/nu_scripts";
in
{
  options.modules.nushell.enable = lib.mkEnableOption "Nushell Shell" // {
    default = true;
  };

  config = lib.mkIf config.modules.nushell.enable {
    programs.nushell = {
      enable = true;
      configFile.source = ./config.nu;
      extraConfig = ''
        $env.LS_COLORS = (${pkgs.vivid}/bin/vivid generate ansi | str trim)

        let carapace_completer = {|spans: list<string>|
            CARAPACE_LENIENT=1 ${pkgs.carapace}/bin/carapace $spans.0 nushell ...$spans | from json
        }

        let fish_completer = {|spans|
            ${pkgs.fish}/bin/fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
            | from tsv --flexible --noheaders --no-infer
            | rename value description
            | update value {|row|
            let value = $row.value
            let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
            if ($need_quote and ($value | path exists)) {
                let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
                $'"($expanded_path | str replace --all "\"" "\\\"")"'
            } else {$value}
            }
        }
        let zoxide_completer = {|spans|
            $spans | skip 1 | ${pkgs.zoxide}/bin/zoxide query -l ...$in | lines | where {|x| $x != $env.PWD} | str replace "/home/nox" "~"
        }

        # This completer will use carapace by default
        let external_completer = {|spans|
            let expanded_alias = scope aliases
            | where name == $spans.0
            | get -o 0.expansion

            let spans = if $expanded_alias != null {
                $spans
                | skip 1
                | prepend ($expanded_alias | split row ' ' | take 1)
            } else {
                $spans
            }

            match $spans.0 {
                nu => $fish_completer
                git => $fish_completer
                tailscale => $fish_completer
                __zoxide_z | __zoxide_zi => $zoxide_completer
                _ => $carapace_completer
            } | do $in $spans
        }

        $env.config.completions.external.completer = $external_completer

        source ${nu_scripts}/custom-completions/nix/nix-completions.nu
        source ${nu_scripts}/custom-completions/dart/dart-completions.nu

        if $nu.is-interactive and (not ("INSIDE_EMACS" in $env)) {
            ${pkgs.fastfetch}/bin/fastfetch
        }
      '';
    };
  };
}
