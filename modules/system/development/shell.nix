{ ... }:
{
  programs.starship = {
    enable = true;
    transientPrompt.enable = true;
  };

  programs.zoxide.enable = true;

  programs.tack = {
    enable = true;
    nixConfTokens = true;
  };
}
