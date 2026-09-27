{ inputs, ... }: {
  imports = [ inputs.dcal.homeModules.default ];

  programs.dank-calendar = {
    enable = true;
    systemd.enable = true;
    settings = {
      remindersEnabled = true;
      use24HourClock = true;
      defaultReminderMinutes = 10;
      snoozeMinutes = 5;
    };
  };
}
