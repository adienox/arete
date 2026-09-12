{ vars, ... }:
{
  # gdm user icon
  systemd.tmpfiles.rules =
    let
      username = "nox";
    in
    [
      "f+ /var/lib/AccountsService/users/${username}  0600 root root - [User]\\nIcon=/var/lib/AccountsService/icons/${username}\\n"
      "L+ /var/lib/AccountsService/icons/${username}  - - - - ${vars.paths.homeFiles}/profile.png"
    ];
}
