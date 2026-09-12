{
  pkgs,
  ...
}:
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.caskaydia-cove
      readexpro
      inter
      font-awesome
      apple-color-emoji
      symbola
      maple-mono.NF-unhinted
    ];
  };
}
