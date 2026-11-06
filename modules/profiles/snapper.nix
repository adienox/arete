{ pkgs, vars, ... }:
{
  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval = "1d";
    persistentTimer = true;

    configs.home = {
      SUBVOLUME = "/home";
      FSTYPE = "btrfs";

      ALLOW_USERS = [ vars.user ];

      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;

      # Minimum age before a snapshot can be cleaned up (seconds)
      TIMELINE_MIN_AGE = "1800";

      # Snapshot retention
      TIMELINE_LIMIT_HOURLY = "24";
      TIMELINE_LIMIT_DAILY = "7";
      TIMELINE_LIMIT_WEEKLY = "4";
      TIMELINE_LIMIT_MONTHLY = "3";
      TIMELINE_LIMIT_YEARLY = "0";
    };
  };

  environment.systemPackages = with pkgs; [
    snapper
    btrfs-progs
  ];
}
