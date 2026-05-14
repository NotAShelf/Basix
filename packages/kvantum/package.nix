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

  kvConfig = ''
    [GeneralColors]
    window.color=#${hex "base00"}
    button.color=#${hex "base02"}
    text.color=#${hex "base05"}
    disabled.text.color=#${hex "base04"}
    highlight.color=#${hex "base0D"}
    highlighted.text.color=#${hex "base00"}
  '';

  kvSvg = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" version="1.1">
      <rect x="0" y="0" width="64" height="64" fill="#${hex "base00"}"/>
      <rect x="8" y="8" width="48" height="20" rx="2" ry="2" fill="#${hex "base02"}"/>
      <rect x="8" y="36" width="48" height="20" rx="2" ry="2" fill="#${hex "base0D"}"/>
    </svg>
  '';
in
  stdenvNoCC.mkDerivation {
    pname = "basix-kvantum-theme-${slugSafe}";
    version = "1.0.0";
    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/Kvantum/${themeName}"

      cat > "$out/share/Kvantum/${themeName}/${themeName}.kvconfig" <<'EOF_KVCONFIG'
      ${kvConfig}
      EOF_KVCONFIG

      cat > "$out/share/Kvantum/${themeName}/${themeName}.svg" <<'EOF_KVSVG'
      ${kvSvg}
      EOF_KVSVG
      runHook postInstall
    '';

    meta = {
      description = "Generated Kvantum theme assets for Basix schemes";
      platforms = lib.platforms.all;
      license = lib.licenses.gpl3Only;
    };
  }
