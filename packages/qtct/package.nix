{
  basixLib,
  lib,
  stdenvNoCC,
}: {
  slug,
  scheme,
}: let
  palette = basixLib.validatePalette {
    inherit slug;
    palette = scheme.palette or {};
  };
  slugSafe = basixLib.sanitizeSlug slug;
  themeName = basixLib.mkThemeName slugSafe;
  hex = key: basixLib.normalizeHex palette.${key};
  argb = key: "#ff${hex key}";

  qtConf = ''
    [ColorScheme]
    active_colors=${argb "base00"},${argb "base05"},${argb "base01"},${argb "base02"},${argb "base03"},${argb "base04"},${argb "base0D"},${argb "base00"},${argb "base08"},${argb "base09"},${argb "base0A"},${argb "base0B"},${argb "base0C"},${argb "base0E"}
    disabled_colors=${argb "base03"},${argb "base04"},${argb "base02"},${argb "base03"},${argb "base03"},${argb "base04"},${argb "base03"},${argb "base04"},${argb "base08"},${argb "base09"},${argb "base0A"},${argb "base0B"},${argb "base0C"},${argb "base0E"}
    inactive_colors=${argb "base00"},${argb "base05"},${argb "base01"},${argb "base02"},${argb "base03"},${argb "base04"},${argb "base0D"},${argb "base00"},${argb "base08"},${argb "base09"},${argb "base0A"},${argb "base0B"},${argb "base0C"},${argb "base0E"}
  '';
in
  stdenvNoCC.mkDerivation {
    pname = "basix-qtct-theme-${slugSafe}";
    version = "1.0.0";
    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/qt5ct/colors"
      mkdir -p "$out/share/qt6ct/colors"

      cat > "$out/share/qt5ct/colors/${themeName}.conf" <<'EOF_QT'
      ${qtConf}
      EOF_QT

      cat > "$out/share/qt6ct/colors/${themeName}.conf" <<'EOF_QT'
      ${qtConf}
      EOF_QT
      runHook postInstall
    '';

    meta = {
      description = "Generated qt5ct and qt6ct color schemes for Basix schemes";
      platforms = lib.platforms.all;
      license = lib.licenses.gpl3Only;
    };
  }
