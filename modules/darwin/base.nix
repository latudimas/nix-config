# Aspect: darwin system base (was hosts/smol/system.nix).
{
  flake.modules.darwin.base =
    { pkgs, ... }:
    {
      system.stateVersion = 5;
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix.settings.trusted-users = [
        "root"
        "dims"
      ];

      # Binary cache — get public key from: https://app.cachix.org/cache/dims-nix
      nix.settings.extra-substituters = [ "https://dims-nix.cachix.org" ];
      nix.settings.extra-trusted-public-keys = [
        "dims-nix.cachix.org-1:42IUG0D/t5x5liUzsGzn0UJDfbJ86eO34cJeDkwqLlk="
      ];

      environment.shells = [ pkgs.zsh ];
      users.users.dims.shell = pkgs.zsh;
      users.users.dims.home = "/Users/dims";
    };
}
