#!/usr/bin/env nu

let stable_urls = [
  [link, os];
  ["https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop", linux]
  ["https://api.beeper.com/desktop/download/linux/arm64/stable/com.automattic.beeper.desktop", linux]
  ["https://api.beeper.com/desktop/download/macos/x64/stable/com.automattic.beeper.desktop", darwin]
  ["https://api.beeper.com/desktop/download/macos/arm64/stable/com.automattic.beeper.desktop", darwin]
]

# Get the latest Download URL
mut pkg_defs = {}
$pkg_defs.stable = $stable_urls | each -f { |thing|
  let download_url = http get $thing.link -R m
  | parse "Found. Redirecting to {url}" | $in.0.url

  mut info = {}

  if $thing.os == linux {
    $info = $download_url
    | parse "https://beeper-desktop.download.beeper.com/builds/Beeper-{version}-{arch}.AppImage"
    | $in.0
  } else {
    if ($download_url | str contains 'arm64') {
      $info = $download_url
      | parse "https://beeper-desktop.download.beeper.com/builds/Beeper-{version}-{arch}.dmg"
      | $in.0
    } else {
      $info = $download_url
      | parse "https://beeper-desktop.download.beeper.com/builds/Beeper-{version}.dmg"
      | $in.0
      $info.arch = "x86_64" 
    }
  }

  # Get the SRI Hash
  $info.hash = ^nix-prefetch-url $download_url --type sha256
  | nix hash convert --hash-algo sha256 $in
  $info.os = $thing.os

  $"{ ($info.arch)-($info.os): { version: ($info.version), hash: ($info.hash), url: \"($download_url)\" } }" | from nuon
}
| reduce { |it| merge $it }

$pkg_defs | to toml | save manifest.toml -f
