{ inputs, config, ... }: {
  imports = [ inputs.niri-snap.homeManagerModules.default ];
  programs.niri-snap = {
    enable = true;
    settings = {
      screenshot_path = "${config.xdg.userDirs.extraConfig.SCREENSHOTS}/%Y-%m-%d %H-%M-%S.png";
      recording_path = "${config.xdg.userDirs.extraConfig.RECORDINGS}/%Y-%m-%d %H-%M-%S";
      controls = false;
      delay = 3;
      pointer = true;
      record_format = "webm";
      ratios = [
        "16:9"
        "4:3"
        "1:1"
      ];
    };
  };
}
