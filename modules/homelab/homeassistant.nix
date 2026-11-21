{ pkgs, config, ... }:
{
  services.home-assistant = {
    enable = true;

    extraComponents = [
      "default_config"
      "esphome"
      "met"
      "mqtt"
      "zha"
      "tuya"
      "tailscale"
      "radio_browser"
      "google_translate"
    ];

    themes = with pkgs.home-assistant-themes; [
      material-you-theme
    ];

    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      material-you-utilities
    ];

    customComponents = with pkgs.home-assistant-custom-components; [
      browser-mod
    ];

    configWritable = true;
    config = {
      default_config = { };
      homeassistant = {
        name = "Home";
        unit_system = "metric";
        time_zone = "Asia/Kathmandu";
        internal_url = "http://home.arete.io";
        external_url = "http://home.arete.io";
      };
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
      "script ui" = "!include scripts.yaml";

      frontend.extra_module_url = [
        "/local/nixos-lovelace-modules/material-you-utilities.min.js"
      ];

      panel_custom = [
        {
          name = "material-you-panel";
          url_path = "material-you-configuration";
          sidebar_title = "Material You Utilities";
          sidebar_icon = "mdi:material-design";
          module_url = "/local/nixos-lovelace-modules/material-you-utilities.min.js";
        }
      ];
    };
  };

  systemd.tmpfiles.rules =
    let
      configDir = config.services.home-assistant.configDir;
    in
    [
      "f ${configDir}/automations.yaml 0755 hass hass"
      "f ${configDir}/scenes.yaml 0755 hass hass"
      "f ${configDir}/scripts.yaml 0755 hass hass"
      "L+ ${configDir}/www/amoled.css - - - - ${pkgs.writeText "amoled.css" ''
        @media (prefers-color-scheme: dark) {
          :host, html, body, ha-card {
            --md-sys-color-background: #000000;
            --md-sys-color-surface: #000000;
            --md-sys-color-surface-dim: #000000;
            --md-sys-color-surface-container-lowest: #000000;
            --md-sys-color-surface-container-low: #0d0d0d;
            --md-sys-color-surface-container: #121212;
            --md-sys-color-surface-container-high: #1a1a1a;
            --md-sys-color-surface-container-highest: #222222;
          }
        }
      ''}"
    ];

  services.caddy.virtualHosts."http://home.arete.io".extraConfig = ''
    reverse_proxy 127.0.0.1:8123
  '';
}
