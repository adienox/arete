{ pkgs, ... }:
let
  internalOutput = {
    node = "alsa_output.pci-0000_c1_00.6.analog-stereo";
    description = "Ryzen HD Audio Controller Analog Stereo";
    route = "Speakers";
  };
  internalInput = {
    node = "alsa_input.pci-0000_c1_00.6.analog-stereo";
    description = "Ryzen HD Audio Controller Analog Stereo";
    route = "Internal Microphone";
  };

  autoload = pipeline: device: preset: {
    "easyeffects/autoload/${pipeline}/${device.node}:${device.route}.json".text = builtins.toJSON {
      device = device.node;
      device-description = device.description;
      device-profile = device.route;
      preset-name = preset;
    };
  };
in
{
  services.easyeffects = {
    enable = true;

    settings.Window = {
      outputAutoloadingUsesFallback = true;
      outputAutoloadingFallbackPreset = "flat";
      inputAutoloadingUsesFallback = true;
      inputAutoloadingFallbackPreset = "flat";
    };
  };

  xdg.dataFile = {
    "easyeffects/output/fw13pro.json".source = ./fw13pro.json;
    "easyeffects/input/mic.json".source = ./mic.json;
    "easyeffects/output/flat.json".source = ./flat-output.json;
    "easyeffects/input/flat.json".source = ./flat-input.json;
  }
  // autoload "output" internalOutput "fw13pro"
  // autoload "input" internalInput "mic";

  systemd.user.services.mic-volume = {
    Unit = {
      Description = "Set mic volume";
      After = [ "wireplumber.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 20%";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
