{
  pkgs ? import <nixpkgs> { },
  stdenv,
  lib,
  fetchurl,
  pkg-config,
  addDriverRunpath,
  makeWrapper,
  meson,
  ninja,
  libglvnd,
  freetype,
  pango,
  libX11,
  libXrandr,
  libXrender,
  libXext,
  wayland,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gpu-screen-recorder-notification";
  version = "1.2.3";

  src = fetchurl {
    url = "https://dec05eba.com/snapshot/gpu-screen-recorder-notification.git.${finalAttrs.version}.tar.gz";
    hash = "sha256-vJ3cs+XNOyzLRhZ1L6qLzz1k/u2fJBrLjoStHNySk8A=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    meson
    ninja
  ];

  buildInputs = [
    freetype
    pango
    libX11
    libXext
    libXrandr
    libXrender
    wayland
  ];

  preFixup = ''
    wrapProgram $out/bin/gsr-notify \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libglvnd
          addDriverRunpath.driverLink
        ]
      }
  '';

  meta = {
    description = "Notification overlay for gpu-screen-recorder-ui.";
    homepage = "https://git.dec05eba.com/gpu-screen-recorder-notification/about/";
    license = lib.licenses.gpl3Only;
    mainProgram = "gpu-screen-recorder-notification";
    maintainers = with lib.maintainers; [ enova ];
    platforms = [ "x86_64-linux" ];
  };
})
