{ pkgs, config, ... }: {
  programs.pi-coding-agent = {
    enable = true;
    configDir = "${config.xdg.configHome}/pi/agent";
    extraPackages = [
      pkgs.nodejs
      pkgs.bun
    ];
  };
}
