{
  inputs,
  lib,
  osConfig,
  vars,
  pkgs,
  ...
}:
{
  imports = [ inputs.xremap.homeManagerModules.default ];

  config = lib.mkIf osConfig.modules.xremap.enable {
    services.xremap = {
      enable = true;
      withNiri = true;
      watch = true;
      config.modmap = [
        {
          name = "Global";
          remap = {
            "CapsLock" = {
              "held" = "leftctrl";
              "alone" = "esc";
              "alone_timeout_millis" = 350;
            };
            "CONTROL_L" = {
              "held" = "leftctrl";
              "alone" = "esc";
              "alone_timeout_millis" = 350;
            };
          };
        }
      ];

      config.keymap = [
        {
          name = "Up/Down";
          mode = "default";
          application.not = [ "emacs" ];
          remap = {
            "C-j" = "down";
            "C-k" = "up";
          };
        }
        {
          name = "Layer pause switch";
          mode = [
            "default"
            "layer"
          ];
          remap = {
            "F23" = {
              set_mode = "layer";
            };

            "F24" = {
              set_mode = "default";
            };
          };
        }
      ];
    };
    systemd.user.services = {
      xremap-layer-pause = {
        Unit = {
          Description = "Pause Xremap for layer shells";
          After = [
            "graphical-session.target"
          ];
          PartOf = [ "graphical-session.target" ];
        };
        Service =
          let
            ydotool = "${pkgs.ydotool}/bin/ydotool";
            xremap-layer-pause = "${vars.paths.scripts}/xremap-layer-pause";
          in
          {
            ExecStart = " ${xremap-layer-pause} -n niri-snap --stop-cmd '${ydotool} key 193:1 193:0' --start-cmd '${ydotool} key 194:1 194:0'";
            Restart = "on-failure";
          };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
