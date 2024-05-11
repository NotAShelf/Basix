# Basix

An over-engineered Nix flake for _all_ Base16 and Base24 themes from
[tinted-theming/schemes](https://github.com/tinted-theming/schemes), exposed as
one convenient library.

## How does it work?

For some obscure reason[^1] all schemes provided by tinted-theming is in YAML
under one unified repository. We convert each YAML scheme to JSON to ensure the
schemes are in a format Nix can read, then read them and expose them under a
flake output.

## How do I use this?

Basix be used as a flake input, or imported from a tarball.

To get a colorscheme, import either `schemeData.base16` or `schemeData.base24`
from the outputs from this flake to import the colorschemes for yourself.

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

## Credits

- [@Gerg-l](https://github.com/gerg-l) for the clinically insane import
  function.
- [@arcnmx/base16.nix](https://github.com/arcnmx/base16.nix) for the idea.

## License

Licensed under the [GNU General Public License v3.0](LICENSE).

[^1]:
    I'm being generous here. The obscure reason is the myth that YAML is human
    readable. Guess what? It is [actually nowhere near human readable and you
    should avoid it](https://ruudvanasseldonk.com/2023/01/11/the-yaml-document-from-hell)
