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
    # homeDirectory is set per-host in hosts/*/default.nix

    # WARNING: DO NOT CHANGE THIS
    stateVersion = "24.11";
  };
}
