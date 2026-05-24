{ pkgs, appimageTools, copyDesktopItems, makeDesktopItem, ... }:
let
  pname = "beeper";
  version = "4.2.860";
  src = pkgs.fetchurl {
    url = "https://beeper-desktop.download.beeper.com/builds/Beeper-${version}-x86_64.AppImage";
    hash = "sha256-zTBPJCdKoIQVWSyVN88fysZYyaxlIYI0LfQJJYTaKn4=";
  };

  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 rec {
  inherit pname version src;
  pkgs = pkgs;

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