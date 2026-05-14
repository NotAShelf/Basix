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

  gtkrc = ''
    gtk-color-scheme = "bg_color:#${hex "base00"}\nfg_color:#${hex "base05"}\nbase_color:#${hex "base01"}\ntext_color:#${hex "base05"}\nselected_bg_color:#${hex "base0D"}\nselected_fg_color:#${hex "base00"}\ntooltip_bg_color:#${hex "base01"}\ntooltip_fg_color:#${hex "base05"}"

    style "basix-default" {
      bg[NORMAL] = "#${hex "base00"}"
      bg[ACTIVE] = "#${hex "base02"}"
      bg[PRELIGHT] = "#${hex "base01"}"
      bg[SELECTED] = "#${hex "base0D"}"
      fg[NORMAL] = "#${hex "base05"}"
      fg[INSENSITIVE] = "#${hex "base04"}"
      fg[SELECTED] = "#${hex "base00"}"
      text[NORMAL] = "#${hex "base05"}"
      text[SELECTED] = "#${hex "base00"}"
      base[NORMAL] = "#${hex "base01"}"
      base[INSENSITIVE] = "#${hex "base03"}"
      base[SELECTED] = "#${hex "base0D"}"
    }

    class "*" style "basix-default"
  '';

  gtkCss = ''
    @define-color bg_color #${hex "base00"};
    @define-color fg_color #${hex "base05"};
    @define-color base_color #${hex "base01"};
    @define-color text_color #${hex "base05"};
    @define-color selected_bg_color #${hex "base0D"};
    @define-color selected_fg_color #${hex "base00"};
    @define-color borders #${hex "base03"};
    @define-color warning_color #${hex "base09"};
    @define-color error_color #${hex "base08"};
    @define-color success_color #${hex "base0B"};

    window, dialog, popover, menu, viewport {
      background-color: @bg_color;
      color: @fg_color;
    }

    entry, textview, treeview, list {
      background-color: @base_color;
      color: @text_color;
      border: 1px solid @borders;
    }

    button, headerbar, toolbar {
      background-color: @base_color;
      color: @fg_color;
      border: 1px solid @borders;
      box-shadow: none;
    }

    scrollbar slider {
      background-color: @base_color;
      border: 1px solid @borders;
    }

    selection {
      background-color: @selected_bg_color;
      color: @selected_fg_color;
    }
  '';
in
  stdenvNoCC.mkDerivation {
    pname = "basix-gtk-theme-${slugSafe}";
    version = "1.0.0";
    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/themes/${themeName}/gtk-2.0"
      mkdir -p "$out/share/themes/${themeName}/gtk-3.0"
      mkdir -p "$out/share/themes/${themeName}/gtk-4.0"

      cat > "$out/share/themes/${themeName}/gtk-2.0/gtkrc" <<'EOF_GTK2'
      ${gtkrc}
      EOF_GTK2

      cat > "$out/share/themes/${themeName}/gtk-3.0/gtk.css" <<'EOF_GTK3'
      ${gtkCss}
      EOF_GTK3

      cat > "$out/share/themes/${themeName}/gtk-4.0/gtk.css" <<'EOF_GTK4'
      ${gtkCss}
      EOF_GTK4
      runHook postInstall
    '';

    meta = {
      description = "Generated GTK theme assets for Basix schemes";
      platforms = lib.platforms.all;
      license = lib.licenses.gpl3Only;
    };
  }
