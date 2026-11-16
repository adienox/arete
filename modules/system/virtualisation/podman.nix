{
  pkgs,
  vars,
  inputs,
  ...
}:
{
  imports = [
    inputs.quadlet-nix.nixosModules.quadlet
  ];

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    quadlet.enable = true;

    oci-containers.backend = "podman";

    containers = {
      registries.settings = {
        unqualified-search-registries = [
          "docker.io"
        ];
      };
      containersConf.settings.engine.compose_warning_logs = false;
    };
  };

  users.users.${vars.user} = {
    isNormalUser = true;
    linger = true;
    autoSubUidGidRange = true;
  };

  environment.systemPackages = with pkgs; [ podman-compose ];
}
