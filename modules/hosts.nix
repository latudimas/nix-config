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

  # Shorthands for the registered aspect modules.
  hm = config.flake.modules.homeManager;
  darwin = config.flake.modules.darwin;
  nixos = config.flake.modules.nixos;

  # Git commit identity. Kept here (not in modules/home/git.nix) so a work
  # machine can swap in a different name/email without touching the aspect.
  gitIdentity = {
    programs.git.settings.user = {
      name = "Riswandha Latu Dimas";
      email = "riswandha.ld@gmail.com";
    };
  };

  # PROFILES = which aspects a host turns on. Editing these lists is how you
  # add/remove features per machine.
  fullHome = [
    hm.base
    gitIdentity
    hm.nodejs
    hm.cli
    hm.git
    hm.zsh
    hm.tmux
    hm.direnv
    hm.aiTools
    hm.helix
    hm.yazi
  ];
  minimalHome = [
    hm.base
    gitIdentity
    hm.git
    hm.cli
    hm.zsh
    hm.linuxNix
    hm.cache # binary cache; needs nix.package from hm.linuxNix
    hm.yazi
  ];

  # Builder for the STANDALONE home-manager (Linux) hosts. Standalone HM gets a
  # ready-made pkgs, so we import nixpkgs here with overlays + allowUnfree.
  mkHome =
    { system, modules }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = { inherit inputs; };
      inherit modules;
    };

  # Server-only extras shared by all VPS hosts.
  vpsExtras =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.neovim ]; # one server-only extra
    };
in
{
  # ---- smol: macOS (nix-darwin + home-manager) ----
  # No `system` argument: darwin.base sets nixpkgs.hostPlatform.
  flake.darwinConfigurations.smol = nix-darwin.lib.darwinSystem {
    specialArgs = { inherit inputs; };
    modules = [
      darwin.base
      darwin.cache # dims-nix binary cache (system half)
      darwin.kitty # ← system half of the "kitty + font" feature
      home-manager.darwinModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-backup";
          extraSpecialArgs = { inherit inputs; };
          users.dims = {
            imports = fullHome ++ [ hm.kitty ]; # full profile + Mac-only kitty (user half)
            home.homeDirectory = "/Users/dims";
            # Mac mini: Homebrew PostgreSQL 18 on PATH.
            home.sessionPath = [ "/opt/homebrew/opt/postgresql@18/bin" ];
          };
        };
      }
    ];
  };

  # ---- dims-wsl: NixOS on WSL (NixOS + home-manager module) ----
  # Same fullHome profile as dims-work, plus Java 21. Unlike dims-work (standalone
  # HM), NixOS owns the system layer here: nix.conf and the binary cache come
  # from nixos.cache, so the hm.linuxNix / hm.cache pair isn't needed here.
  # Apply inside WSL with: sudo nixos-rebuild switch --flake .#dims-wsl
  flake.nixosConfigurations.dims-wsl = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      inputs.nixos-wsl.nixosModules.default # provides the `wsl.*` options
      nixos.wsl
      nixos.cache
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-backup";
          extraSpecialArgs = { inherit inputs; };
          users.dims.imports = fullHome ++ [ hm.java ];
        };
      }
    ];
  };

  # ---- dims-work: WSL (standalone home-manager, full) ----
  flake.homeConfigurations."dims-work" = mkHome {
    system = "x86_64-linux";
    modules = fullHome ++ [
      hm.linuxNix
      hm.cache # binary cache; needs nix.package from hm.linuxNix
      { home.homeDirectory = "/home/dims"; }
    ];
  };

  # ---- vps-dims: original VPS (username: dims) ----
  flake.homeConfigurations."vps-dims" = mkHome {
    system = "x86_64-linux";
    modules = minimalHome ++ [
      vpsExtras
      {
        home.username = "dims";
        home.homeDirectory = "/home/dims";
      }
    ];
  };

  # ---- vps-dudidam: new VPS (username length restriction) ----
  flake.homeConfigurations."vps-dudidam" = mkHome {
    system = "x86_64-linux";
    modules = minimalHome ++ [
      vpsExtras
      {
        home.username = "dudidam";
        home.homeDirectory = "/home/dudidam";
      }
    ];
  };
}
