{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "keylightd";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "jonas-schievink";
    repo = "keylightd";
    rev = "933a4cf851009d4a8c1b4ce7725556d69d4b82db";
    hash = "sha256-lU5ddVRjiGts7IzkoL3CWJVtjoiBMIHRBxb/C0n+oqQ=";
  };

  patches = [
    ./fix-let-underscore-lock.patch
  ];

  cargoHash = "sha256-P3kJM4TI33ug5hmTLer91Wy1eVJGgtPRbvftqI3tbvY=";

  meta = {
    description = "Keyboard backlight daemon for Framework laptops";
    homepage = "https://github.com/jonas-schievink/keylightd";
    license = lib.licenses._0bsd;
    platforms = [ "x86_64-linux" ];
    mainProgram = "keylightd";
  };
}
