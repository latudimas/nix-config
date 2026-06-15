# Aspect: Zig toolchain. Defined but NOT in any profile yet (add `hm.zig` to a
# profile in modules/hosts.nix). Ships the compiler + zls (language server).
{
  flake.modules.homeManager.zig =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        zig # Latest stable Zig compiler
        zls # Zig Language Server for IDE support
      ];

      # Keep Zig's caches under ~/.cache instead of littering projects.
      home.sessionVariables = {
        ZIG_CACHE_HOME = "$HOME/.cache/zig";
        ZIG_GLOBAL_CACHE = "$HOME/.cache/zig/global";
        ZIG_LOCAL_CACHE_DIR = ".cache/zig";
      };

      # Short aliases for the commands you type all day.
      home.shellAliases = {
        zb = "zig build";
        zt = "zig test";
        zr = "zig run";
        zfmt = "zig fmt";
      };
    };
}
