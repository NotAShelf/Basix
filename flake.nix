{
  description = "Base16/Base24 schemes for Nix";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {pkgs, ...}: {
        packages = {
          convert-scheme = pkgs.callPackage ./packages/convert-scheme/package.nix {};
        };
      };

      flake = let
        inherit (inputs.nixpkgs) lib;
        evalSchemeData = x:
          (lib.mapAttrs' (
            n: v:
              lib.optionalAttrs (v == "regular" && lib.hasSuffix ".json" n) {
                name = lib.removeSuffix ".json" n;
                value = x + n;
              }
          ))
          (builtins.readDir x);
      in {
        schemeData = {
          base16 = evalSchemeData ./json/base16;
          base24 = evalSchemeData ./json/base24;
        };
      };
    };
}
