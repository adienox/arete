{ pkgs, ... }:
{
  programs.rbw = {
    enable = true;
    settings = {
      email = "adkadwait@gmail.com";
      pinentry = pkgs.pinentry-gnome3;
    };
  };
}
