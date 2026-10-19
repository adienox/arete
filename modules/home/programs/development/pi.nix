{
  pkgs,
  config,
  helpers,
  vars,
  ...
}:
{
  programs.pi-coding-agent = {
    enable = true;
    extraPackages = with pkgs; [
      nodejs
      bun
    ];
  };

  sops.templates."pi-auth.json".content = builtins.toJSON {
    openrouter = {
      type = "api_key";
      key = config.sops.placeholder."services/pi";
    };
  };

  home.file = helpers.mkSymlinkedFiles [
    {
      target = "${config.xdg.configHome}/pi/agent/auth.json";
      source = config.sops.templates."pi-auth.json".path;
    }
    {
      target = "${config.xdg.configHome}/pi/agent/settings.json";
      source = "${vars.paths.homeFiles}/pi/settings.json";
    }
  ];
}
