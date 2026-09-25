{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6,
  bluez,
  dbus,
  glfw,
}:

stdenv.mkDerivation rec {
  pname = "sony-device-center";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "marconvcm";
    repo = "sony-device-center";
    rev = "v${version}";
    hash = "sha256-XpX91dXf85pY0h//S4P9TjKRveypz7r7Jhq2bCtI4R0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    bluez
    dbus
    glfw
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DSONY_REQUIRE_QT=ON"
  ];

  meta = {
    description = "Control Sony headphones from Linux";
    homepage = "https://github.com/marconvcm/sony-device-center";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "sony-device-center";
  };
}
