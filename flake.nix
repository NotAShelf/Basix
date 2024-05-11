{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {pkgs, ...}: {
        # Example if we could make it a list:
        # builtins.mapAttrs (_: p: builtins.fromJSON (builtins.readFile p)) (import ./list.nix)
        packages = {
          convert-scheme = pkgs.callPackage ./packages/convert-scheme/package.nix {};
        };
      };
    };
}
