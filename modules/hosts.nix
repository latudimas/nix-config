# Host assembly — the one place that turns reusable "aspects" into concrete
# machine configurations. Every aspect is collected from `flake.modules.*`
# (populated by the files under modules/home and modules/darwin).
{ inputs, config, ... }:
let
  inherit (inputs) nixpkgs home-manager nix-darwin;

  # devenv overlay, shared by every host (dendritic style: a plain let-binding,
  # no specialArgs gymnastics needed).
  overlay-devenv = final: prev: {
    devenv = inputs.devenv.packages.${prev.system}.devenv;
  };

  # Aspect modules, gathered from all the dendritic files.
  hm = config.flake.modules.homeManager;
  darwin = config.flake.modules.darwin;

  # Profiles = which aspects a host turns on.
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

  # Standalone Home-Manager builder for the Linux hosts.
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
            imports = fullHome;
            home.homeDirectory = "/Users/dims";
            # Mac Mini: Homebrew PostgreSQL 18 on PATH
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
          home.packages = [ pkgs.neovim ];
        }
      )
    ];
  };
}
