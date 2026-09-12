{
  services.pipewire.wireplumber.extraConfig = {
    "audio-config" = {
      "monitor.alsa.rules" = [
        {
          # HDMI
          matches = [ { "node.name" = "alsa_output.pci-0000_01_00.1.hdmi-stereo"; } ];
          actions.update-props = {
            "priority.driver" = "1024";
            "priority.session" = "1024";
          };
        }
        {
          # Internal speaker
          matches = [ { "node.name" = "alsa_output.pci-0000_05_00.6.analog-stereo"; } ];
          actions.update-props = {
            "priority.driver" = "512";
            "priority.session" = "512";
          };
        }
      ];
      "monitor.bluez.rules" = [
        {
          # Bluetooth headphone
          matches = [ { "node.name" = "bluez_output.80_99_E7_FF_4A_2B.1"; } ];
          actions.update-props = {
            "priority.driver" = "4096";
            "priority.session" = "4096";
          };
        }
        {
          # Bluetooth speaker
          matches = [ { "node.name" = "bluez_output.F4_4E_FD_A7_A6_E4.1"; } ];
          actions.update-props = {
            "priority.driver" = "2048";
            "priority.session" = "2048";
          };
        }
      ];
    };
  };
}
