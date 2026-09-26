{
  config,
  hostname,
  vars,
  ...
}:
{
  services.syncthing = {
    enable = true;

    guiCredentials = {
      username = "nox";
      passwordFile = config.sops.secrets."syncthing/password".path;
    };

    cert = config.sops.secrets."syncthing/${hostname}/cert".path;
    key = config.sops.secrets."syncthing/${hostname}/key".path;

    settings.options = {
      localAnnounceEnabled = false;
      globalAnnounceEnabled = false;
      relaysEnabled = false;
      natEnabled = false;
      urAccepted = -1;
    };

    overrideDevices = false;
    settings.devices = {
      axiom = {
        id = "7MMDVVS-5KYYTT5-NGYSA5V-VAEFDNP-YACRMNN-SXG6T5G-G2D2NZG-JLRVMQK";
        addresses = [ "tcp://axiom:22000" ];
      };
      anomaly = {
        id = "MN5IMVI-IAALPOH-4G53AYU-5235MYG-TFVXRKN-BEWVW26-7RRQ4EL-CNYSXQK";
        addresses = [ "tcp://anomaly:22000" ];
      };
      hawk = {
        id = "6RLXUWM-3PGV75V-ULIMDDN-AQJF746-RXKPLUP-TPGDFXP-ER6USHD-ZVBH5QT";
        addresses = [ "tcp://hawk:22000" ];
      };
      impel = {
        id = "NVJO7VD-IGHTRXF-K4R4TIQ-XMADLXV-PIT6AZ7-56LT4TR-V5DAI3P-JMSMLA2";
        addresses = [ "tcp://impel:22000" ];
      };
    };

    overrideFolders = false;
    settings.folders = {
      "screenshots" = {
        devices = [
          "hawk"
          "axiom"
          "anomaly"
        ];
        id = "screenshots";
        path = "~/Pictures/Screenshots";
      };
      "notes" = {
        devices = [
          "hawk"
          "axiom"
          "anomaly"
          "impel"
        ];
        id = "notes";
        path = vars.paths.notes;
      };
      "state" = {
        devices = [
          "hawk"
        ];
        id = "state";
        path = "~/.local/share/arete-state";
        maxConflicts = 0;
      };
    };
  };
  home.file.".local/share/arete-state/.stignore".text = "(?d)*.tmp";
}
