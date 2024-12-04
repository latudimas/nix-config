{
  description = "Example nix-darwin system flake";

  inputs = {
    # Core package collection - unstable channel for latest packages 
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Darwin system configuration manager
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nix-darwin, nixpkgs, home-manager }: {
    darwinConfigurations."smol" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        # System config from separate files
        ./darwin-configuration.nix

        # ./hosts/darwin/default.nix

        # Home-manager configuration
        home-manager.darwinModules.home-manager
        {
          users.users.dims.home = "/Users/dims";
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            # users.dims = import ./modules/home-manager/default.nix;
            users.dims = import ./home.nix;
          };
        }
      ];
    };
  };
}

