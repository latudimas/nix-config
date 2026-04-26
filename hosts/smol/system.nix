{ pkgs, ... }:
{
  # System state version
  system.stateVersion = 5;

  # The platform the config will be used on
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # enable nix flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow devenv/cachix to manage binary caches
  nix.settings.trusted-users = [
    "root"
    "dims"
  ];

  # Binary cache — get public key from: https://app.cachix.org/cache/dims-nix
  nix.settings.extra-substituters = [ "https://dims-nix.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [ "dims-nix.cachix.org-1:42IUG0D/t5x5liUzsGzn0UJDfbJ86eO34cJeDkwqLlk=" ];

  # Set zsh as default shell
  environment.shells = [ pkgs.zsh ];
  users.users.dims.shell = pkgs.zsh;
}
