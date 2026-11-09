{ config, lib, ... }: {
  nix.settings = {
    # NixOS merges these with the default cache.nixos.org entries
    substituters = [
      "https://nix-community.cachix.org"
      "https://vicinae.cachix.org"
    ]
    ++ lib.optional (config.networking.hostName != "anomaly") "http://anomaly:5000?priority=30";

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "anomaly:3APbvj5ysHlEel0I1g+3BJvXwA+QS5nmFEj8ixoR9fA="
    ];

    connect-timeout = 2; # seconds; default is effectively very long
    fallback = true; # build locally if a substituter fails instead of erroring
  };
}
