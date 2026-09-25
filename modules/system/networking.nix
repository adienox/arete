{ hostname, ... }:
{
  services.resolved.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enables .local name resolution for IPv4
    publish = {
      enable = true;
      addresses = true; # Broadcast IP addresses
      workstation = true; # Register as a workstation
      domain = true; # Announce local domain
      userServices = true; # Allow user-defined services
    };
  };

  networking = {
    hostName = hostname;
    networkmanager = {
      enable = true;
      wifi = {
        powersave = true;
        macAddress = "stable-ssid";
      };
    };

    nameservers = [
      # "94.140.14.14"
      # "94.140.15.15"
      "1.1.1.1"
    ];
    networkmanager.insertNameservers = [
      # "94.140.14.14"
      # "94.140.15.15"
      "1.1.1.1"
    ];

    interfaces = {
      eno1 = {
        wakeOnLan.enable = true;
      };
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22000 # syncthing
        2222 # sftp
        # Custom Ports
        1337
        2020
        3030
        4040
        5050
        6060
        7070
        8080
        9090
      ];
      allowedUDPPorts = [
        9 # Wake-on-LAN
        2222
        5353
        # Custom Ports
        1337
        2020
        3030
        4040
        5050
        6060
        7070
        8080
        9090
      ];
      # Needed for KDE connect
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      # Needed for KDE connect
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
  };
}
