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
    homeDirectory = "/Users/dims";

    # WARNING: DO NOT CHANGE THIS
    stateVersion = "24.11";
  };
}
