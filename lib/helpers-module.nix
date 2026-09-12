# Injects `helpers` as a module argument for all modules in the same
# module list (NixOS or Home Manager), avoiding the need to manually
# `import ./helpers.nix { inherit lib config; }` in every module.
{ lib, config, ... }:
{
  _module.args.helpers = import ./helpers.nix { inherit lib config; };
}
