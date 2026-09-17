{
  services.syncthing = {
    enable = true;
    overrideDevices = false;
    overrideFolders = false;
    settings.options.localAnnounceEnabled = false;
    settings.options.urAccepted = -1;
  };
}
