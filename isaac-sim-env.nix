{ pkgs ? import <nixpkgs> {} }:

let
  fakeArch = pkgs.writeShellScriptBin "arch" ''
    exec uname -m
  '';
in
pkgs.buildFHSEnv {
  name = "isaac-sim-env";

  targetPkgs = pkgs: [
    # C / C++ runtime expected by Isaac-Sim (built with GCC 11)
    pkgs.gcc11
    fakeArch
    pkgs.glibc

    # Window system / OpenGL / Vulkan
    pkgs.vulkan-loader pkgs.libglvnd
    pkgs.xorg.libX11 pkgs.xorg.libXi pkgs.xorg.libXext pkgs.xorg.libxcb
    pkgs.libxkbcommon

    # Audio (optional ‑ set ISAAC_DISABLE_AUDIO=1 if it causes trouble)
    pkgs.libpulseaudio pkgs.alsa-lib

    # Misc run-time deps
    pkgs.zlib pkgs.fontconfig pkgs.freetype
    pkgs.libxcrypt-legacy

    # HTTPS / DNS / CA stuff
    pkgs.cacert
    pkgs.openssl
    pkgs.curl

    pkgs.which pkgs.git
    pkgs.python3

    # NEW – libs demanded at runtime by MaterialX / Iray / etc.
    pkgs.xorg.libXt          # libXt.so.6
    pkgs.libGLU              # libGLU.so.1
    pkgs.xorg.libXrender     # libXrender.so.1   (often needed next)
    pkgs.libxcrypt-legacy    # some plugins still need libcrypt.so.1
  ];

  extraBwrapArgs = [ "--setenv" "SSL_CERT_FILE" "/etc/ssl/certs/ca-bundle.crt" ];
  runScript = "bash";
}
