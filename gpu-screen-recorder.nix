{
  stdenv,
  lib,
  makeWrapper,
  meson,
  ninja,
  addDriverRunpath,
  pkg-config,
  libxcomposite,
  libpulseaudio,
  dbus,
  ffmpeg,
  wayland,
  wayland-scanner,
  vulkan-headers,
  pipewire,
  libdrm,
  libva,
  libglvnd,
  libxdamage,
  libxi,
  libxrandr,
  libxfixes,
  libcap,
  libx11,
  vulkan-loader,
  wrapperDir ? "/run/wrappers/bin",
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  name = "gpu-screen-recorder";
  version = "5.13.6";

  src = fetchGit {
    url = "https://repo.dec05eba.com/gpu-screen-recorder";
    rev = "34d8f62f46f01fcd0953ec3dc9e1ee1c56aaf999";
    ref = "master";
    submodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    meson
    ninja
  ];

  buildInputs = [
    vulkan-loader
    libx11
    libcap
    libxcomposite
    libpulseaudio
    dbus
    ffmpeg
    pipewire
    wayland
    wayland-scanner
    vulkan-headers
    libdrm
    libva
    libxdamage
    libxi
    libxrandr
    libxfixes
  ];

  mesonFlags = [
    # Install the upstream systemd unit
    (lib.mesonBool "systemd" true)
    # Enable Wayland support
    (lib.mesonBool "portal" true)
    # Handle by the module
    (lib.mesonBool "capabilities" false)
    (lib.mesonBool "nvidia_suspend_fix" false)
  ];

  postInstall = ''
    mkdir $out/bin/.wrapped
    mv $out/bin/gpu-screen-recorder $out/bin/.wrapped/
    makeWrapper "$out/bin/.wrapped/gpu-screen-recorder" "$out/bin/gpu-screen-recorder" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libglvnd
          addDriverRunpath.driverLink
        ]
      }" \
      --prefix PATH : "${wrapperDir}" \
      --suffix PATH : "$out/bin"
  '';

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Screen recorder that has minimal impact on system performance by recording a window using the GPU only";
    homepage = "https://git.dec05eba.com/gpu-screen-recorder/about/";
    license = lib.licenses.gpl3Only;
    mainProgram = "gpu-screen-recorder";
    maintainers = with lib.maintainers; [
      babbaj
      js6pak
      rPlakama
    ];
    platforms = [ "x86_64-linux" ];
  };
})
