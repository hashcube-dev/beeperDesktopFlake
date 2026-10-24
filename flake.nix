{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = { self, nixpkgs, systems, ... }:
  let
    eachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    packages = eachSystem (system:
    let
      pkgs = import nixpkgs {
        system = "${system}";
      };
    in {
      default = self.packages.${system}.beeper.stable;
      beeper = {
        stable = pkgs.callPackage ./default.nix { os = system; inherit pkgs; };
      };
    });
  };
}
