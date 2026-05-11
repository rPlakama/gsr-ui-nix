{
  pkgs ? import <nixpkgs> { },
  lib,
  fetchurl,
  pkg-config,
  addDriverRunpath,
  desktop-file-utils,
  makeWrapper,
  meson,
  ninja,
  cmake,
  libpulseaudio,
  libdrm,
  mesa,
  gpu-screen-recorder,
  libglvnd,
  libX11,
  libXrandr,
  libXcomposite,
  libXcursor,
  libXext,
  libXfixes,
  libXrender,
  libXi,
  libcap,
  freetype,
  glib,
  pango,
  notify,
  dbus,
  wayland,
  wayland-scanner,
  wrapperDir ? "/run/wrappers/bin",
}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "gpu-screen-recorder-ui";
  version = "1.11.8";

  src = fetchurl {
    url = "https://dec05eba.com/snapshot/gpu-screen-recorder-ui.git.${finalAttrs.version}.tar.gz";
    hash = "sha256-1kXaoXKi897zN5TcOBXnTK6MtEH/25EOG4FTpE/4aN0=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    meson
    cmake
    ninja
  ];

  buildInputs = [
    freetype
    glib
    pango
    libpulseaudio
    desktop-file-utils
    libdrm
    libX11
    libXrandr
    libXcomposite
    libXcursor
    libXext
    libXfixes
    libXrender
    libXi
    wayland
    dbus
    wayland-scanner
    libcap
  ];

  preFixup =
    let
      gpu-screen-recorder-wrapped = gpu-screen-recorder.override {
        inherit wrapperDir;
      };
    in
    ''
      wrapProgram "$out/bin/gsr-ui" \
        --prefix PATH : ${wrapperDir} \
        --suffix PATH : ${
          lib.makeBinPath [
            notify
            gpu-screen-recorder-wrapped
          ]
        } \
        --prefix LD_LIBRARY_PATH : ${
          lib.makeLibraryPath [
            mesa
            libglvnd
            addDriverRunpath.driverLink
          ]
        }
    '';

  meta = {
    description = "Shadowplay-like frontend for gpu-screen-recorder.";
    homepage = "https://git.dec05eba.com/gpu-screen-recorder-ui/about/";
    license = lib.licenses.gpl3Only;
    mainProgram = "gpu-screen-recorder-ui";
    maintainers = with lib.maintainers; [
      {
        email = "rPlakama@proton.me";
        name = "rPlakama";
      }

      {
        email = "enovale@proton.me";
        name = "enova";
      }
      {
        email = "iwisp360@protonmail.com";
        name = "iWisp360";
      }
    ];
    platforms = [ "x86_64-linux" ];
  };
})
