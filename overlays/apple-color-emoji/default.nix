{
  lib,
  stdenv,
  fetchurl,
  ...
}:
stdenv.mkDerivation {
  name = "apple-color-emoji";
  version = "macos-26-20260722-484daf4e";

  src = fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-ttf/releases/download/${version}/AppleColorEmoji-Linux.ttf";
    hash = "sha256-0vsihaj3vxjp8lrl70vfjvcpd9q9c7l6bg2pdnps1i2s4vv7lz73";
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
