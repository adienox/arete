{ lib, ... }:
{
  imports = [
    ./base
    ./browsers
    ./development
    ./shell
    ./desktop
    ./media
    ./security
    ./system-tools
    ./theming
  ];

  services.mpris-proxy.enable = true;
  services.playerctld.enable = true;
}
