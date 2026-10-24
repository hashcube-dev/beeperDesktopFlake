#!/usr/bin/env nu

let stable_urls = [
  [link, os, pattern];
  ["https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop", linux, "https://beeper-desktop.download.beeper.com/builds/Beeper-{version}-{arch}.AppImage"]
  ["https://api.beeper.com/desktop/download/linux/arm64/stable/com.automattic.beeper.desktop", linux, "https://beeper-desktop.download.beeper.com/builds/Beeper-{version}-{arch}.AppImage"]
  # ["https://api.beeper.com/desktop/download/macos/x64/stable/com.automattic.beeper.desktop", darwin, "https://beeper-desktop.download.beeper.com/builds/Beeper-{version}.dmg"]
  # ["https://api.beeper.com/desktop/download/macos/arm64/stable/com.automattic.beeper.desktop", darwin "https://beeper-desktop.download.beeper.com/builds/Beeper-{version}-{arch}.dmg"]
]
let nightly_urls = [
  [link, os, pattern];
  ["https://api.beeper.com/desktop/download/linux/x64/nightly/com.automattic.beeper.desktop", linux, "https://beeper-desktop.download.beeper.com/builds/Beeper-Nightly-{version}-{arch}.AppImage"]
  ["https://api.beeper.com/desktop/download/linux/arm64/nightly/com.automattic.beeper.desktop", linux, "https://beeper-desktop.download.beeper.com/builds/Beeper-Nightly-{version}-{arch}.AppImage"]
  # ["https://api.beeper.com/desktop/download/macos/x64/nightly/com.automattic.beeper.desktop", darwin, "https://beeper-desktop.download.beeper.com/builds/Beeper%20Nightly-{version}.dmg"]
  # ["https://api.beeper.com/desktop/download/macos/arm64/nightly/com.automattic.beeper.desktop", darwin, "https://beeper-desktop.download.beeper.com/builds/Beeper%20Nightly-{version}-{arch}.dmg"]
]
let beta_urls = [
  [link, os, pattern];
  ["https://api.beeper.com/desktop/download/linux/x64/beta/com.automattic.beeper.desktop", linux, "https://beeper-desktop.download.beeper.com/builds/BeeperNightly-{version1}-linux-{arch}-{version2}.AppImage"]
  # ["https://api.beeper.com/desktop/download/macos/x64/beta/com.automattic.beeper.desktop", darwin, "https://beeper-desktop.download.beeper.com/builds/BeeperNightly-{version1}-mac-{arch}-{version2}.zip"]
  # ["https://api.beeper.com/desktop/download/macos/arm64/beta/com.automattic.beeper.desktop", darwin, "https://beeper-desktop.download.beeper.com/builds/BeeperNightly-{version1}-mac-{arch}-{version2}.zip"]
]

let parse_url_list = { |it|
  let download_url = http get $it.link -R m
  | parse "Found. Redirecting to {url}" | $in.0.url

  mut info = {}

  $info = $download_url
  | parse $it.pattern
  | $in.0
  # Get the SRI Hash
  $info.hash = ^nix-prefetch-url $download_url --name "beeper" --type sha256
  | nix hash convert --hash-algo sha256 $in
  $info.os = $it.os
  if $info.version? == null { $info.version = ""}
  if $info.version1? != null { $info.version = $info.version + $info.version1}
  if $info.version2? != null { $info.version += $info.version + "-" + $info.version2}
  if $info.arch? == null { $info.arch = "x86_64" } 
  if $info.arch == "x64" { $info.arch = "x86_64" } 
  if $info.arch == "arm64" { $info.arch = "aarch64" } 

  $"{ \"($info.arch)-($info.os)\": { version: \"($info.version)\", hash: \"($info.hash)\", url: \"($download_url)\" } }" | from nuon
}

mut pkg_defs = {}

$pkg_defs.stable = $stable_urls
| each -f $parse_url_list
| reduce { |it| merge $it }

$pkg_defs.nightly = $nightly_urls
| each -f $parse_url_list
| reduce { |it| merge $it }

$pkg_defs.beta = $beta_urls
| each -f $parse_url_list
| reduce { |it| merge $it }

$pkg_defs | to toml | save manifest.toml -f
