# modules/development/zig.nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Core Zig toolchain
    zig # Latest stable Zig compiler
    zls # Zig Language Server for IDE support

    # Build tools commonly used with Zig
    # cmake # Often needed for C/C++ interop
    # ninja # Fast build system

    # Debugging and analysis tools
    # lldb # LLVM debugger, works well with Zig
    # valgrind # Memory analysis tool

    # C/C++ toolchain (useful for Zig's interop features)
    # clang      # C/C++ compiler
    # lld # LLVM linker
  ];

  # Environment variables for Zig
  home.sessionVariables = {
    # Cache directories
    ZIG_CACHE_HOME = "$HOME/.cache/zig";
    ZIG_GLOBAL_CACHE = "$HOME/.cache/zig/global";

    # Optional: Set default local cache location for projects
    ZIG_LOCAL_CACHE_DIR = ".cache/zig";

    # Optional: Add Zig-specific flags
    # ZIG_SYSTEM_LINKER_HACK = "1";  # Uncomment if needed for specific use cases
  };

  # Optional: Add Zig-specific shell aliases
  home.shellAliases = {
    zb = "zig build";
    zt = "zig test";
    zr = "zig run";
    zfmt = "zig fmt";
  };
}
