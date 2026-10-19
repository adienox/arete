{ pkgs, ... }:
{
  imports = [
    ./emacs.nix
    ./git.nix
    ./devenv.nix
    ./pi.nix
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
    nixd
    platformio-core
  ];
}
