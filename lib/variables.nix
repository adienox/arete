rec {
  # Primary interactive user. Used across system + home modules so the
  # configuration is not hard-wired to a single account.
  user = "nox";
  home = "/home/${user}";

  # NixOS + home-manager state version. Bump intentionally on major upgrades.
  stateVersion = "26.11";

  paths = {
    dotFiles = "${home}/Documents/projects/arete";
    homeFiles = "${paths.dotFiles}/modules/home/files";
    scripts = "${paths.homeFiles}/scripts";
    notes = "${home}/Documents/notes";
    wallpapers = "${home}/Pictures/wallpapers";
  };

  fonts = {
    monospace = "Maple Mono NF";
    variable = "Readex Pro";
    emoji = "Apple Color Emoji";
  };

  # Syncthing mesh. Referenced by modules/home/programs/system-tools/syncthing.nix.
  syncthing.devices = {
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
}
