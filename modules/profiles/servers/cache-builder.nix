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

    postScript = lib.mkOption {
      type = lib.types.lines;
      default = "";
      example = ''
        echo "built $TARGET_HOST: $TOPLEVEL (lock changed: $LOCK_CHANGED)"
      '';
      description = ''
        Shell snippet run at the very end of the service, only after the build
        succeeded and flake.lock was pushed (if it changed). Runs in the same
        shell as the build, as the cache-builder user, in the repo checkout.

        Available variables:
          TARGET_HOST   name of the host that was built
          TOPLEVEL      resolved store path of the built system closure
          OLD_TOPLEVEL  closure from the previous run (empty on the first run)
          LOCK_CHANGED  1 if flake.lock was updated and pushed, else 0
          REPO          path to the repo checkout

        A non-zero exit marks the unit as failed, but the build, the push and
        the cache contents are unaffected. Append `|| true` to a command to
        make it non-fatal.
      '';
    };

    postScriptPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.curl pkgs.jq ]";
      description = "Extra packages available on PATH inside postScript.";
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
      path =
        (with pkgs; [
          nix
          git
          openssh
          coreutils
        ])
        ++ cfg.postScriptPackages;

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

        # Remember the previous closure (for diffs in postScript) and keep it
        # rooted, because the main out-link is overwritten by the build below.
        old_toplevel=""
        if [ -e ${stateDir}/${cfg.targetHost}-gcroot ]; then
          old_toplevel="$(readlink -f ${stateDir}/${cfg.targetHost}-gcroot)"
          nix-store --realise "$old_toplevel" \
            --add-root ${stateDir}/${cfg.targetHost}-prev-gcroot --indirect \
            >/dev/null || old_toplevel=""
        fi

        # Build first. Out-link doubles as a GC root for the newest closure,
        # and it is overwritten each run, so older closures can be collected.
        nix build \
          ".#nixosConfigurations.${cfg.targetHost}.config.system.build.toplevel" \
          --out-link ${stateDir}/${cfg.targetHost}-gcroot \
          --print-build-logs

        lock_changed=0

        # Only reached if the build succeeded (set -e).
        if ! git diff --quiet -- flake.lock; then
          git add flake.lock
          git -c user.name="cache-builder" -c user.email="cache-builder@localhost" \
            commit -m "flake.lock: automated update (built for ${cfg.targetHost})"
          # Fails (and the unit fails) if someone pushed in the meantime.
          # That is intentional: the closure we built no longer matches HEAD.
          git push origin HEAD:${lib.escapeShellArg cfg.branch}
          lock_changed=1
        fi

        ${lib.optionalString (cfg.postScript != "") ''
          # ---- user-supplied postScript (build + push already succeeded) ----
          export TARGET_HOST=${lib.escapeShellArg cfg.targetHost}
          export TOPLEVEL="$(readlink -f ${stateDir}/${cfg.targetHost}-gcroot)"
          export OLD_TOPLEVEL="$old_toplevel"
          export LOCK_CHANGED="$lock_changed"
          export REPO="$repo"

          ${cfg.postScript}
        ''}
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
