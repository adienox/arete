{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [ inputs.xremap.homeManagerModules.default ];

  options.modules.xremap.enable = lib.mkEnableOption "Xremap" // {
    default = true;
  };

  config = lib.mkIf config.modules.xremap.enable {
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
          application.not = [ "emacs" ];
          remap = {
            "C-j" = "down";
            "C-k" = "up";
          };
        }
      ];
    };
  };
}
