{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "keylightd";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "jonas-schievink";
    repo = "keylightd";
    rev = "933a4cf851009d4a8c1b4ce7725556d69d4b82db";
    hash = lib.fakeHash;
  };

  cargoHash = lib.fakeHash;

  meta = {
    description = "Keyboard backlight daemon for Framework laptops";
    homepage = "https://github.com/jonas-schievink/keylightd";
    license = lib.licenses._0bsd;
    platforms = [ "x86_64-linux" ];
    mainProgram = "keylightd";
  };
}
