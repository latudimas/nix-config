# modules/hosts.nix — where ASPECTS become MACHINES.
# ============================================================================
# Every other file just *registers* aspects (reusable modules). This file is
# the one place that *assembles* them into real configurations. The flow:
#
#   modules/home/*.nix   ──registers──►  config.flake.modules.homeManager.*
#   modules/darwin/*.nix ──registers──►  config.flake.modules.darwin.*
#                                              │
#   this file picks aspects into "profiles" ◄──┘ and feeds them to the
#   nix-darwin / home-manager builders below.
#
# `{ inputs, config, ... }` are provided by flake-parts: `config` is the merged
# flake-parts config, so `config.flake.modules.*` sees every aspect file.
{ inputs, config, ... }:
let
  inherit (inputs) nixpkgs home-manager nix-darwin;

  # devenv overlay, shared by every host. Dendritic style: just a let-binding,
  # no specialArgs gymnastics needed.
  overlay-devenv = final: prev: {
    devenv = inputs.devenv.packages.${prev.system}.devenv;
  };

  # Shorthands for the registered aspect modules.
  hm = config.flake.modules.homeManager;
  darwin = config.flake.modules.darwin;

  # PROFILES = which aspects a host turns on. Editing these lists is how you
  # add/remove features per machine.
  fullHome = [
    hm.base
    hm.nodejs
    hm.cli
    hm.git
    hm.zsh
    hm.tmux
    hm.direnv
    hm.aiTools
    hm.helix
  ];
  minimalHome = [
    hm.base
    hm.git
    hm.cli
    hm.zsh
    hm.linuxNix
  ];

  # Builder for the STANDALONE home-manager (Linux) hosts. Standalone HM gets a
  # ready-made pkgs, so we import nixpkgs here with overlays + allowUnfree.
  mkHome =
    { system, modules }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay-devenv ];
        config.allowUnfree = true;
      };
      extraSpecialArgs = { inherit inputs; };
      inherit modules;
    };
in
{
  # ---- smol: macOS (nix-darwin + home-manager) ----
  flake.darwinConfigurations.smol = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit inputs; };
    modules = [
      { nixpkgs.overlays = [ overlay-devenv ]; }
      darwin.base
      home-manager.darwinModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-backup";
          extraSpecialArgs = { inherit inputs; };
          users.dims = {
            imports = fullHome; # turn on the full profile for this user
            home.homeDirectory = "/Users/dims";
            # Mac mini: Homebrew PostgreSQL 18 on PATH.
            home.sessionPath = [ "/opt/homebrew/opt/postgresql@18/bin" ];
          };
        };
      }
    ];
  };

  # ---- dims-work: WSL (standalone home-manager, full) ----
  flake.homeConfigurations."dims-work" = mkHome {
    system = "x86_64-linux";
    modules = fullHome ++ [
      hm.linuxNix
      { home.homeDirectory = "/home/dims"; }
    ];
  };

  # ---- vps: standalone home-manager (minimal) ----
  flake.homeConfigurations."vps" = mkHome {
    system = "x86_64-linux";
    modules = minimalHome ++ [
      (
        { pkgs, ... }:
        {
          home.homeDirectory = "/home/dims";
          home.packages = [ pkgs.neovim ]; # one server-only extra
        }
      )
    ];
  };
}
