# modules/systems.nix — base flake-parts wiring (itself a flake-parts module).
# ============================================================================
{ inputs, ... }:
{
  # Turn ON the `flake.modules.<class>.<name>` option the whole dendritic
  # pattern leans on. WITHOUT this import those options don't exist, and every
  # aspect file (modules/home/*, modules/darwin/*) would fail with
  # "option `flake.modules` does not exist".
  imports = [ inputs.flake-parts.flakeModules.modules ];

  # flake-parts requires the list of systems it may produce per-system outputs
  # (devShells, formatter, ...) for. Ours: one Apple Silicon Mac + two Linux.
  systems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];
}
