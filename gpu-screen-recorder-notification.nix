{
  pkgs ? import <nixpkgs> { },
  stdenv,
  lib,
  cmake,
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
  libxkbcommon,
  wayland-scanner,
}:
stdenv.mkDerivation (finalAttrs: {
  name = "gpu-screen-recorder-notification";
  version = "1.3.0";

  src = fetchGit {
    url = "https://repo.dec05eba.com/gpu-screen-recorder-notification";
    rev = "54919821258146826bed800a67b51c9492b3797a";
    ref = "master";
    submodules = true;
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    meson
    ninja
    wrapGAppsHook3
    cmake
  ];

  buildInputs = [
    gsettings-desktop-schemas
    libxkbcommon
    glib
    freetype
    pango
    libX11
    libXext
    libXrandr
    libXrender
    wayland
    wayland-scanner
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
