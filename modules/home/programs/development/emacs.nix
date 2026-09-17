{ pkgs, ... }:
let
  emacsPkg = pkgs.emacs-unstable-pgtk;

  emacsclient-capture = pkgs.writeShellScriptBin "emacsclient-capture" ''
    emacsclient -c -F '((name . "emacs-capture"))' "$@"
  '';

  emacs-debug = pkgs.makeDesktopItem {
    icon = "emacs";
    name = "emacs-debug";
    exec = "${emacsPkg}/bin/emacs --debug-init";
    desktopName = "Emacs (Debug Mode)";
    comment = "Emacs with debug init";
    terminal = false;
  };

  dired = pkgs.makeDesktopItem {
    name = "dired";
    desktopName = "Dired";
    comment = "Emacs Dired as file manager";
    exec = "dired %u";
    icon = "system-file-manager";
    terminal = false;
    type = "Application";
    mimeTypes = [ "inode/directory" ];
    categories = [
      "System"
      "FileManager"
    ];
  };
in
{
  programs.emacs = {
    enable = true;
    package = emacsPkg;
  };

  services.emacs = {
    enable = true;
    package = emacsPkg;
    client.enable = true;
    defaultEditor = true;
    startWithUserSession = "graphical";
  };

  home.packages = with pkgs; [
    emacs-debug
    dired

    # Encryption
    age
    sops

    # utils
    zip
    poppler-utils

    # LATEX
    texliveMedium
    vips

    nixfmt

    # Mason & Apheleia
    nodejs-slim.npm
    nodejs-slim
    # python3
  ];

  xdg.desktopEntries.org-protocol = {
    name = "Org Protocol";
    exec = "${emacsclient-capture}/bin/emacsclient-capture -- %u";
    icon = "emacs";
    type = "Application";
    mimeType = [ "x-scheme-handler/org-protocol" ];
    terminal = false;
  };
}
