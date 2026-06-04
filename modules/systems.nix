# flake-parts base wiring (itself a flake-parts module).
{ inputs, ... }:
{
  # Enables the `flake.modules.<class>.<name>` option that the dendritic
  # pattern is built on (aspect modules under modules/home and modules/darwin).
  imports = [ inputs.flake-parts.flakeModules.modules ];

  # Required by flake-parts for any per-system outputs (devShells / formatter).
  systems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];
}
