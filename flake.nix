{
  description = "Base16/Base24 schemes for Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    flake-parts,
    self,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} (let
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

      # FWIW this could also be lib.extend but lib.extend itself claims that
      # it should not be used, so we do this instead.
      inherit (inputs.nixpkgs) lib;
      basixLib = import ./lib.nix {inherit lib;};

      mkThemeAttrSet = pkgs: schemes: let
        mkGtkTheme = pkgs.callPackage ./packages/gtk/package.nix {basixLib = self.lib;};
        mkQtctTheme = pkgs.callPackage ./packages/qtct/package.nix {basixLib = self.lib;};
        mkKvantumTheme = pkgs.callPackage ./packages/kvantum/package.nix {basixLib = self.lib;};
      in
        lib.mapAttrs (slug: scheme:
          pkgs.symlinkJoin {
            name = "basix-theme-${self.lib.sanitizeSlug slug}";
            paths = [
              (mkGtkTheme {inherit slug scheme;})
              (mkQtctTheme {inherit slug scheme;})
              (mkKvantumTheme {inherit slug scheme;})
            ];
          })
        schemes;

      mkSystemThemePackages = system: let
        pkgs = import inputs.nixpkgs {inherit system;};
      in {
        base16 = mkThemeAttrSet pkgs self.schemeData.base16;
        base24 = mkThemeAttrSet pkgs self.schemeData.base24;
      };
    in {
      inherit systems;
      perSystem = {
        pkgs,
        system,
        ...
      }: let
        themePackages = self.themePackages.${system};
      in {
        packages = {
          # Converts YAML -> JSON
          convert-scheme = pkgs.callPackage ./packages/convert-scheme/package.nix {};

          # Theme collections
          themes-base16 = pkgs.symlinkJoin {
            name = "basix-themes-base16";
            paths = lib.attrValues themePackages.base16;
          };

          themes-base24 = pkgs.symlinkJoin {
            name = "basix-themes-base24";
            paths = lib.attrValues themePackages.base24;
          };

          themes-all = pkgs.symlinkJoin {
            name = "basix-themes-all-${system}";
            paths = (lib.attrValues themePackages.base16) ++ (lib.attrValues themePackages.base24);
          };
        };
      };

      flake = let
        inherit (basixLib) evalSchemeData;
      in {
        lib = basixLib;

        schemeData = {
          base16 = evalSchemeData "${self}/json/base16";
          base24 = evalSchemeData "${self}/json/base24";
        };

        themePackages = lib.genAttrs systems mkSystemThemePackages;
      };
    });
}
