{ pkgs, ... }:
{
  imports = [
    ./emacs.nix
    ./git.nix
  ];

  home.packages = with pkgs; [
    (python3.withPackages (
      python-pkgs: with python-pkgs; [
        pandas
        matplotlib
        requests
        ipython
      ]
    ))
    uv
    flutter
    nixd
    platformio-core
    fritzing
    kotlin
    gradle
    jdk21
  ];
}
