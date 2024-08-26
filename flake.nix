{
  description = "Base16/Base24 schemes for Nix";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs @ {
    flake-parts,
    self,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {pkgs, ...}: {
        packages = {
          convert-scheme = pkgs.callPackage ./packages/convert-scheme/package.nix {};
        };
      };

      flake = let
        inherit (inputs.nixpkgs) lib;
        evalSchemeData = lib.flip lib.pipe [
          builtins.unsafeDiscardStringContext
          lib.filesystem.listFilesRecursive
          (builtins.filter (lib.hasSuffix ".json"))
          (map (n: {
            name = lib.removePrefix ((dirOf n) + "/") (lib.removeSuffix ".json" n);
            value = lib.importJSON n;
          }))
          lib.listToAttrs
        ];
      in {
        lib = {
          inherit evalSchemeData;
        };

        schemeData = {
          base16 = evalSchemeData "${self}/json/base16";
          base24 = evalSchemeData "${self}/json/base24";
        };
      };
    };
}
