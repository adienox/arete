{
  lib,
  stdenv,
  fetchurl,
  ...
}:
stdenv.mkDerivation rec {
  name = "apple-color-emoji";
  version = "macos-26-20260722-484daf4e";

  src = fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-ttf/releases/download/${version}/AppleColorEmoji-Linux.ttf";
    hash = "sha256-43x69iZaxKCvbVe8ZehhCad22ZZug0MzRVf2PaSCUW8=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp $src $out/share/fonts/truetype/AppleColorEmoji.ttf
  '';

  meta = {
    description = "Apple Color Emoji font for Linux";
    homepage = "https://github.com/samuelngs/apple-emoji-ttf";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
