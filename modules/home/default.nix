{
  pkgs,
  helpers,
  vars,
  ...
}:
let
  homeFiles = vars.paths.homeFiles;
  scripts = vars.paths.scripts;
in
{
  imports = [
    ./programs
    ./secrets.nix
  ];

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    gnome-calculator
    fuzzel
    libtool
    ispell
    xclip
    ffmpegthumbnailer
    mediainfo
    imagemagick
    ntfy
    #freecad-wayland
    trash-cli
    gojq
    libnotify
    imv
    yad
    hyprlock
    just
    tesseract
    qbittorrent
  ];

  home.file = helpers.mkFiles {
    symlinked = [
      {
        target = ".config/scripts";
        source = scripts;
      }
      {
        target = ".config/fastfetch";
        source = "${homeFiles}/fastfetch";
      }
      {
        target = ".config/matugen";
        source = "${homeFiles}/matugen";
      }
      {
        target = ".local/bin";
        source = "${homeFiles}/bin";
      }
      {
        target = ".local/share/nautilus/scripts";
        source = "${homeFiles}/nautilus-scripts";
      }
      {
        target = ".config/hypr/hyprlock.conf";
        source = "${homeFiles}/hyprlock.conf";
      }
      {
        target = ".mozilla/native-messaging-hosts/nox.handoff_host.json";
        source = "${homeFiles}/nox.handoff_host.json";
      }
      {
        target = ".config/codebook/codebook.toml";
        source = "${homeFiles}/codebook.toml";
      }
      {
        target = ".config/tridactyl/.tridactylrc";
        source = "${homeFiles}/.tridactylrc";
      }
      {
        target = ".XCompose";
        source = "${homeFiles}/.XCompose";
      }
      {
        target = ".face";
        source = "${homeFiles}/profile.png";
      }
    ];
  };

  news.display = "silent";

  home = {
    enableNixpkgsReleaseCheck = false;
    stateVersion = "26.11";
  };
}
