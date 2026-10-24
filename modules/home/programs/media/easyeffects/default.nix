{ pkgs, ... }:
{
  services.easyeffects = {
    enable = true;
    preset = "fw13pro";
    extraPackages = with pkgs; [
      lsp-plugins
      calf
    ];
  };

  xdg.dataFile."easyeffects/output/fw13pro.json".source = ./fw13pro.json;
}
