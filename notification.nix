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
  gsettings-desktop-schemas,
  wrapGAppsHook3,
  glib,
  wayland,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gpu-screen-recorder-notification";

  src = fetchGit {
    url = "https://repo.dec05eba.com/gpu-screen-recorder-notification";
    rev = "013e758ecba50ca2043f6f9d334aebcbca6dbdd5";
    hash = "sha256-vJ3cs+XNOyzLRhZ1L6qLzz1k/u2fJBrLjoStHNySk8A=";
    ref = "master";
    submoduels = true;
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    meson
    ninja
    wrapGAppsHook3
  ];

  buildInputs = [
    gsettings-desktop-schemas
    glib
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
