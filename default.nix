{
  pkgs,
  appimageTools ? pkgs.appimageTools,
  copyDesktopItems ? pkgs.copyDesktopItems,
  makeDesktopItem ? pkgs.makeDesktopItem,
  importTOML ? pkgs.lib.importTOML,
  system ? "linux-x86_64",
  build ? "stable",
  ...
}:
let
  manifest = importTOML ./manifest.toml;
  pkg_info = manifest.${build}.${system};
  pname = "beeper";
  version = pkg_info.version;
  src = pkgs.fetchurl {
    inherit (pkg_info) url hash;
  };

  # Beeper's current AppImage stores its AI2 marker at offset 1024,
  # while nixpkgs' appimage-exec reads it from the ELF header.
  patchedSrc = pkgs.runCommand "${pname}-${version}-appimage-patched" { } ''
    cp ${src} $out
    chmod u+w $out
    printf '\x41\x49\x02' | dd of=$out bs=1 seek=8 conv=notrunc
  '';

  appimageContents = pkgs.appimageTools.extract {
    inherit pname version;
    src = patchedSrc;
  };
in
appimageTools.wrapAppImage rec {
  inherit pname version;
  src = appimageContents;
  nativeBuildInputs = [
    copyDesktopItems
  ];

  desktopItem = ( makeDesktopItem {
    name = "beeper";
    desktopName = "Beeper";
    exec = "${pname} %u";
    icon = "beepertexts.png";
    type = "Application";
    terminal = false;
    comment= "The ultimate messaging app";
    categories = [ "Network" "Chat" ];
    mimeTypes =[ "x-scheme-handler/beeper" ];
  });

  extraInstallCommands = ''
  mkdir -p $out/share/applications
  cp ${desktopItem}/share/applications/*.desktop $out/share/applications/
  cp -r ${appimageContents}/usr/share/icons $out/share

  # unless linked, the binary is placed in $out/bin/beeper-someVersion
  # ln -s $out/bin/${pname}-${version} $out/bin/${pname}
        '';
}
