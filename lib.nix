{lib}: let
  requiredBaseKeys = [
    "base00"
    "base01"
    "base02"
    "base03"
    "base04"
    "base05"
    "base06"
    "base07"
    "base08"
    "base09"
    "base0A"
    "base0B"
    "base0C"
    "base0D"
    "base0E"
    "base0F"
  ];

  sanitizeSlug = slug:
    lib.strings.sanitizeDerivationName
    (lib.strings.toLower (toString slug));

  normalizeHex = color:
    lib.strings.toLower
    (lib.removePrefix "#" (toString color));

  missingBaseKeys = palette:
    builtins.filter (key: !(builtins.hasAttr key palette)) requiredBaseKeys;

  validatePalette = {
    slug,
    palette,
  }: let
    missing = missingBaseKeys palette;
  in
    if missing != []
    then throw "Basix theme generation failed for `${slug}`: missing palette keys ${lib.concatStringsSep ", " missing} (required: base00-base0F)"
    else palette;

  mkThemeName = slug: "Basix-${sanitizeSlug slug}";

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
  inherit
    evalSchemeData
    mkThemeName
    normalizeHex
    requiredBaseKeys
    sanitizeSlug
    validatePalette
    ;
}
