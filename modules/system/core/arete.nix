# Exposes arete-level metadata as read-only NixOS options so tooling
# (e.g. scripts/install.sh) can query it without poking at _module.args.
{ lib, role, vars, ... }:
{
  options.arete = {
    role = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = role;
      description = "Base profile role (workstation/server).";
    };

    user = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = vars.user;
      description = "Primary interactive user.";
    };

    home = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = vars.home;
      description = "Primary user's home directory.";
    };
  };
}
