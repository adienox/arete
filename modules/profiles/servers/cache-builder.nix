{
  config,
  lib,
  pkgs,
  ...
}:

#   services.cacheBuilder = {
#     enable = true;
#     repoUrl = "git@github.com:<you>/arete.git";
#     sshKeyFile = config.sops.secrets."cache-builder-deploy-key".path;
#   };
#
# Flow: pull repo -> nix flake update -> build axiom's toplevel ->
#       (only if the build succeeded) commit + push flake.lock.
# Harmonia serves anomaly's /nix/store, signing paths on the fly.

let
  cfg = config.services.cacheBuilder;
  stateDir = "/var/lib/cache-builder";
in
{
  options.services.cacheBuilder = {
    enable = lib.mkEnableOption "nightly build of another host's closure plus a Harmonia binary cache";

    repoUrl = lib.mkOption {
      type = lib.types.str;
      description = "Git URL of the flake repo (arete).";
    };

    branch = lib.mkOption {
      type = lib.types.str;
      default = "main";
    };

    targetHost = lib.mkOption {
      type = lib.types.str;
      default = "axiom";
      description = "nixosConfigurations.<name> to build.";
    };

    updateInputs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run `nix flake update` before building.";
    };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "04:00";
      description = "systemd OnCalendar expression.";
    };

    sshKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "Private deploy key (with write access) used to clone and push the repo.";
    };

    signKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "Harmonia signing key (private), e.g. a sops-nix secret path.";
    };

    interface = lib.mkOption {
      type = lib.types.str;
      default = "tailscale0";
      description = "Interface on which the cache port is opened.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5000;
    };
  };

  config = lib.mkIf cfg.enable {
    # ---- Cache server -------------------------------------------------
    services.harmonia.cache = {
      enable = true;
      signKeyPaths = [ cfg.signKeyFile ];
      settings.bind = "[::]:${toString cfg.port}";
    };

    networking.firewall.interfaces.${cfg.interface}.allowedTCPPorts = [ cfg.port ];

    # ---- Builder user -------------------------------------------------
    users.users.cache-builder = {
      isSystemUser = true;
      group = "cache-builder";
      home = stateDir;
    };
    users.groups.cache-builder = { };

    # ---- Build service ------------------------------------------------
    systemd.services.cache-builder = {
      description = "Build ${cfg.targetHost}'s system closure and publish flake.lock";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = with pkgs; [
        nix
        git
        openssh
        coreutils
      ];

      environment = {
        HOME = stateDir;
        GIT_SSH_COMMAND = "ssh -i ${cfg.sshKeyFile} -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=${stateDir}/known_hosts";
      };

      serviceConfig = {
        Type = "oneshot";
        User = "cache-builder";
        Group = "cache-builder";
        StateDirectory = "cache-builder";
        WorkingDirectory = stateDir;
        Nice = 10;
        IOSchedulingClass = "idle";
        TimeoutStartSec = "3h";
      };

      script = ''
        set -euo pipefail

        repo=${stateDir}/repo

        if [ ! -d "$repo/.git" ]; then
          git clone ${lib.escapeShellArg cfg.repoUrl} "$repo"
        fi
        cd "$repo"

        # This checkout is disposable: always match the remote exactly.
        git fetch origin ${lib.escapeShellArg cfg.branch}
        git checkout -B ${lib.escapeShellArg cfg.branch} origin/${lib.escapeShellArg cfg.branch}
        git reset --hard origin/${lib.escapeShellArg cfg.branch}

        ${lib.optionalString cfg.updateInputs "nix flake update"}

        # Build first. Out-link doubles as a GC root for the newest closure,
        # and it is overwritten each run, so older closures can be collected.
        nix build \
          ".#nixosConfigurations.${cfg.targetHost}.config.system.build.toplevel" \
          --out-link ${stateDir}/${cfg.targetHost}-gcroot \
          --print-build-logs

        # Only reached if the build succeeded (set -e).
        if ! git diff --quiet -- flake.lock; then
          git add flake.lock
          git -c user.name="cache-builder" -c user.email="cache-builder@localhost" \
            commit -m "flake.lock: automated update (built for ${cfg.targetHost})"
          # Fails (and the unit fails) if someone pushed in the meantime.
          # That is intentional: the closure we built no longer matches HEAD.
          git push origin HEAD:${lib.escapeShellArg cfg.branch}
        fi
      '';
    };

    systemd.timers.cache-builder = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };
  };
}
