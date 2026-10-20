{
  nixpkgs,
  inputs,
}:
let
  vars = import ./variables.nix;

  profilesDir = ../modules/profiles;

  # Role -> directory under modules/profiles/. Unknown roles are used
  # as-is, so custom top-level profile directories keep working.
  roleDir =
    role:
    {
      workstation = "workstations";
      server = "servers";
    }
    .${role} or role;

  # Hardware config resolution order:
  #   1. explicit `hardware = ./path` passed to mkHost
  #   2. hosts/<hostname>/hardware.nix committed in the repo
  #   3. /etc/nixos/hardware-configuration.nix (bootstrap fallback)
  #   4. nothing
  #
  # Rule 4 lets the flake evaluate for the `disko` step, which runs before the
  # target is mounted and its hardware.nix exists. disko only reads
  # `config.disko.devices`, so no hardware config is needed there. Prefer
  # committing the real file (or passing `hardware`) once installed; the
  # /etc/nixos fallback is only for bootstrapping on a live NixOS system.
  findHardwareConfig =
    hostname: hardware:
    let
      repoHw = ../hosts/${hostname}/hardware.nix;
      etcHw = /etc/nixos/hardware-configuration.nix;
    in
    if hardware != null then
      hardware
    else if builtins.pathExists repoHw then
      repoHw
    else if builtins.pathExists etcHw then
      etcHw
    else
      null;

  # A profile can be either <name>.nix or <name>/default.nix, so both flat
  # profiles and grouped directories work.
  resolveProfile =
    name:
    let
      file = profilesDir + "/${name}.nix";
      dir = profilesDir + "/${name}/default.nix";
    in
    if builtins.pathExists file then
      file
    else if builtins.pathExists dir then
      dir
    else
      throw ''
        No NixOS profile named "${name}".
        Checked:
          - ${toString file}
          - ${toString dir}
      '';
in
{
  hostname,
  system ? "x86_64-linux",
  # Base role profile. Selects modules/profiles/<roleDir>/default.nix.
  role ? "workstation",
  # Extra profiles layered on top (relative to modules/profiles/),
  # e.g. profiles = [ "desktop" "nvidia" ].
  profiles ? [ ],
  # Optional explicit hardware config path (see findHardwareConfig).
  hardware ? null,
}:
let
  hwPath = findHardwareConfig hostname hardware;

  roleProfileDir = roleDir role;
  baseProfile = resolveProfile roleProfileDir;

  # Per-machine profile, automatically applied when present:
  #   modules/profiles/<roleDir>/<hostname>.nix
  hostProfile = profilesDir + "/${roleProfileDir}/${hostname}.nix";

  profilePaths =
    [ baseProfile ]
    ++ nixpkgs.lib.optional (builtins.pathExists hostProfile) hostProfile
    ++ map resolveProfile profiles;
in
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit
      inputs
      vars
      hostname
      role
      profiles
      ;
  };
  modules = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops

    ../hosts/${hostname}/disko.nix
    ./helpers-module.nix
  ] ++ nixpkgs.lib.optional (hwPath != null) hwPath ++ profilePaths;
}
