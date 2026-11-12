{ pkgs, lib, ... }:
let
  impacted = pkgs.fetchurl {
    url = "https://emudhra.we-have-a-problem.com/impacted-intermediates.json";
    sha256 = "f67b3abe9b4879f4e91874ed041beccd71257f1db41c588c724ccf12aa90c59e";
  };

  emudhra-distrust = pkgs.writeShellApplication {
    name = "emudhra-distrust";
    runtimeInputs = [
      pkgs.jq
      pkgs.nssTools
    ];
    text = ''
      dbdir="$HOME/.pki/nssdb"
      db="sql:$dbdir"
      mkdir -p "$dbdir"
      [ -f "$dbdir/cert9.db" ] || certutil -d "$db" -N --empty-password

      for sha in $(jq -r '.[].sha256 | ascii_downcase' ${impacted}); do
        name="eMudhra $sha"
        # skip if already imported (certutil -A errors on duplicate nicknames)
        certutil -d "$db" -L -n "$name" >/dev/null 2>&1 && continue
        jq -r --arg sha "$sha" \
          '.[] | select((.sha256 | ascii_downcase) == $sha) | .pem' ${impacted} |
          certutil -d "$db" -A -a -t p,p,p -n "$name"
      done
    '';
  };
in
{
  home.packages = with pkgs; [
    qutebrowser
    ungoogled-chromium
    emudhra-distrust
  ];

  home.activation.emudhraDistrust = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${emudhra-distrust}/bin/emudhra-distrust
  '';
}
