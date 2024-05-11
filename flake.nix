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
      perSystem = {
        self',
        config,
        pkgs,
        lib,
        ...
      }: let
        inherit (builtins) filter map toString;
        inherit (lib.filesystem) listFilesRecursive;
        inherit (lib.strings) hasSuffix concatStringsSep;
        listAllSchemes = path: filter (hasSuffix ".yaml") (map toString (listFilesRecursive path));
      in {
        # for some fucking reason all tinted-theming themes are in yaml. you know what's wrong with that?
        # fromJSON cannot read it! That iss because yaml is a stupid fucking format and nobody should use it
        # But since the idiots at tinted-theming decided to use it (of course they would) we have to read each
        # yaml file and then convert it to JSON. Why? so that we can FUCKING PARSE IT.
        # FIXME: this actually does nothing. Because listFilesRecursive simply returns a list of strings.
        # We would like to organize each theme in a {name = "path"} format so that we can parse the output
        # e.g. from a list and expose each palette as an attribute set.
        # Example if we could make it a list:
        # builtins.mapAttrs (_: p: builtins.fromJSON (builtins.readFile p)) (import ./list.nix)
        packages = {
          convert-scheme = pkgs.callPackage ./packages/convert-scheme/package.nix {};
          convert-all-schemes = pkgs.runCommandLocal "convert-all-schemes" {} ''
            mkdir $out

            for scheme in ${concatStringsSep " " (listAllSchemes inputs.schemes)}
            do
                ${self'.packages.convert-scheme + /bin/convert-scheme} "$scheme" ${placeholder "out"}/"$scheme"
            done
          '';
        };
      };
    };
}
