{
  description = "Dims' multi-device nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nix-darwin, nixpkgs, home-manager, devenv, ... }:
    let
      overlay-devenv = final: prev: {
        devenv = devenv.packages.${prev.system}.devenv;
      };
    in
    {
      # macOS — nix-darwin + home-manager
      darwinConfigurations.smol = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          { nixpkgs.overlays = [ overlay-devenv ]; }
          ./hosts/smol
          home-manager.darwinModules.home-manager
        ];
      };

      # WSL — home-manager standalone (full config)
      homeConfigurations."dims-work" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ overlay-devenv ];
        };
        modules = [ ./hosts/dims-work ];
      };

      # VPS — home-manager standalone (minimal packages)
      homeConfigurations."vps" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ overlay-devenv ];
        };
        modules = [ ./hosts/vps ];
      };
    };
}
