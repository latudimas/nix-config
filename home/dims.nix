{ pkgs, ... }:
{
  imports = [
    ../modules/development
    ../modules/shell
    ../modules/packages
  ];

  programs.home-manager.enable = true;

  home = {
    username = "dims";
    # homeDirectory is set per-host in flake.nix

    # WARNING: DO NOT CHANGE THIS
    stateVersion = "24.11";
  };

  nixpkgs.config.allowUnfree = true;
}
