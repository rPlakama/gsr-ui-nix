{
  pkgs ? import <nixpkgs> { },
  lib,
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
  wrapGAppsHook3,
  libxkbcommon,
  gsettings-desktop-schemas,
  wrapperDir ? "/run/wrappers/bin",
}:
pkgs.stdenv.mkDerivation {
  pname = "gpu-screen-recorder-ui";
  version = "unstable-2026-05-11";
  src = fetchGit {
    url = "https://repo.dec05eba.com/gpu-screen-recorder-ui";
    rev = "e9a37d135498b60e61d2b97a20725c02dcfe5ddb";
    ref = "master";
    submodules = true;
  };
  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    makeWrapper
    meson
    cmake
    ninja
  ];
  buildInputs = [
    gsettings-desktop-schemas
    libxkbcommon
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
        email = "enovale@proton.me";
        name = "enova";
      }
      {
        email = "iwisp360@protonmail.com";
        name = "iWisp360";
      }
      {
        email = "rPlakama@proton.me";
        name = "rPlakama";
      }
    ];
    platforms = [ "x86_64-linux" ];
  };
}
