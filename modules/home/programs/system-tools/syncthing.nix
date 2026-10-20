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
      username = vars.user;
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
    settings.devices = vars.syncthing.devices;

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
