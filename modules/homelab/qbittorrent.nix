{ pkgs, ... }: {
  services.qbittorrent = {
    enable = true;
    webuiPort = 8888;
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        WebUI = {
          Username = "nox";
          Password_PBKDF2 = "@ByteArray(RP2iCfHfGRJgwKdOLZEtAA==:zjtnkbwyXjKZiyX7eneKPUn2Jd8gHHocPgYp86at1BVa18XjbJpQVSOwu32oWey7rOE3ElXe56NQZ0NrYEQKSA==)";
          AlternativeUIEnabled = true;
          RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
        };
        General.Locale = "en";
      };
    };
  };

  homelab.dns.hosts.qb = 8888;
}
