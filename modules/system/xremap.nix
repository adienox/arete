{
  hardware.uinput.enable = true;
  users.groups.uinput.members = [ "nox" ];
  users.groups.input.members = [ "nox" ];
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", TAG+="uaccess"
  '';
}
