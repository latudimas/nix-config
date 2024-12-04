{ pkgs, ... }:
{
  # System-level packages
  environment.systemPackages = [ ];

  # Enable Nix flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Set Git commit hash for darwin-version
  system.configurationRevision = null;

  # System state version
  system.stateVersion = 5;

  # Enable nix-darwin's shell integration
  programs.zsh.enable = true; # If you use zsh
  # programs.fish.enable = true;  # If you use fish

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # The platform the configuration will be used on
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Shell Aliases
  environment.shellAliases = {
    ll = "eza -l --icons";
    drs = "darwin-rebuild switch --flake ~/.config/nix-darwin";
  };
}
