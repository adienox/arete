{
  lib,
  stdenv,
  fetchurl,
  ...
}:
stdenv.mkDerivation {
  name = "apple-color-emoji";
  version = "macos-26";

  src = fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-ttf/releases/latest/download/AppleColorEmoji-Linux.ttf";
    sha256 = "sha256:U1oEOvBHBtJEcQWeZHRb/IDWYXraLuo0NdxWINwPUxg=";
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
