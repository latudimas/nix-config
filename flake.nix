# flake.nix — entry point, "dendritic" style.
# ============================================================================
# Compare with the modular branch: there, flake.nix lists every host and wires
# them up by hand. Here it does almost nothing — thanks to two ideas:
#
#   • flake-parts — lets us write the flake as a TREE OF SMALL MODULES instead
#                   of one big attribute set. Each module can contribute to any
#                   output (packages, configurations, ...).
#   • import-tree — recursively finds every *.nix file under ./modules and
#                   imports each as a flake-parts module. "Add a feature" =
#                   "drop a file in"; there is no central list of imports.
#
# The DENDRITIC pattern = "every file is a flake-parts module". Each file under
# ./modules describes one ASPECT (git, zsh, ...) and can target macOS, Linux,
# and home-manager at once. Start reading at modules/home/base.nix (explains the
# mechanism), then modules/hosts.nix (assembles aspects into real machines).
{
  description = "Dims' multi-device nix config (dendritic pattern PoC)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # The two pillars of the dendritic pattern.
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # devenv is intentionally NOT an input: the CLI comes from nixpkgs
    # (modules/home/cli.nix); each project pins its own devenv anyway.
  };

  # mkFlake builds the flake from a single module. `import-tree ./modules` IS
  # that module: at evaluation it expands to `{ imports = [ ./modules/... ]; }`
  # covering every file in the tree.
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
