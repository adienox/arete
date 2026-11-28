{
  config,
  lib,
  pkgs,
  hostname,
  ...
}:

# Usage:
#
#   services.cacheBuilder = {
#     enable = true;
#     repoUrl = "git@github.com:<you>/arete.git";
#     sshKeyFile = config.sops.secrets."cache-builder-deploy-key".path;
#     signKeyFile = config.sops.secrets."cache-builder-sign-key".path;
#   };
#
# Flow:
#   pull repo -> update inputs (tack or nix flake) -> build target's toplevel
#   -> diff against the previous closure (dix) into a dated report
#   -> repoint the GC root -> prune old reports
#   -> (only if the build succeeded) commit + push the lock file
#   -> run postScript.
#
# Reports live in /var/lib/cache-builder/reports/:
#   <targetHost>-YYYY-MM-DD.diff   one per run
#   latest.diff                    symlink to the newest report
#
# Harmonia serves this machine's /nix/store, signing paths on the fly.

let
  cfg = config.services.cacheBuilder;

  # ---- Paths ----------------------------------------------------------
  stateDir = "/var/lib/cache-builder";
  repoDir = "${stateDir}/repo";
  gcroot = "${stateDir}/${cfg.targetHost}-gcroot";
  reportDir = "${stateDir}/reports";

  # ---- Values that depend on options ----------------------------------
  branch = lib.escapeShellArg cfg.branch;
  repoUrl = lib.escapeShellArg cfg.repoUrl;
  targetHost = lib.escapeShellArg cfg.targetHost;
  flakeAttr = ".#nixosConfigurations.${cfg.targetHost}.config.system.build.toplevel";

  # Which tool updates the inputs, and which file/dir records the result.
  updateCmd = if cfg.useTack then "tack update" else "nix flake update";
  lockName = if cfg.useTack then ".tack" else "flake.lock";
  lockFile = lib.escapeShellArg lockName;

  # ---- Script sections ------------------------------------------------
  # Each section is plain shell; they run in order in a single shell, so
  # variables like $repo, $old_toplevel, $diff_file and $lock_changed carry
  # across.

  syncRepo = ''
    repo=${repoDir}

    if [ ! -d "$repo/.git" ]; then
      git clone ${repoUrl} "$repo"
    fi
    cd "$repo"

    # This checkout is disposable: always match the remote exactly.
    git fetch origin ${branch}
    git checkout --force -B ${branch} origin/${branch}
    git reset --hard origin/${branch}
  '';

  updateInputs = lib.optionalString cfg.updateInputs ''
    ${updateCmd}
  '';

  # Build without an out-link so the previous closure stays rooted (by the
  # existing gcroot) while we diff against it. Only then is the gcroot
  # repointed at the new closure, which keeps just the newest one alive and
  # lets older closures be collected.
  build = ''
    old_toplevel=""
    if [ -e ${gcroot} ]; then
      old_toplevel="$(readlink -f ${gcroot})"
    fi

    # --no-link: the old closure must stay rooted until the diff is done.
    new_toplevel="$(nix build ${lib.escapeShellArg flakeAttr} \
      --no-link --print-out-paths --print-build-logs)"
  '';

  # One dated report per run, e.g. axiom-2026-11-28.diff
  report = ''
    mkdir -p ${reportDir}
    diff_file="${reportDir}/${cfg.targetHost}-$(date +%F).diff"

    # Non-fatal: a failed diff must not stop the lock file from being pushed.
    if [ -n "$old_toplevel" ]; then
      dix diff --color=always "$old_toplevel" "$new_toplevel" > "$diff_file" || true
    else
      : > "$diff_file"
    fi

    # Stable path to the newest report (relative link, stays valid if moved).
    ln -sfn "$(basename "$diff_file")" ${reportDir}/latest.diff
  '';

  # Repoint the GC root at the new closure; older ones become collectable.
  repointGC = ''
    nix-store --realise "$new_toplevel" --add-root ${gcroot} --indirect >/dev/null
  '';

  # Runs after the new report exists, so latest.diff never dangles.
  # -type f skips the latest.diff symlink itself.
  pruneReports = lib.optionalString (cfg.reportRetentionDays > 0) ''
    find ${reportDir} -maxdepth 1 -type f -name '*.diff' \
      -mtime +${toString cfg.reportRetentionDays} -delete || true
  '';

  # Only reached if the build succeeded (set -e).
  publishLock = ''
    lock_changed=0

    # `status --porcelain` (unlike `diff --quiet`) also notices untracked files.
    if [ -n "$(git status --porcelain -- ${lockFile})" ]; then
      git add ${lockFile}
      git -c user.name="cache-builder" -c user.email="cache-builder@${hostname}" \
        commit -m "${lockName}: automated update (built for ${cfg.targetHost})"

      # Fails (and the unit fails) if someone pushed in the meantime.
      # That is intentional: the closure we built no longer matches HEAD.
      git push origin HEAD:${branch}
      lock_changed=1
    fi
  '';

  runPostScript = lib.optionalString (cfg.postScript != "") ''
    # ---- user-supplied postScript (build + push already succeeded) ----
    export TARGET_HOST=${targetHost}
    export TOPLEVEL="$new_toplevel"
    export OLD_TOPLEVEL="$old_toplevel"
    export DIFF_FILE="$diff_file"
    export LOCK_CHANGED="$lock_changed"
    export REPO="$repo"

    ${cfg.postScript}
  '';
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
      description = "Branch to build and push the lock file to.";
    };

    targetHost = lib.mkOption {
      type = lib.types.str;
      default = "axiom";
      description = "nixosConfigurations.<name> to build.";
    };

    updateInputs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Update flake inputs before building (see `useTack`).";
    };

    useTack = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Update with `tack update` and commit `.tack`, instead of
        `nix flake update` and `flake.lock`.
      '';
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
      description = "Port the Harmonia cache listens on.";
    };

    priority = lib.mkOption {
      type = lib.types.port;
      default = 30;
      description = "Priority of the Harmonia cache.";
    };

    reportRetentionDays = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 30;
      description = ''
        Delete diff reports older than this many days after each run.
        Set to 0 to keep them forever.
      '';
    };

    postScript = lib.mkOption {
      type = lib.types.lines;
      default = "";
      example = ''
        echo "built $TARGET_HOST: $TOPLEVEL (lock changed: $LOCK_CHANGED)"
        cat "$DIFF_FILE"
      '';
      description = ''
        Shell snippet run at the very end of the service, only after the build
        succeeded and the lock file was pushed (if it changed). Runs in the
        same shell as the build, as the cache-builder user, in the repo
        checkout.

        Available variables:
          TARGET_HOST   name of the host that was built
          TOPLEVEL      store path of the built system closure
          OLD_TOPLEVEL  closure from the previous run (empty on the first run)
          DIFF_FILE     this run's dix diff between OLD_TOPLEVEL and
                        TOPLEVEL, stored as <targetHost>-<YYYY-MM-DD>.diff
                        in the reports directory (empty on the first run)
          LOCK_CHANGED  1 if the lock file was updated and pushed, else 0
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
      settings = {
        bind = "[::]:${toString cfg.port}";
        priority = cfg.priority;
      };
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
      description = "Build ${cfg.targetHost}'s system closure and publish ${lockName}";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      path =
        (with pkgs; [
          nix
          git
          openssh
          coreutils
          findutils
          dix
        ])
        ++ lib.optional cfg.useTack pkgs.tack # drop this line if tack isn't in pkgs
        ++ cfg.postScriptPackages;

      environment = {
        HOME = stateDir;
        GIT_SSH_COMMAND = lib.concatStringsSep " " [
          "ssh"
          "-i ${cfg.sshKeyFile}"
          "-o IdentitiesOnly=yes"
          "-o StrictHostKeyChecking=accept-new"
          "-o UserKnownHostsFile=${stateDir}/known_hosts"
        ];
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

      script = lib.concatStringsSep "\n" [
        "set -euo pipefail"
        syncRepo
        updateInputs
        build
        report
        repointGC
        pruneReports
        publishLock
        runPostScript
      ];
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
