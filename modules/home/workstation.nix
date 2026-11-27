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

  home.packages = with pkgs; [
    gnome-calculator
    libtool
    ispell
    ffmpegthumbnailer
    mediainfo
    imagemagick
    keylightd
    #freecad-wayland
    libnotify
    yad
    qbittorrent
  ];

  home.file = helpers.mkFiles {
    symlinked = [
      {
        target = ".config/scripts";
        source = scripts;
      }
      {
        target = ".local/share/assets";
        source = "${homeFiles}/assets";
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
        target = ".config/codebook/codebook.toml";
        source = "${homeFiles}/codebook.toml";
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
}
