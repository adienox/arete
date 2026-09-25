# overlays/tab-handoff/default.nix
{
  lib,
  stdenv,
  makeWrapper,
  python3,
  ...
}:
let
  # from manifest.json -> browser_specific_settings.gecko.id
  addonId = "tab-handoff@nox";

  # from background.js -> const HOST (the connectNative() argument)
  hostName = "nox.handoff_host";
in
{
  # programs.firefox.extensions = [ pkgs.tab-handoff.xpi ];
  xpi = stdenv.mkDerivation {
    pname = "tab-handoff";
    version = "1.0"; # keep in sync with manifest.json

    src = ./extension.xpi;

    dontUnpack = true; # src is already final, same trick as the emoji font
    preferLocalBuild = true;
    allowSubstitutes = false;

    installPhase = ''
      dst=$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}
      mkdir -p $dst
      cp $src $dst/${addonId}.xpi
    '';

    # home-manager's extensions option asserts on this
    passthru = { inherit addonId; };

    meta = {
      description = "Tab Handoff: syncs active tab URL for phone handoff";
      platforms = lib.platforms.all;
    };
  };

  # programs.firefox.nativeMessagingHosts = [ pkgs.tab-handoff.host ];
  host = stdenv.mkDerivation {
    pname = "tab-handoff-native-host";
    version = "1.0";

    src = ./.; # expects handoff_host.py in this directory

    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin $out/lib/mozilla/native-messaging-hosts

      install -m755 handoff_host.py $out/bin/${hostName}
      # shebang must be #!/usr/bin/env python3 (yours is)
      wrapProgram $out/bin/${hostName} \
        --prefix PATH : ${python3}/bin

      # Firefox requires an absolute path here — bake the store path in at build time
      cat > $out/lib/mozilla/native-messaging-hosts/${hostName}.json <<EOF
      {
        "name": "${hostName}",
        "description": "Tab Handoff native host — writes active tab URL to file",
        "path": "$out/bin/${hostName}",
        "type": "stdio",
        "allowed_extensions": ["${addonId}"]
      }
      EOF
    '';

    meta = {
      description = "Native messaging host for tab-handoff";
      platforms = lib.platforms.all;
    };
  };
}
