{ inputs, config, ... }: {
  imports = [ inputs.niri-snap.homeManagerModules.default ];
  programs.niri-snap = {
    enable = true;
    settings = {
      SCREENSHOT_DIR = config.xdg.userDirs.extraConfig.SCREENSHOTS;
      RECORDING_DIR = config.xdg.userDirs.extraConfig.RECORDINGS;
      NIRI_SNAP_DELAY = 3;
      NIRI_SNAP_POINTER = true;
      NIRI_SNAP_RECORD_FORMAT = "webm";
      NIRI_SNAP_RATIOS = [
        "16:9"
        "4:3"
        "1:1"
      ];
    };
  };
}
