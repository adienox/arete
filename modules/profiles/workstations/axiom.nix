# Per-machine workstation profile for `axiom` (Framework AMD AI 300).
#
# Only loaded when axiom runs the workstation role. Machine hardware support
# lives here so hosts/ holds only disko.nix + hardware.nix.
{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];
}
