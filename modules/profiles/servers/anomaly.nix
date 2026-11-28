{
  pkgs,
  config,
  vars,
  ...
}:
let
  homelab = [
    "caddy"
    "redlib"
    "piped"
    "technitium"
    "freshrss"
    "audiobookshelf"
    "webdav"
    "qbittorrent"
    "prowlarr"
    "rmab"
    "ntfy"
    "n8n"
    "searx"
    "karakeep"
    "homeassistant"
    "radicale"
    "speedtest-tracker"
    "dynacat"
  ];
in
{
  imports = [
    ./cache-builder.nix
    (import ../../homelab { inherit homelab vars; })
  ];

  environment.systemPackages = with pkgs; [
    btop
    dix # for diffs produced by nh
  ];

  systemd.services.battery-conservation = {
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      echo 1 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
    '';
  };

  services.cacheBuilder = {
    enable = true;
    repoUrl = "git@github.com:adienox/arete.git";
    sshKeyFile = config.sops.secrets."anomaly/arete-deploy".path;
    signKeyFile = config.sops.secrets."anomaly/harmonia".path;
  };

  sops.secrets."anomaly/arete-deploy".owner = "cache-builder";
  sops.secrets."anomaly/harmonia" = { };

  security.pam.sshAgentAuth.enable = true;
  security.pam.services.sudo.sshAgentAuth = true;

  security.sudo.extraConfig = ''
    Defaults env_keep+=SSH_AUTH_SOCK
  '';

  users.users.nox.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILauKlCkhZTtkOyCmnz8YBZOeqGJhVhnRAgcwtMhAnVG nox@axiom"
  ];
}
