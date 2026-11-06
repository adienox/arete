{
  pkgs,
  config,
  helpers,
  ...
}:
{
  programs.rbw.enable = true;
  sops.secrets."ids/bitwarden" = { };

  sops.templates."rbw-config.json".content = builtins.toJSON {
    email = config.sops.placeholder."ids/bitwarden";
    pinentry = "${pkgs.pinentry-gnome3}/bin/pinentry";
    lock_timeout = 3600;
  };

  home.file = helpers.mkSymlinkedFile {
    target = ".config/rbw/config.json";
    source = config.sops.templates."rbw-config.json".path;
  };
}
