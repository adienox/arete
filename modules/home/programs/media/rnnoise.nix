{ pkgs, ... }:
let
  json = pkgs.formats.json { };

  pw_rnnoise_config = {
    "context.modules" = [
      {
        "name" = "libpipewire-module-filter-chain";
        "args" = {
          "node.description" = "Noise Canceling source";
          "media.name" = "Noise Canceling source";
          "filter.graph" = {
            "nodes" = [
              {
                "type" = "ladspa";
                "name" = "rnnoise";
                "plugin" = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                "label" = "noise_suppressor_stereo";
                "control" = {
                  "VAD Threshold (%)" = 70.0;
                };
              }
            ];
          };
          "audio.position" = [
            "FL"
            "FR"
          ];
          "capture.props" = {
            "node.name" = "effect_input.rnnoise";
            "node.passive" = true;
            "target.object" = "alsa_input.pci-0000_05_00.6.analog-stereo";
          };
          "playback.props" = {
            "node.name" = "effect_output.rnnoise";
            "media.class" = "Audio/Source";
          };
        };
      }
    ];
  };
in
{
  xdg.configFile = {
    "pipewire/pipewire.conf.d/99-input-denoising.conf" = {
      source = json.generate "99-input-denoising.conf" pw_rnnoise_config;
    };
    "wireplumber/wireplumber.conf.d/51-default-rnnoise.conf" = {
      source = json.generate "51-default-rnnoise.conf" {
        "wireplumber.settings" = {
          "default.configured.audio.source" = "effect_output.rnnoise";
        };
      };
    };
  };
}
