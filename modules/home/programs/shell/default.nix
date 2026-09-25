{ pkgs, ... }:
{
  imports = [
    ./ghostty.nix
    ./starship.nix
    ./zoxide.nix
    ./atuin.nix
    ./bat.nix
    ./lsd.nix
    ./fish.nix
    ./btop.nix
    ./ssh.nix
  ];

  home.shell.enableFishIntegration = true;

  home.shellAliases = {
    v = "${pkgs.neovim}/bin/nvim";
    e = "emacsclient";
    et = "emacsclient -c -nw";

    rm = "${pkgs.trash-cli}/bin/trash";

    gc = "git commit -m";
    ga = "git add";
    gp = "git push";
    gs = "git status";

    cls = "clear";
    sudo = "sudo ";
    yt-audio = "${pkgs.yt-dlp}/bin/yt-dlp -x --audio-format mp3 --audio-quality 0";
    cat = "${pkgs.bat}/bin/bat";
    wget = "wget -c ";
    grep = "grep --color=auto";
    hw = "${pkgs.hwinfo}/bin/hwinfo --short";
    ipa = "ip --brief address";

    ns = "nix-shell -p";
    nsh = "${pkgs.nh}/bin/nh search";

    jq = "${pkgs.gojq}/bin/gojq";

    man = "${pkgs.bat-extras.batman}/bin/batman";
  };
}
