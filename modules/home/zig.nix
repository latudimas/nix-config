# Aspect: Zig toolchain. (Defined but not enabled by any profile yet.)
{
  flake.modules.homeManager.zig =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        zig # Latest stable Zig compiler
        zls # Zig Language Server for IDE support
      ];

      home.sessionVariables = {
        ZIG_CACHE_HOME = "$HOME/.cache/zig";
        ZIG_GLOBAL_CACHE = "$HOME/.cache/zig/global";
        ZIG_LOCAL_CACHE_DIR = ".cache/zig";
      };

      home.shellAliases = {
        zb = "zig build";
        zt = "zig test";
        zr = "zig run";
        zfmt = "zig fmt";
      };
    };
}
