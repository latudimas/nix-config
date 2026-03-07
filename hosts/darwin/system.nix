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
}
