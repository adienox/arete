{ config, ... }: {
  imports = [ ./cache-builder.nix ];

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
    postScript = ''
      reports=/var/lib/cache-builder/reports
      mkdir -p "$reports"
      report="$reports/$(date +%F)-$TARGET_HOST.md"

      {
        echo "# $TARGET_HOST update report ($(date -u +'%F %H:%M UTC'))"
        echo

        if [ -z "$OLD_TOPLEVEL" ]; then
          echo "First build, so there is no previous closure to compare against."
        elif [ "$OLD_TOPLEVEL" = "$TOPLEVEL" ]; then
          echo "No changes since the last build."
        else
          diff="$(nix store diff-closures "$OLD_TOPLEVEL" "$TOPLEVEL")"

          echo "## Version changes"
          echo
          # lines look like "pkg: 1.2 → 1.3, +10 KiB"; "ε → ε" lines are
          # rebuilds with no version change, so they are counted instead
          printf '%s\n' "$diff" | grep '→' | grep -v 'ε → ε' | sed 's/^/- /' \
            || echo "(none)"

          echo
          rebuilt="$(printf '%s\n' "$diff" | grep -c 'ε → ε' || true)"
          echo "Rebuilt without a version change: $rebuilt"
        fi
      } > "$report"

      echo "Report written to $report"
    '';
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
