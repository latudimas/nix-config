# Aspect: Kitty terminal + its font — a feature that spans BOTH layers.
# ============================================================================
# THE POINT OF THIS FILE: a single aspect can register modules for *different*
# classes. Here one file owns the whole "kitty + font" feature:
#   • the USER half   (home-manager) — configure the terminal, and
#   • the macOS SYSTEM half (nix-darwin) — install the font system-wide.
# Activate by selecting `hm.kitty` and `darwin.kitty` in modules/hosts.nix.
{
  # USER half — tell kitty which font to use.
  flake.modules.homeManager.kitty = {
    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 14;
      };
    };
  };

  # macOS SYSTEM half — install the font. GUI apps (kitty) read fonts from the
  # system font directories, which on nix-darwin is the `fonts.packages` option.
  flake.modules.darwin.kitty =
    { pkgs, ... }:
    {
      fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
    };
}
