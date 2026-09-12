{ pkgs, vars, ... }:
{
  home.packages = with pkgs; [ apple-color-emoji ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = [ vars.fonts.emoji ];
      monospace = [ vars.fonts.monospace ];
      sansSerif = [ vars.fonts.variable ];
    };
  };
}
