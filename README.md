# Basix

[@tinted-theming/schemes]: https://github.com/tinted-theming/schemes

An over-engineered, reusable Nix flake for _all_ Base16 and Base24 themes from
[@tinted-theming/schemes], exposed as one convenient schema collection, library
and opinionated theme packages for GTK and QT theming systems.

## How does it work?

For some obscure reason, [^1] all schemes provided by tinted-theming are YAML
files vendored in one massive repository. Basix, in turn, fetches the theme data
from the tinted-theming repository and converts them into JSON to ensure the
schemes are available in a format Nix can read, parse and expose under the flake
outputs.

Downloading and parsing is done by a
[quick and dirty Python script](./packages/convert-scheme/) and then exposed by
the flake as `schemeData`. You can also import the Nix2 endpoint provided by
`default.nix` and get `schemeData` that way.

### How do I use this?

Basix can be used as a flake input, or imported from a tarball. To get a color
scheme, import either `schemeData.base16` or `schemeData.base24` from the
outputs from this flake to import the color schemes for yourself. For example,
in the Nix REPL:

```bash
nix-repl> :p schemeData.base16.decaf
{
  author = "Alex Mirrington (https://github.com/alexmirrington)";
  name = "Decaf";
  palette = {
    base00 = "2d2d2d";
    base01 = "393939";
    base02 = "515151";
    base03 = "777777";
    base04 = "b4b7b4";
    base05 = "cccccc";
    base06 = "e0e0e0";
    base07 = "ffffff";
    base08 = "ff7f7b";
    base09 = "ffbf70";
    base0A = "ffd67c";
    base0B = "beda78";
    base0C = "bed6ff";
    base0D = "90bee1";
    base0E = "efb3f7";
    base0F = "ff93b3";
  };
  system = "base16";
  variant = "dark";
}
```

You can get a list of schemes by looking into [`json/`](./json) for the
appropriate theming model or evaluate available themes in the Nix REPL using
`attrNames` or similar.

### Generated theme packages

Basix also generates "conservative" GTK/Qt themes for every Base16/Base24
scheme:

- `themePackages.<system>.base16.<slug>`
- `themePackages.<system>.base24.<slug>`
- `packages.<system>.themes-base16`
- `packages.<system>.themes-base24`
- `packages.<system>.themes-all`

You can build them if you so wish:

```bash
# Build all packages
$ nix build .#themes-all

# Build base16 theme packages
$ nix build .#themes-base16

# Build only the 'decaf' theme package
$ nix build .#themePackages.x86_64-linux.base16.decaf
```

`themePackages` is keyed by system, so the system segment is required.

Generated install paths include:

- GTK themes under `share/themes/Basix-<slug>/...`
  - `gtk-2.0/gtkrc`
  - `gtk-3.0/gtk.css`
  - `gtk-4.0/gtk.css`
- Qt color schemes under:
  - `share/qt5ct/colors/Basix-<slug>.conf`
  - `share/qt6ct/colors/Basix-<slug>.conf`
- Kvantum theme assets under:
  - `share/Kvantum/Basix-<slug>/Basix-<slug>.kvconfig`
  - `share/Kvantum/Basix-<slug>/Basix-<slug>.svg`

These are generated from Base16/Base24 palettes and intentionally keep styling
flat and conservative for broad compatibility.

## Why?

There are not many theming solutions for Nix. Those that already exist are
either too convoluted, or straight up bad in terms of code quality or/and
execution. This leads me to use (and recommend) home-baked theming modules for
in-home usage, but there was not a good Base16 solution on Nix. Basix aims to
solve this issue by providing you an auto-updated collection of Base16 and
Base24 color palettes. As opposed to traditional hacks needed to convert YAML to
JSON and then read it, you can simply consume attribute sets derived from JSON
schemes while Basix does the heavy lifting for you.

Basix might come in handy in scenarios you wish to theme individual applications
from a pre-defined color palette.

## Credits

- [@Gerg-l](https://github.com/gerg-l) for the clinically insane import
  function.
- [@arcnmx/base16.nix](https://github.com/arcnmx/base16.nix) for the idea.

## License

Licensed under the [GNU General Public License v3.0](LICENSE).

[^1]: I'm being generous here. The obscure reason is the myth that YAML is human
    readable. Guess what? It is
    [actually nowhere near human readable and you
    should avoid it](https://ruudvanasseldonk.com/2023/01/11/the-yaml-document-from-hell)
