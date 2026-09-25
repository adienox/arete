# Helper functions for common module patterns
#
# These utilities simplify and DRY up recurring patterns in home-manager
# and system modules, reducing boilerplate and improving maintainability.
{
  lib,
  config,
}:
let
  inherit (lib) mkIf;
in
rec {
  # Create a symlinked config file entry that points to a source outside /nix/store
  # This allows editing the source file without breaking the symlink
  #
  # Usage:
  #   mkSymlinkedFile {
  #     target = ".config/example/config.toml";
  #     source = "${vars.paths.homeFiles}/config.toml";
  #   }
  mkSymlinkedFile =
    { target, source }:
    {
      ${target}.source = config.lib.file.mkOutOfStoreSymlink source;
    };

  # Create multiple symlinked config file entries from a list and merge
  # them into a single attrset, suitable for `home.file`.
  #
  # Usage:
  #   home.file = mkSymlinkedFiles [
  #     { target = ".config/app"; source = "${vars.paths.homeFiles}/app"; }
  #     { target = ".local/bin"; source = "${vars.paths.homeFiles}/bin"; }
  #   ];
  mkSymlinkedFiles = files: lib.foldl' (acc: f: acc // mkSymlinkedFile f) { } files;

  # Create a home.file entry for a regular (copied) file
  # These files are copied into the nix store, not symlinked
  #
  # Usage:
  #   mkConfigFile {
  #     target = ".XCompose";
  #     source = ./files/.XCompose;
  #   }
  mkConfigFile =
    { target, source }:
    {
      ${target}.source = source;
    };

  # Create multiple config file entries from a list and merge them into a
  # single attrset, suitable for `home.file`.
  #
  # Usage:
  #   home.file = mkConfigFiles [
  #     { target = ".XCompose"; source = ./files/.XCompose; }
  #     { target = ".face"; source = ./files/profile.png; }
  #   ];
  mkConfigFiles = files: lib.foldl' (acc: f: acc // mkConfigFile f) { } files;

  # Convenience wrapper combining symlinked and copied files into a single
  # attrset suitable for `home.file`.
  #
  # Usage:
  #   home.file = mkFiles {
  #     symlinked = [
  #       { target = ".config/app"; source = "${vars.paths.homeFiles}/app"; }
  #     ];
  #     copied = [
  #       { target = ".XCompose"; source = ./files/.XCompose; }
  #     ];
  #   };
  mkFiles =
    {
      symlinked ? [ ],
      copied ? [ ],
    }:
    mkSymlinkedFiles symlinked // mkConfigFiles copied;

  # Merge multiple enable options into a single config option, and enable
  # all of the given submodules whenever the group is enabled.
  # Group defaults to true enabling all its modules.
  #
  # Usage:
  # imports = [
  #   (mkModuleGroup "shell"   [ "zsh" "starship" "git" ])
  #   (mkModuleGroup "desktop" [ "hyprland" "waybar" "rofi" ])
  #   (mkModuleGroup "dev"     [ "emacs" "python-dev" "direnv" ])
  # ];
  mkModuleGroup = name: modules: {
    options.modules.${name}.enable = lib.mkEnableOption name // {
      default = true;
    };
    config = mkIf config.modules.${name}.enable {
      modules = lib.genAttrs modules (_: {
        enable = lib.mkDefault true;
      });
    };
  };
}
