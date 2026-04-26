{
  description = "Dims' multi-device nix config";

  inputs = {
    # Unstable channel for dev machines
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Stable channel for servers (24.11)
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nix-darwin, nixpkgs, nixpkgs-stable, home-manager, ... }:
    {
      # macOS — nix-darwin + home-manager
      darwinConfigurations.smol = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/smol
          home-manager.darwinModules.home-manager
        ];
      };

      # WSL — home-manager standalone (full config)
      homeConfigurations."dims-work" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [ ./hosts/dims-work ];
      };

      # VPS — home-manager standalone (minimal packages)
      homeConfigurations."vps" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs-stable.legacyPackages."x86_64-linux";
        modules = [ ./hosts/vps ];
      };
    };
}
