{ config, lib, ... }:
{
  options.services.audio = {
    enable = lib.mkEnableOption "audio" // {
      default = true;
    };
  };

  config = lib.mkIf config.services.audio.enable {
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
