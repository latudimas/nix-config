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
  };

  outputs =
    { self, nix-darwin, nixpkgs, home-manager, ... }:
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
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [ ./hosts/vps ];
      };
    };
}
